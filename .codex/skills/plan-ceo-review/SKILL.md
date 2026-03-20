---
name: plan-ceo-review
description: Founder-mode plan review. Use after office-hours when the user wants the strongest product framing, better scope choices, and the most compelling version of the idea before implementation.
---

# Plan CEO Review

Use this to pressure-test the product framing and scope before implementation.

## Hard Gate

- Stay in design and planning.
- Do not implement code from this skill.
- Update the active design artifact instead of creating a competing plan.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Read the latest approved design or plan artifact in `designs/`. If none exists, recommend `office-hours` first.
3. Choose the review stance:
   - scope expansion
   - selective expansion
   - hold scope
   - scope reduction
4. Review one issue or opportunity at a time and stop for real product tradeoffs.
5. Challenge the job-to-be-done, the wedge, delight, ambition, and scope discipline.
6. Update the same design artifact with accepted scope decisions.
7. Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark plan-ceo-review <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_REVISION`
- `BLOCKED`
8. End by recommending whether the design is ready for `plan-eng-review`, `design-consultation`, or `plan-design-review`.

## Output

- A tighter or more ambitious plan
- Explicit scope decisions
- Clear product rationale for the next stage
- An updated design artifact in `designs/`
- A readiness entry for `plan-ceo-review`
