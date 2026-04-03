#!/usr/bin/env bash
# validate-audit-spec.sh — Validates audit-spec.json for goal coverage closure.
# Exit 0 if valid, exit 1 with specific errors if not.
# Requires: jq

set -euo pipefail

SPEC="${1:-audit-spec.json}"
ERRORS=0

# Check jq availability
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed." >&2
  exit 1
fi

# Check spec file exists
if [ ! -f "$SPEC" ]; then
  echo "ERROR: $SPEC not found." >&2
  exit 1
fi

# Check valid JSON
if ! jq empty "$SPEC" 2>/dev/null; then
  echo "ERROR: $SPEC is not valid JSON." >&2
  exit 1
fi

# Check non-empty goals array
GOAL_COUNT=$(jq '.goals | length' "$SPEC")
if [ "$GOAL_COUNT" -eq 0 ]; then
  echo "ERROR: goals array is empty." >&2
  ERRORS=$((ERRORS + 1))
fi

# Check non-empty checks array
CHECK_COUNT=$(jq '.checks | length' "$SPEC")
if [ "$CHECK_COUNT" -eq 0 ]; then
  echo "ERROR: checks array is empty." >&2
  ERRORS=$((ERRORS + 1))
fi

# Collect all goal IDs (tr -d '\r' for Windows compatibility)
GOAL_IDS=$(jq -r '.goals[].id' "$SPEC" | tr -d '\r')

# Check: every check has at least one goal
while IFS= read -r line; do
  id=$(echo "$line" | jq -r '.id')
  goal_count=$(echo "$line" | jq '.goals | length')
  if [ "$goal_count" -eq 0 ]; then
    echo "ERROR: check '$id' has no goals." >&2
    ERRORS=$((ERRORS + 1))
  fi
done < <(jq -c '.checks[]' "$SPEC")

# Check: every non-meta goal has at least one check
while IFS= read -r line; do
  gid=$(echo "$line" | jq -r '.id')
  gtype=$(echo "$line" | jq -r '.type')
  if [ "$gtype" = "meta" ]; then
    continue
  fi
  match=$(jq --arg gid "$gid" '[.checks[] | select(.goals[] == $gid)] | length' "$SPEC")
  if [ "$match" -eq 0 ]; then
    echo "ERROR: goal '$gid' ($gtype) has no checks." >&2
    ERRORS=$((ERRORS + 1))
  fi
done < <(jq -c '.goals[]' "$SPEC")

# Check: all goal IDs referenced in checks exist in goals array
while IFS= read -r line; do
  cid=$(echo "$line" | jq -r '.id')
  for ref_goal in $(echo "$line" | jq -r '.goals[]' | tr -d '\r'); do
    if ! echo "$GOAL_IDS" | grep -qx "$ref_goal"; then
      echo "ERROR: check '$cid' references unknown goal '$ref_goal'." >&2
      ERRORS=$((ERRORS + 1))
    fi
  done
done < <(jq -c '.checks[]' "$SPEC")

# Check: all check IDs are unique
DUPES=$(jq -r '.checks[].id' "$SPEC" | sort | uniq -d)
if [ -n "$DUPES" ]; then
  echo "ERROR: duplicate check IDs: $DUPES" >&2
  ERRORS=$((ERRORS + 1))
fi

# Check: no empty why fields
while IFS= read -r line; do
  cid=$(echo "$line" | jq -r '.id')
  why=$(echo "$line" | jq -r '.why')
  if [ -z "$why" ] || [ "$why" = "null" ]; then
    echo "ERROR: check '$cid' has empty 'why' field." >&2
    ERRORS=$((ERRORS + 1))
  fi
done < <(jq -c '.checks[]' "$SPEC")

# Summary
if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: $ERRORS error(s) found in $SPEC." >&2
  exit 1
else
  echo "PASSED: $SPEC is valid. $GOAL_COUNT goals, $CHECK_COUNT checks, all mappings consistent."
  exit 0
fi
