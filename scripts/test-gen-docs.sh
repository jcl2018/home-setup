#!/usr/bin/env bash
# test-gen-docs.sh — Tests for gen-docs.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

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

echo "=== test-gen-docs.sh ==="

# Test 1: gen-docs.sh generates both files
echo ""
echo "--- Test 1: Generation ---"
bash "$REPO_ROOT/scripts/gen-docs.sh" >/dev/null 2>&1
check "traceability.md exists" "[ -f '$REPO_ROOT/docs/design/traceability.md' ]"
check "skills-reference.md exists" "[ -f '$REPO_ROOT/docs/operations/skills-reference.md' ]"

# Test 2: Generated files have content
echo ""
echo "--- Test 2: Content ---"
check "traceability.md non-empty" "[ -s '$REPO_ROOT/docs/design/traceability.md' ]"
check "skills-reference.md non-empty" "[ -s '$REPO_ROOT/docs/operations/skills-reference.md' ]"
check "traceability has Mermaid" "grep -q 'mermaid' '$REPO_ROOT/docs/design/traceability.md'"
check "skills-reference has table" "grep -q '| Skill |' '$REPO_ROOT/docs/operations/skills-reference.md'"

# Test 3: --check mode passes when up to date
echo ""
echo "--- Test 3: Check mode (up to date) ---"
check "--check passes" "bash '$REPO_ROOT/scripts/gen-docs.sh' --check >/dev/null 2>&1"

# Test 4: --check mode fails when stale
echo ""
echo "--- Test 4: Check mode (stale) ---"
echo "stale" >> "$REPO_ROOT/docs/design/traceability.md"
if bash "$REPO_ROOT/scripts/gen-docs.sh" --check >/dev/null 2>&1; then
  echo "  FAIL: --check should fail on stale file" >&2
  FAIL=$((FAIL + 1))
else
  echo "  PASS: --check detects stale file"
  PASS=$((PASS + 1))
fi
# Restore
bash "$REPO_ROOT/scripts/gen-docs.sh" >/dev/null 2>&1

# Test 5: Idempotent
echo ""
echo "--- Test 5: Idempotent ---"
bash "$REPO_ROOT/scripts/gen-docs.sh" >/dev/null 2>&1
check "idempotent (--check still passes)" "bash '$REPO_ROOT/scripts/gen-docs.sh' --check >/dev/null 2>&1"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
