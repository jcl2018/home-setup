---
name: ship
description: Final release workflow. Use when the code is ready to land, a PR needs to be prepared, or release readiness needs to be checked.
---

# Ship

Use this after review and QA have cleared the branch.

## Default Behavior

Treat `ship` as an execution workflow, not a brainstorming workflow. Once the user asks to ship, move straight through unless a real blocker appears.

## Pre-Flight

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a ship artifact path with `~/.codex/bin/codex-project-log stamp ship ship`.
3. Check the current branch, diff summary, and readiness state.
4. If the branch is already the base branch or has no diff, stop early and say so.

## Readiness Inputs

Review the current readiness dashboard with:

`~/.codex/bin/codex-review-readiness dashboard`

At minimum, check whether `plan-eng-review`, `review`, and `qa` are already clear enough for the current diff, and whether any of those passes are stale relative to the current commit. If the change is materially user-facing, also inspect `plan-design-review` and `design-review`.

## Final Release Flow

1. Re-run the smallest relevant final verification.
2. Resolve or explicitly carry forward any remaining `NEEDS_FIX` or `DONE_WITH_CONCERNS` items.
3. Decide whether version, changelog, and docs need to move together.
4. Keep commits bisectable when separate logical changes are still mixed together.
5. If docs are stale, hand off into `document-release` before calling the release done.
6. If the ship is blocked mainly by missing rendered UI validation, recommend `design-review` or repo-native browser QA before retrying ship.

Use [references/ship-template.md](references/ship-template.md) as the artifact shape.

## Stop Conditions

Stop and surface the blocker when:

- the branch is not actually shippable
- tests fail
- release readiness is contradicted by new issues
- a major version or risky release decision needs user judgment

## Readiness

Record the final ship status with:

`~/.codex/bin/codex-review-readiness mark ship <status> --artifact <path>`

Suggested statuses:

- `READY`
- `BLOCKED`
- `DONE_WITH_CONCERNS`

## Workflow

1. Ensure the project store exists.
2. Create the ship artifact.
3. Review readiness.
4. Run the final release flow.
5. Record ship status.

## Output

- A ship artifact under `ship/`
- Final verification evidence
- A readiness entry for ship
