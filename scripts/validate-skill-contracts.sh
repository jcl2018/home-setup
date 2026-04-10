#!/usr/bin/env bash
# validate-skill-contracts.sh — Validates skill-contracts.json schema + coverage
# Exit 0 on success, 1 on validation failure, 2 on parse error

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACTS="$REPO_ROOT/skill-contracts.json"
CATALOG="$REPO_ROOT/skills-catalog.json"

errors=0

# --- Parse check ---
if ! jq empty "$CONTRACTS" 2>/dev/null; then
  echo "ERROR: skill-contracts.json is not valid JSON"
  exit 2
fi

if ! jq empty "$CATALOG" 2>/dev/null; then
  echo "ERROR: skills-catalog.json is not valid JSON"
  exit 2
fi

echo "=== Skill Contracts Validation ==="
echo ""

# --- Schema check: required fields per contract ---
echo "--- Schema Checks ---"
contract_count=$(jq '.contracts | length' "$CONTRACTS")

for i in $(seq 0 $((contract_count - 1))); do
  skill=$(jq -r ".contracts[$i].skill" "$CONTRACTS")

  for field in skill source job must_produce must_not_do handoff inputs allowed_side_effects eval_mode; do
    val=$(jq -r ".contracts[$i].$field // empty" "$CONTRACTS")
    if [ -z "$val" ]; then
      echo "FAIL: Contract '$skill' missing required field: $field"
      errors=$((errors + 1))
    fi
  done

  # Check must_produce is non-empty array
  produce_count=$(jq ".contracts[$i].must_produce | length" "$CONTRACTS")
  if [ "$produce_count" -eq 0 ]; then
    echo "FAIL: Contract '$skill' has empty must_produce array"
    errors=$((errors + 1))
  fi

  # Check eval_mode is valid
  eval_mode=$(jq -r ".contracts[$i].eval_mode" "$CONTRACTS")
  case "$eval_mode" in
    structural|behavioral|both) ;;
    *) echo "FAIL: Contract '$skill' has invalid eval_mode: $eval_mode (must be structural, behavioral, or both)"
       errors=$((errors + 1)) ;;
  esac
done

if [ $errors -eq 0 ]; then
  echo "PASS: All $contract_count contracts have valid schema"
fi

echo ""

# --- Coverage check: non-upstream skills should have contracts ---
echo "--- Coverage Checks ---"
custom_skills=$(jq -r '.skills[] | select(.source != "gstack" and .source != "waza") | select(.status != "removed") | .name' "$CATALOG" | sort)
contracted_skills=$(jq -r '.contracts[] | select(.source != "gstack" and .source != "waza") | .skill' "$CONTRACTS" | sort)

missing=0
while IFS= read -r skill; do
  if ! echo "$contracted_skills" | grep -q "^${skill}$"; then
    echo "WARN: Custom skill '$skill' has no contract in skill-contracts.json"
    missing=$((missing + 1))
  fi
done <<< "$custom_skills"

if [ $missing -eq 0 ]; then
  echo "PASS: All custom skills have contracts"
else
  echo "WARN: $missing custom skill(s) without contracts"
fi

echo ""

# --- Orphan check: contracts for skills not in catalog ---
echo "--- Orphan Checks ---"
catalog_skills=$(jq -r '.skills[].name' "$CATALOG" | sort)
orphans=0

for i in $(seq 0 $((contract_count - 1))); do
  skill=$(jq -r ".contracts[$i].skill" "$CONTRACTS")
  if ! echo "$catalog_skills" | grep -q "^${skill}$"; then
    echo "WARN: Contract for '$skill' but skill not found in catalog"
    orphans=$((orphans + 1))
  fi
done

if [ $orphans -eq 0 ]; then
  echo "PASS: No orphan contracts"
fi

echo ""
echo "=== Summary ==="
echo "Contracts: $contract_count"
echo "Errors: $errors"
echo "Warnings: $((missing + orphans))"

if [ $errors -gt 0 ]; then
  exit 1
fi

exit 0
