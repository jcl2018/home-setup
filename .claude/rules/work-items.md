---
paths:
  - work-items/**
---

# Work Item Files

Work items live at `./work-items/` relative to each project repo.
They are created by /work-track and managed by the work-* skill family.

- Work items are mutable: phase skills update trackers, journals, and handoff blocks.
- Each work item directory contains: TRACKER.md + type-specific artifacts (PRD.md, RCA.md, etc.).
- Never manually edit handoff blocks (`<!-- HANDOFF: ... -->`). Phase skills manage these.
- Journal entries should reference commit SHAs when documenting implementation progress.
