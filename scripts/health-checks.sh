#!/usr/bin/env bash
# health-checks.sh — Deterministic health checks for layers 7 and 9
# Called by .claude/skills/health/SKILL.md. Outputs structured check results.
# Usage: bash scripts/health-checks.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude"
PASS=0
WARN=0
FAIL=0

check() {
  local severity="$1" name="$2" detail="$3"
  echo "[$severity] $name: $detail"
  case "$severity" in
    PASS) PASS=$((PASS + 1)) ;;
    WARN) WARN=$((WARN + 1)) ;;
    FAIL) FAIL=$((FAIL + 1)) ;;
  esac
}

echo "=== HEALTH CHECKS (deterministic) ==="
echo "Repo: $REPO_ROOT"
echo "Target: $TARGET"
echo ""

# ============================================================
# LAYER 7: Governance
# ============================================================
echo "--- Layer 7: Governance ---"

# 7.1 Upstream freshness — gstack
if [ -f "$TARGET/skills/gstack/VERSION" ]; then
  GSTACK_INSTALLED=$(cat "$TARGET/skills/gstack/VERSION" 2>/dev/null || echo "unknown")
  echo "[INFO] gstack version: $GSTACK_INSTALLED"
else
  check WARN "gstack VERSION" "not found at $TARGET/skills/gstack/VERSION"
fi

# 7.2 Upstream freshness — waza
if [ -f "$REPO_ROOT/skills/waza/health/SKILL.md" ]; then
  WAZA_VER=$(grep -oP 'version:\s*"\K[^"]+' "$REPO_ROOT/skills/waza/health/SKILL.md" 2>/dev/null || echo "unknown")
  check PASS "Waza upstream" "version $WAZA_VER present"
else
  check WARN "Waza upstream" "skills/waza/health/SKILL.md not found"
fi

# 7.3 Contract validation
if [ -x "$REPO_ROOT/scripts/validate-skill-contracts.sh" ]; then
  CONTRACT_OUT=$(bash "$REPO_ROOT/scripts/validate-skill-contracts.sh" 2>&1)
  if echo "$CONTRACT_OUT" | grep -q "Errors: 0"; then
    CONTRACTS=$(echo "$CONTRACT_OUT" | grep "Contracts:" | grep -oE '[0-9]+')
    check PASS "Contract validation" "$CONTRACTS contracts, 0 errors"
  else
    check FAIL "Contract validation" "$(echo "$CONTRACT_OUT" | tail -3)"
  fi
else
  check WARN "Contract validation" "validate-skill-contracts.sh not found"
fi

# 7.4 Audit spec validation
if [ -x "$REPO_ROOT/scripts/validate-audit-spec.sh" ]; then
  SPEC_OUT=$(bash "$REPO_ROOT/scripts/validate-audit-spec.sh" 2>&1)
  if echo "$SPEC_OUT" | grep -q "PASSED"; then
    check PASS "Audit spec validation" "$(echo "$SPEC_OUT" | head -1)"
  else
    check FAIL "Audit spec validation" "$(echo "$SPEC_OUT" | head -1)"
  fi
else
  check WARN "Audit spec validation" "validate-audit-spec.sh not found"
fi

# 7.5 Template coverage
if [ -f "$REPO_ROOT/artifact-manifests.json" ] && command -v jq >/dev/null 2>&1; then
  ARTIFACT_TYPES=$(jq -r '.types[].required[]?.template // empty' "$REPO_ROOT/artifact-manifests.json" 2>/dev/null | sort -u | wc -l | tr -d ' ')
  TEMPLATE_COUNT=$(find "$REPO_ROOT/upstreams/claude-skills-templates/templates" -name '*.md' -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
  check PASS "Template coverage" "$TEMPLATE_COUNT templates for $ARTIFACT_TYPES artifact types"
else
  echo "[INFO] Template coverage: skipped (no artifact-manifests.json or jq)"
fi

# 7.5b Skill usage (from analytics)
if [ -f ~/.gstack/analytics/skill-usage.jsonl ]; then
  USAGE_COUNT=$(wc -l < ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null | tr -d ' ')
  echo "[INFO] Skill usage: $USAGE_COUNT invocations recorded"
else
  echo "[INFO] Skill usage: no analytics file found"
fi

# 7.6 Empty dirs
EMPTY_DIRS=$(find "$REPO_ROOT" -type d -empty -not -path '*/.git/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
if [ "$EMPTY_DIRS" -gt 0 ]; then
  check WARN "Empty dirs" "$EMPTY_DIRS empty directories found"
else
  check PASS "Empty dirs" "none"
fi

# 7.7 CLI dependencies
for cmd in git gh jq; do
  if command -v "$cmd" >/dev/null 2>&1; then
    check PASS "CLI dep: $cmd" "available"
  else
    check WARN "CLI dep: $cmd" "not found"
  fi
done

# 7.6 Commands non-empty
if [ -d "$REPO_ROOT/.claude/commands" ]; then
  for cmd_file in "$REPO_ROOT"/.claude/commands/*.md; do
    [ -f "$cmd_file" ] || continue
    name=$(basename "$cmd_file")
    if [ -s "$cmd_file" ]; then
      check PASS "Command: $name" "non-empty"
    else
      check FAIL "Command: $name" "empty file"
    fi
  done
fi

# 7.7 Principle alignment — rules trace to principles
if [ -d "$REPO_ROOT/.claude/rules" ]; then
  for rule_file in "$REPO_ROOT"/.claude/rules/*.md; do
    [ -f "$rule_file" ] || continue
    name=$(basename "$rule_file")
    if grep -qiE 'P[0-9]+|D[0-9]+' "$rule_file" 2>/dev/null; then
      check PASS "Rule traces to principle: $name" "yes"
    else
      check WARN "Rule traces to principle: $name" "no principle citation found"
    fi
  done
fi

# 7.8 Replaced skill detection — check for stale references to replaced skills
if command -v jq >/dev/null 2>&1 && [ -f "$REPO_ROOT/skills-catalog.json" ]; then
  STALE_REFS=0
  while IFS= read -r replaced_name; do
    [ -z "$replaced_name" ] && continue
    # Search owned files only: docs/**/*.md, scripts/*.sh, .claude/skills/**/*.md, CLAUDE.md, README.md
    # Exclude: skills/ (upstream P2), CHANGELOG.md (history), docs/inspections/ (snapshots), skills-catalog.json (the replaces field itself)
    HITS=$(grep -rl "$replaced_name" \
      "$REPO_ROOT"/upstreams/claude-skills-templates/docs/*/PRD.md "$REPO_ROOT"/upstreams/claude-skills-templates/docs/*/ARCHITECTURE.md "$REPO_ROOT"/upstreams/claude-skills-templates/docs/*/TEST-SPEC.md \
      "$REPO_ROOT"/scripts/*.sh \
      "$REPO_ROOT"/upstreams/claude-skills-templates/skills/*/SKILL.md \
      "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/README.md" \
      2>/dev/null | grep -v "skills-catalog.json" | grep -v "docs/inspections/" | head -5)
    if [ -n "$HITS" ]; then
      STALE_REFS=$((STALE_REFS + 1))
      check WARN "Stale ref: $replaced_name" "found in: $(echo "$HITS" | tr '\n' ', ')"
    fi
  done < <(jq -r '.skills[] | select(.replaces != null) | .replaces[]' "$REPO_ROOT/skills-catalog.json" 2>/dev/null)
  [ "$STALE_REFS" -eq 0 ] && check PASS "Replaced skill refs" "no stale references found"
fi

echo ""

# ============================================================
# LAYER 9: Deploy State
# ============================================================
echo "--- Layer 9: Deploy State ---"

# 9.1 Deploy drift
if [ -x "$REPO_ROOT/scripts/deploy.sh" ]; then
  DRIFT_OUT=$(bash "$REPO_ROOT/scripts/deploy.sh" --dry-run 2>&1)
  check PASS "Deploy dry-run" "completed"
else
  check FAIL "Deploy script" "deploy.sh not found or not executable"
fi

# 9.2 Skill sync — every catalog skill is deployed
if command -v jq >/dev/null 2>&1 && [ -f "$REPO_ROOT/skills-catalog.json" ]; then
  MISSING=0
  while IFS= read -r skill_name; do
    if [ ! -d "$TARGET/skills/$skill_name" ]; then
      check FAIL "Skill deployed: $skill_name" "missing from $TARGET/skills/"
      MISSING=$((MISSING + 1))
    fi
  done < <(jq -r '.skills[] | select(.status != "removed") | .name' "$REPO_ROOT/skills-catalog.json")
  [ "$MISSING" -eq 0 ] && check PASS "Skill sync" "all catalog skills deployed"
fi

# 9.3 Orphan skills
if command -v jq >/dev/null 2>&1; then
  CATALOG_SKILLS=$(jq -r '.skills[] | select(.status != "removed") | .name' "$REPO_ROOT/skills-catalog.json" | sort)
  ORPHANS=0
  for installed_dir in "$TARGET"/skills/*/; do
    [ -d "$installed_dir" ] || continue
    installed_name=$(basename "$installed_dir")
    [ "$installed_name" = "gstack" ] && continue
    [ "$installed_name" = "waza" ] && continue
    if ! echo "$CATALOG_SKILLS" | grep -qx "$installed_name"; then
      check WARN "Orphan skill" "$installed_name not in catalog"
      ORPHANS=$((ORPHANS + 1))
    fi
  done
  [ "$ORPHANS" -eq 0 ] && check PASS "Orphan skills" "none found"
fi

# 9.4 Stale sessions
STALE_SESSIONS=$(find ~/.gstack/sessions -type f -mmin +1440 2>/dev/null | wc -l | tr -d ' ')
if [ "$STALE_SESSIONS" -gt 0 ]; then
  check WARN "Stale sessions" "$STALE_SESSIONS files >24h old"
else
  check PASS "Stale sessions" "none"
fi

# 9.5 Temp files
TEMP_FILES=$(find "$TARGET" ~/.gstack -name '*.tmp' -o -name '.pending-*' -o -name '*.bak' 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEMP_FILES" -gt 0 ]; then
  check WARN "Temp files" "$TEMP_FILES found"
else
  check PASS "Temp files" "none"
fi

# 9.6 Oversized files
OVERSIZED=$(find "$TARGET" -type f -size +10M 2>/dev/null | wc -l | tr -d ' ')
if [ "$OVERSIZED" -gt 0 ]; then
  check WARN "Oversized files" "$OVERSIZED files >10MB"
else
  check PASS "Oversized files" "none"
fi

# 9.7 Disk usage
CLAUDE_SIZE=$(du -sh "$TARGET" 2>/dev/null | cut -f1 || echo "unknown")
GSTACK_SIZE=$(du -sh ~/.gstack 2>/dev/null | cut -f1 || echo "unknown")
echo "[INFO] ~/.claude/ size: $CLAUDE_SIZE"
echo "[INFO] ~/.gstack/ size: $GSTACK_SIZE"

# 9.8 settings.json exists
if [ -f "$TARGET/settings.json" ]; then
  check PASS "settings.json" "exists"
else
  check FAIL "settings.json" "missing — Claude Code may not work correctly"
fi

# 9.9 Repo status (P11)
UNCOMMITTED=$(git -C "$REPO_ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$UNCOMMITTED" -gt 0 ]; then
  check WARN "Repo status" "$UNCOMMITTED uncommitted changes (P11)"
else
  check PASS "Repo status" "clean"
fi

# 9.10 Analytics volume
if [ -d ~/.gstack/analytics ]; then
  ANALYTICS_SIZE=$(du -sh ~/.gstack/analytics 2>/dev/null | cut -f1 || echo "unknown")
  echo "[INFO] Analytics size: $ANALYTICS_SIZE"
fi

echo ""
echo "=== SUMMARY ==="
echo "PASS: $PASS | WARN: $WARN | FAIL: $FAIL"
echo "=== END ==="
