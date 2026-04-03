---
paths:
  - "docs/**"
  - "README.md"
  - "CLAUDE.md"
---
# D9: No Hardcoded Counts

Never write a specific skill count in any documentation file.
Always reference skills-catalog.json as the source of truth.

BAD: "35 skills total (30 upstream + 5 custom)"
GOOD: "See skills-catalog.json for the current count"

Exception: CLAUDE.md header line may state the count for orientation,
but it must be updated whenever the catalog changes.
