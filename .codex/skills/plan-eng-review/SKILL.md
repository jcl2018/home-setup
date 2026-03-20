---
name: plan-eng-review
description: Engineering-manager plan review. Use after office-hours or plan-ceo-review when the user wants architecture, failure modes, edge cases, diagrams, and tests locked in before coding.
---

# Plan Eng Review

Use this to make a plan buildable.

## Hard Gate

- Stay in design and planning.
- Do not implement code from this skill.
- Update the active design artifact instead of creating a competing plan.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Read the latest approved design or plan artifact in `designs/`. If none exists, recommend `office-hours` first.
3. Start with a scope challenge:
   - what existing code or workflows can be reused
   - what can be cut
   - whether the plan is boiling a lake or inventing an ocean
4. Review the design in sections:
   - architecture and boundaries
   - data and state flow
   - failure modes and reversibility
   - test coverage and verification
   - rollout or readiness concerns
5. Prefer ASCII diagrams when they remove ambiguity.
6. Review one real tradeoff at a time and stop when the user needs to choose.
7. Update the same design artifact with accepted engineering decisions.
8. Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark plan-eng-review <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_REVISION`
- `BLOCKED`
9. End by recommending whether the design is ready for `plan-design-review`, `design-consultation`, or direct implementation.

## Output

- A technically buildable plan
- Clear test and failure-mode coverage
- Updated plan details in `designs/`
- A clear recommendation for the next stage
- A readiness entry for `plan-eng-review`
