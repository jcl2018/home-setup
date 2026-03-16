---
name: lv1-workflow-session-handoff
description: Use when writing handoff notes for unfinished coding work.
---

# Session Handoff

Use this when work is unfinished, the user wants a clean resume point, or the session is long enough that the next pass will benefit from a short written handoff.

## Default path

- Prefer `.local-work/current.md` in the repo root.
- If the repo already has `.local-work/current.md`, update it.

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

When resuming from a handoff:

1. Read the nearest `AGENTS.md` first.
2. Read `.local-work/current.md` if it exists.
3. Verify the repo still matches the recorded state.
4. Re-run any stale verification before building on top of it.
