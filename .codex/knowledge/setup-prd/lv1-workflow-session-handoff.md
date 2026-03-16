# Lv1 Workflow Session Handoff PRD

## Purpose

Define the desired shape for durable handoff notes so unfinished work can resume quickly without bloated history.

## Desired State

- Home-control work keeps a required tracking doc at `~/.codex/.local-work/current.md`.
- Repo work keeps a required tracking doc at `.local-work/current.md` in the repo root.
- Handoffs stay short, operational, and easy to refresh.
- Handoffs capture current state, verification, next steps, blockers, and rollback notes.
- Resume flow starts with the root contract and then the required tracking doc.
- When work depends on repo-local `lv2` skills, the resume flow can also consult the repo-local `setup-prd/` index.
- Tracking docs are refreshed after material work-state changes and before pause, handoff, or session end.

## Audit Checklist

- Handoffs avoid long prose, full logs, and vague next steps.
- The required tracking doc exists for both home and repo work.
- The note records the exact verification already run.
- The resume instructions still match the repo’s current contract and knowledge root.

## Success Criteria

- Another session can resume the home or repo work with minimal rediscovery.
- The handoff complements repo-local PRDs instead of duplicating them.

## Out of Scope

- Permanent architecture or module documentation.
- Replacing repo-local PRDs, contracts, or code exploration.

## Related Sources

- `~/.codex/skills/lv1-workflow-session-handoff/SKILL.md`

## Last Checked

- 2026-03-15
