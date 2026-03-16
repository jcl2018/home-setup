# Lv1 Workflow Repo Bootstrap PRD

## Purpose

Define the minimum reliable setup a repo bootstrap should leave behind for future Codex work, including the repo-local PRD convention when `lv2` skills exist.

## Desired State

- The repo ends with a real verification path that has been run.
- The repo has a short local contract when one is needed.
- Every repo has a gitignored `.local-work/current.md` tracking doc from the start.
- Durable repo-local knowledge lives under a single repo knowledge root.
- When the repo introduces `lv2` skills, it also introduces `<repo-knowledge-root>/setup-prd/` with matching PRDs.
- The tracking doc is read after the repo `AGENTS.md` and refreshed after material work-state changes.

## Audit Checklist

- Bootstrap always creates the required tracking doc and chooses the smallest other docs instead of creating templates by default.
- The repo knowledge root is named clearly when durable notes or `lv2` skills exist.
- `lv2` skill creation is paired with repo-local PRDs rather than home-level notes.
- Verification ran at least once before claiming the bootstrap is complete.

## Success Criteria

- Future sessions can enter the repo, find the contract, run the right checks, and locate durable notes quickly.
- Repos with `lv2` skills inherit the same PRD discipline as the home control layer.

## Out of Scope

- Over-documenting simple repos beyond the required local contract and tracking doc.
- Forcing repo-local knowledge trees when the repo is trivial and has no reusable workflow contract to store.

## Related Sources

- `~/.codex/skills/lv1-workflow-repo-bootstrap/SKILL.md`
- `~/.codex/skills/lv1-workflow-project-contract/SKILL.md`

## Last Checked

- 2026-03-15
