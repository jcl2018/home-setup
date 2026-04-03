#!/usr/bin/env bash
# test-audit-spec.sh — Automated tests for validate-audit-spec.sh
# Creates temp spec files and verifies the validator catches each error type.

set -euo pipefail

VALIDATOR="$(dirname "$0")/validate-audit-spec.sh"
TMPDIR=$(mktemp -d)
PASS=0
FAIL=0

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

expect_pass() {
  local name="$1" file="$2"
  if bash "$VALIDATOR" "$file" >/dev/null 2>&1; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name (expected pass, got fail)" >&2
    FAIL=$((FAIL + 1))
  fi
}

expect_fail() {
  local name="$1" file="$2" pattern="${3:-}"
  local output
  if output=$(bash "$VALIDATOR" "$file" 2>&1); then
    echo "  FAIL: $name (expected fail, got pass)" >&2
    FAIL=$((FAIL + 1))
  else
    if [ -n "$pattern" ] && ! echo "$output" | grep -qi "$pattern"; then
      echo "  FAIL: $name (failed but missing expected message '$pattern')" >&2
      FAIL=$((FAIL + 1))
    else
      echo "  PASS: $name"
      PASS=$((PASS + 1))
    fi
  fi
}

echo "=== validate-audit-spec.sh test suite ==="

# Test 1: Valid spec passes
cat > "$TMPDIR/valid.json" << 'EOF'
{
  "goals": [{"id":"AG1","name":"Test","description":"Test","informed_by":[],"type":"check-level"}],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"Test","goals":["AG1"],"why":"Test reason","baseline":"ok","fix":"fix it"}]
}
EOF
expect_pass "valid spec" "$TMPDIR/valid.json"

# Test 2: Missing file fails
expect_fail "missing file" "$TMPDIR/nonexistent.json" "not found"

# Test 3: Malformed JSON fails
echo "not json{" > "$TMPDIR/bad.json"
expect_fail "malformed JSON" "$TMPDIR/bad.json" "not valid JSON"

# Test 4: Empty goals array fails
cat > "$TMPDIR/empty-goals.json" << 'EOF'
{"goals":[],"checks":[{"id":"1.1","engine":"health","room":1,"title":"T","goals":["AG1"],"why":"w","baseline":"b","fix":"f"}]}
EOF
expect_fail "empty goals" "$TMPDIR/empty-goals.json" "goals array is empty"

# Test 5: Empty checks array fails
cat > "$TMPDIR/empty-checks.json" << 'EOF'
{"goals":[{"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"}],"checks":[]}
EOF
expect_fail "empty checks" "$TMPDIR/empty-checks.json" "checks array is empty"

# Test 6: Check with no goals fails
cat > "$TMPDIR/no-goals.json" << 'EOF'
{
  "goals": [{"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"}],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"T","goals":[],"why":"w","baseline":"b","fix":"f"}]
}
EOF
expect_fail "check with no goals" "$TMPDIR/no-goals.json" "has no goals"

# Test 7: Non-meta goal with no checks fails
cat > "$TMPDIR/uncovered-goal.json" << 'EOF'
{
  "goals": [
    {"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"},
    {"id":"AG2","name":"T2","description":"T2","informed_by":[],"type":"check-level"}
  ],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"T","goals":["AG1"],"why":"w","baseline":"b","fix":"f"}]
}
EOF
expect_fail "uncovered non-meta goal" "$TMPDIR/uncovered-goal.json" "has no checks"

# Test 8: Meta goal with no checks passes
cat > "$TMPDIR/meta-ok.json" << 'EOF'
{
  "goals": [
    {"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"},
    {"id":"AG8","name":"Meta","description":"Meta","informed_by":[],"type":"meta"}
  ],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"T","goals":["AG1"],"why":"w","baseline":"b","fix":"f"}]
}
EOF
expect_pass "meta goal with no checks" "$TMPDIR/meta-ok.json"

# Test 9: Unknown goal ID in check fails
cat > "$TMPDIR/unknown-goal.json" << 'EOF'
{
  "goals": [{"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"}],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"T","goals":["AG99"],"why":"w","baseline":"b","fix":"f"}]
}
EOF
expect_fail "unknown goal ID" "$TMPDIR/unknown-goal.json" "unknown goal"

# Test 10: Duplicate check ID fails
cat > "$TMPDIR/dupe-id.json" << 'EOF'
{
  "goals": [{"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"}],
  "checks": [
    {"id":"1.1","engine":"health","room":1,"title":"T1","goals":["AG1"],"why":"w","baseline":"b","fix":"f"},
    {"id":"1.1","engine":"health","room":1,"title":"T2","goals":["AG1"],"why":"w","baseline":"b","fix":"f"}
  ]
}
EOF
expect_fail "duplicate check ID" "$TMPDIR/dupe-id.json" "duplicate"

# Test 11: Empty why field fails
cat > "$TMPDIR/empty-why.json" << 'EOF'
{
  "goals": [{"id":"AG1","name":"T","description":"T","informed_by":[],"type":"check-level"}],
  "checks": [{"id":"1.1","engine":"health","room":1,"title":"T","goals":["AG1"],"why":"","baseline":"b","fix":"f"}]
}
EOF
expect_fail "empty why field" "$TMPDIR/empty-why.json" "empty 'why'"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
