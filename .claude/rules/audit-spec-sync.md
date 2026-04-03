---
paths:
  - "audit-spec.json"
---
# D8: Keep Audit Spec in Sync

After editing audit-spec.json:
1. Run bash scripts/validate-audit-spec.sh to verify coverage closure
2. Run bash scripts/gen-docs.sh to regenerate traceability.md
3. Update .claude/skills/home-inspect/SKILL.md if check descriptions changed
4. Update docs/operations/INSPECTION-BASELINE.md if baselines changed
