---
paths:
  - "docs/design/PHILOSOPHY.md"
  - "docs/design/DECISIONS.md"
---
# Principle and Decision Changes

After editing PHILOSOPHY.md or DECISIONS.md:
1. Check that all cross-references between the two files are valid
2. Run bash scripts/gen-docs.sh to regenerate traceability.md
3. Run bash scripts/deploy.sh to deploy changes
4. Verify CLAUDE.md principles section still matches
