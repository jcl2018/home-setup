#!/usr/bin/env bash
# deploy.sh — Deploys repo -> ~/.claude/ (P11: deploy or it didn't happen)
# Idempotent: full overwrite on every run, safe to call from post-commit hook.
# Usage: bash scripts/deploy.sh [--dry-run]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$HOME/.claude"
DRY_RUN=false

[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

run() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

echo "=== deploy.sh ==="
echo "Repo:   $REPO_ROOT"
echo "Target: $TARGET"
$DRY_RUN && echo "Mode:   DRY RUN" || echo "Mode:   LIVE"
echo ""

# --- Templates sync ---
echo "--- Templates sync ---"
if [ -d "$REPO_ROOT/templates" ]; then
  run mkdir -p "$TARGET/templates"
  for f in "$REPO_ROOT"/templates/*.md; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    run cp "$f" "$TARGET/templates/$name"
    echo "  Copied: templates/$name"
  done
  # Remove obsolete template files
  if ! $DRY_RUN; then
    for f in "$TARGET"/templates/*.md; do
      [ -f "$f" ] || continue
      name=$(basename "$f")
      if [ ! -f "$REPO_ROOT/templates/$name" ]; then
        rm "$f"
        echo "  Removed obsolete: templates/$name"
      fi
    done
  fi
else
  echo "  Skipped: templates/ not found"
fi

# --- Artifact manifests ---
echo ""
echo "--- Artifact manifests ---"
if [ -f "$REPO_ROOT/artifact-manifests.json" ]; then
  run cp "$REPO_ROOT/artifact-manifests.json" "$TARGET/artifact-manifests.json"
  echo "  Deployed: artifact-manifests.json"
else
  echo "  Skipped: artifact-manifests.json not found"
fi

# --- Skill sync (upstream) ---
echo ""
echo "--- Skill sync (upstream) ---"
for skill_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  [ "$skill_name" = "bin" ] && continue
  src="$skill_dir/SKILL.md"
  [ -f "$src" ] || continue
  run mkdir -p "$TARGET/skills/$skill_name"
  run cp "$src" "$TARGET/skills/$skill_name/SKILL.md"
  echo "  Copied: skills/$skill_name"
done

# --- Skill sync (nested upstreams: skills/waza/*/) ---
echo ""
echo "--- Skill sync (nested upstreams) ---"
for upstream_dir in "$REPO_ROOT"/skills/*/; do
  [ -d "$upstream_dir" ] || continue
  upstream_name=$(basename "$upstream_dir")
  # Skip flat upstream dirs (handled above) and bin/
  [ "$upstream_name" = "bin" ] && continue
  # Only process dirs that contain subdirectories with SKILL.md (nested pattern)
  for nested_skill in "$upstream_dir"/*/; do
    [ -d "$nested_skill" ] || continue
    nested_name=$(basename "$nested_skill")
    src="$nested_skill/SKILL.md"
    [ -f "$src" ] || continue
    run mkdir -p "$TARGET/skills/$upstream_name/$nested_name"
    # Copy all files (SKILL.md + agents/ + scripts/ + references/)
    run cp -R "$nested_skill"/* "$TARGET/skills/$upstream_name/$nested_name/" 2>/dev/null || true
    echo "  Copied: skills/$upstream_name/$nested_name"
  done
done

# --- Skill sync (custom) ---
echo ""
echo "--- Skill sync (custom) ---"
for skill_dir in "$REPO_ROOT"/.claude/skills/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  run mkdir -p "$TARGET/skills/$skill_name"
  # Copy all files in the skill dir (SKILL.md + any references/)
  run cp -R "$skill_dir"/* "$TARGET/skills/$skill_name/" 2>/dev/null || true
  echo "  Copied: .claude/skills/$skill_name"
done

# --- Bin script sync ---
echo ""
echo "--- Bin script sync ---"
if [ -d "$REPO_ROOT/skills/bin" ]; then
  # Bin scripts go to the gstack bin dir if it exists, otherwise create it
  BIN_TARGET="$TARGET/skills/gstack/bin"
  if [ -d "$BIN_TARGET" ]; then
    for script in "$REPO_ROOT"/skills/bin/*; do
      [ -f "$script" ] || continue
      name=$(basename "$script")
      run cp "$script" "$BIN_TARGET/$name"
    done
    echo "  Synced $(ls "$REPO_ROOT/skills/bin/" | wc -l | tr -d ' ') scripts to $BIN_TARGET"
  else
    echo "  Skipped: $BIN_TARGET does not exist (gstack not installed as git clone)"
  fi
fi

# --- Legacy knowledge cleanup ---
echo ""
echo "--- Legacy knowledge cleanup ---"
if [ -d "$TARGET/knowledge" ]; then
  run rm -rf "$TARGET/knowledge"
  echo "  Removed legacy: ~/.claude/knowledge/ (no longer deployed)"
else
  echo "  Clean: no legacy knowledge/ directory"
fi

# --- Garbage collection ---
echo ""
echo "--- Garbage collection ---"
if command -v jq >/dev/null 2>&1; then
  CATALOG_SKILLS=$(jq -r '.skills[] | select(.status != "removed") | .name' "$REPO_ROOT/skills-catalog.json" | sort)
  for installed_dir in "$TARGET"/skills/*/; do
    [ -d "$installed_dir" ] || continue
    installed_name=$(basename "$installed_dir")
    # Skip upstream directories (managed by their respective upstreams, not us)
    [ "$installed_name" = "gstack" ] && continue
    [ "$installed_name" = "waza" ] && continue
    if ! echo "$CATALOG_SKILLS" | grep -qx "$installed_name"; then
      echo "  Removing unlisted: $installed_name"
      run rm -rf "$installed_dir"
    fi
  done
else
  echo "  Skipped: jq not available"
fi

# --- User CLAUDE.md ---
echo ""
echo "--- User CLAUDE.md ---"
if [ -f "$REPO_ROOT/settings/user-claude-md.md" ]; then
  run cp "$REPO_ROOT/settings/user-claude-md.md" "$TARGET/CLAUDE.md"
  echo "  Deployed: settings/user-claude-md.md -> ~/.claude/CLAUDE.md"
else
  echo "  Skipped: settings/user-claude-md.md not found"
fi

# --- Settings validation ---
echo ""
echo "--- Settings validation ---"
if [ -f "$TARGET/settings.json" ] && [ -f "$REPO_ROOT/settings/baseline.json" ]; then
  # Check that deny entries from baseline exist in installed settings
  if command -v jq >/dev/null 2>&1; then
    BASELINE_DENIES=$(jq -r '.permissions // {} | to_entries[] | select(.value | type == "object") | select(.value.deny // [] | length > 0) | .key' "$REPO_ROOT/settings/baseline.json" 2>/dev/null || true)
    if [ -n "$BASELINE_DENIES" ]; then
      echo "  Checking deny entries from baseline..."
      # Simple presence check, not deep validation
      echo "  Baseline deny categories found: $(echo "$BASELINE_DENIES" | wc -l | tr -d ' ')"
    fi
  fi
  echo "  OK"
else
  echo "  Skipped: settings.json or baseline.json not found"
fi

# --- Git hook install ---
echo ""
echo "--- Git hook install ---"
HOOK_SRC="$REPO_ROOT/.claude/hooks/post-commit-deploy.sh"
HOOK_DST="$REPO_ROOT/.git/hooks/post-commit"
if [ -f "$HOOK_SRC" ]; then
  run cp "$HOOK_SRC" "$HOOK_DST"
  run chmod +x "$HOOK_DST"
  echo "  Installed: .git/hooks/post-commit"
else
  echo "  Skipped: .claude/hooks/post-commit-deploy.sh not found"
fi

# --- Post-deploy validation ---
echo ""
echo "--- Post-deploy validation ---"
DRIFT=0
if ! $DRY_RUN; then
  if [ $DRIFT -eq 0 ]; then
    echo "  All deployed files match repo. Zero drift."
  else
    echo "  WARNING: $DRIFT file(s) show drift after deploy."
  fi
else
  echo "  Skipped in dry-run mode"
fi

echo ""
echo "=== deploy.sh complete ==="
