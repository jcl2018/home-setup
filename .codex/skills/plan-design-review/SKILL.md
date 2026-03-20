---
name: plan-design-review
description: Design-review pass on a plan. Use after office-hours or plan-eng-review when the user needs the actual user experience, interaction states, and visual intent specified before implementation.
---

# Plan Design Review

Use this before UI work so the plan describes what the user actually sees.

## Hard Gate

- Stay in design and planning.
- Do not implement code from this skill.
- Update the active design artifact instead of creating a competing plan.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Read the latest approved design or plan artifact in `designs/`. If none exists, recommend `office-hours` first.
3. Give the design an initial rating out of 10.
4. Review the design in passes:
   - information hierarchy
   - interaction and state coverage
   - user journey
   - AI-slop risk
   - design-system fit
   - responsive and accessibility coverage
   - unresolved design decisions
5. Fix obvious gaps directly in the design artifact and stop for real tradeoffs.
6. Update the same design artifact with concrete UI decisions and the revised rating.
7. Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark plan-design-review <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_REVISION`
- `BLOCKED`
8. If the review reveals that the visual system itself is under-specified, recommend `design-consultation` before implementation. After UI code lands, recommend `design-review` for rendered-state QA.

## Output

- A plan that covers the user-facing states
- Clear design constraints for implementation
- Updated plan details in `designs/`
- A clearer implementation target for UI work
- A readiness entry for `plan-design-review`
