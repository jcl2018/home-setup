#!/usr/bin/env bash
# test-deploy.sh — Tests for deploy.sh
# Runs deploy against a temp HOME directory and verifies output.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPLOY="$REPO_ROOT/scripts/deploy.sh"
TMPDIR=$(mktemp -d)
PASS=0
FAIL=0

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

check() {
  local name="$1" condition="$2"
  if eval "$condition"; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name" >&2
    FAIL=$((FAIL + 1))
  fi
}

echo "=== test-deploy.sh ==="

# --- Test 1: Dry run produces no side effects ---
echo ""
echo "--- Test 1: Dry run ---"
FAKE_HOME="$TMPDIR/dry-run"
mkdir -p "$FAKE_HOME/.claude"
HOME="$FAKE_HOME" bash "$DEPLOY" --dry-run >/dev/null 2>&1 || true
check "dry-run no knowledge files" "[ ! -f '$FAKE_HOME/.claude/knowledge/INDEX.md' ]"

# --- Test 2: Live deploy copies knowledge ---
echo ""
echo "--- Test 2: Knowledge sync ---"
FAKE_HOME="$TMPDIR/live"
mkdir -p "$FAKE_HOME/.claude/knowledge" "$FAKE_HOME/.claude/skills" "$FAKE_HOME/.claude/settings"
# Create a fake .git dir so the hook install has somewhere to go
mkdir -p "$REPO_ROOT/.git/hooks" 2>/dev/null || true
HOME="$FAKE_HOME" bash "$DEPLOY" >/dev/null 2>&1 || true
check "INDEX.md deployed" "[ -f '$FAKE_HOME/.claude/knowledge/INDEX.md' ]"
check "code-best-practices.md deployed" "[ -f '$FAKE_HOME/.claude/knowledge/code-best-practices.md' ]"
check "knowledge matches repo" "diff -q '$REPO_ROOT/knowledge/INDEX.md' '$FAKE_HOME/.claude/knowledge/INDEX.md' >/dev/null 2>&1"

# --- Test 3: Skill sync ---
echo ""
echo "--- Test 3: Skill sync ---"
check "upstream skill deployed" "[ -f '$FAKE_HOME/.claude/skills/office-hours/SKILL.md' ]"
check "custom skill deployed" "[ -d '$FAKE_HOME/.claude/skills/home-inspect' ]"

# --- Test 4: Garbage collection ---
echo ""
echo "--- Test 4: Garbage collection ---"
# Create a fake skill not in catalog
mkdir -p "$FAKE_HOME/.claude/skills/fake-orphan"
echo "test" > "$FAKE_HOME/.claude/skills/fake-orphan/SKILL.md"
HOME="$FAKE_HOME" bash "$DEPLOY" >/dev/null 2>&1 || true
check "orphan skill removed" "[ ! -d '$FAKE_HOME/.claude/skills/fake-orphan' ]"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
