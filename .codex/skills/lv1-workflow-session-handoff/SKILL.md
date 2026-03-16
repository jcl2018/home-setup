---
name: lv1-workflow-session-handoff
description: Use when creating or refreshing the required tracking doc for home, repo, or umbrella-root work.
---

# Session Handoff

Use this to create or refresh the required tracking doc for home, repo, or umbrella-root work, especially when work is underway, the user wants a clean resume point, or the session needs a short durable handoff.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv1-workflow-session-handoff.md](../../knowledge/setup-prd/lv1-workflow-session-handoff.md).

## Paths And Refresh Rules

- For home-control work, use `~/.codex/.local-work/current.md`.
- For repo work, use `.local-work/current.md` in the repo root.
- For umbrella-root work, use `.local-work/current.md` in the umbrella root. Child repos keep their own tracking docs.
- Create the relevant tracking doc before substantive edits if it is missing.
- Read it immediately after the root `AGENTS.md` for that scope.
- Refresh it after material changes to goal, plan, constraints, files touched, verification, blockers, or next steps.
- Always refresh it before pausing, compacting, handing off, or ending the session.

## What to capture

Keep the handoff short and operational. Use these sections:

1. Last updated
2. Goal
3. Current state
4. Decisions / constraints
5. Files touched
6. Verification
7. Next steps
8. Blockers / risks
9. Rollback notes

## What to avoid

- Long prose history
- Full tool logs
- Repeating facts already obvious from the code
- Vague next steps like "continue working"

## Resume workflow

When resuming home-control work:

1. Read `~/AGENTS.md`.
2. Read `~/.codex/.local-work/current.md`.
3. Read the smallest relevant home PRDs under `~/.codex/knowledge/setup-prd/`.
4. Verify the home setup still matches the recorded state.
5. Re-run any stale verification before building on top of it.

When resuming repo work:

1. Read the nearest `AGENTS.md`.
2. Read `.local-work/current.md`.
3. Read `<repo-knowledge-root>/setup-prd/INDEX.md` when the work depends on repo-local `lv2` skills or workflow contracts and that index exists.
4. Verify the repo still matches the recorded state.
5. Re-run any stale verification before building on top of it.

When resuming umbrella-root work:

1. Read the umbrella root `AGENTS.md`.
2. Read the umbrella root `.local-work/current.md`.
3. If the root declares `Child Repos`, traverse only the listed child paths.
4. When work moves into a child repo, resume inside that child repo using its own `AGENTS.md`, `.local-work/current.md`, and repo-local PRDs when applicable.
5. Re-run any stale verification at the umbrella or child-repo scope before building on top of it.
