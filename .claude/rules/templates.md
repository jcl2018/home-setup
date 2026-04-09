---
paths:
  - templates/**
---

# Templates Are Read-Only Source

Templates in `templates/` are the source of truth for document scaffolding.
They are deployed to `~/.claude/templates/` by `deploy.sh`.

- Do not modify templates without updating the GENERATION-GUIDE.md.
- After editing a template, run `bash scripts/deploy.sh` to deploy.
- /work-track reads templates during scaffolding. Template changes affect all future work items.
