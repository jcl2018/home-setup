# /project:audit — Unified Audit

Run doc triplet enforcement and smoke tests on all families, plus contract validation:

1. Run `bash scripts/validate-skill-contracts.sh` (contract schema + coverage)
2. Run `/test-align-contract` (Tier 1 smoke tests on all doc triplets under docs/)
3. For each triplet family found, run `/align-feature-contract` (template alignment + cross-doc traceability + reference verification)
4. Verify deploy state: `bash scripts/deploy.sh --dry-run` and check for drift
5. Save a timestamped snapshot to `docs/inspections/audit-YYYY-MM-DD-HHMMSS.md`

## Output format

```
=== UNIFIED AUDIT ===
Date: YYYY-MM-DD HH:MM:SS
Commit: <short hash>

--- Contract Validation ---
<validate-skill-contracts.sh output>

--- Doc Triplet Smoke Tests (Tier 1) ---
<test-align-contract results per family>

--- Doc Triplet Alignment (per family) ---
<align-feature-contract L1/L2/L3 results per family>

--- Deploy State ---
<drift check results>

--- Summary ---
Contracts:  X errors, Y warnings
Smoke:      X pass, Y fail of Z families
Alignment:  X pass, Y warn, Z fail across N families
Deploy:     zero drift / N files drifted
```

After the audit, remind the user to commit the snapshot.
