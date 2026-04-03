---
paths:
  - "skills-catalog.json"
---
# P1: Catalog Changes

The skills catalog is the source of truth for what skills exist (P1).
After editing skills-catalog.json:
1. Run bash scripts/gen-docs.sh to regenerate skills-reference.md
2. Update docs/operations/SKILLS-CHEATSHEET.md if skill commands changed
3. Update CLAUDE.md layout tree if custom skills were added/removed
4. Run bash scripts/deploy.sh to deploy
