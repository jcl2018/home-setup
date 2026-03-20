---
name: design-consultation
description: Build or reset the visual system before implementation. Use when a feature needs a design language, design-system direction, or a more opinionated visual concept before code.
---

# Design Consultation

Use this when the user needs design direction, not implementation.

## Hard Gate

- Stay in design and planning.
- Do not implement code from this skill.
- Update the active design artifact instead of creating competing design notes unless no design artifact exists yet.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Read the latest design artifact in `designs/` when one exists. If none exists, create one with `~/.codex/bin/codex-project-log stamp designs design-consultation`.
3. Read the nearest `AGENTS.md` plus any existing design system, style guide, screenshots, Storybook docs, or product references that define the current visual language.
4. Determine the stance:
   - extend the current design system
   - sharpen a vague visual direction
   - invent a new visual system from scratch
5. Produce at least two viable directions:
   - one lower-risk direction that fits the current product
   - one bolder direction that would make the product feel more distinctive
6. For each direction, define:
   - core design thesis
   - typography direction
   - color and surface system
   - layout and spacing rules
   - motion and interaction tone
   - component or pattern implications
   - implementation risk
7. Recommend one direction and update the active design artifact with concrete design-system decisions:
   - visual principles
   - token guidance
   - component guidance
   - responsive and accessibility constraints
   - examples of what to avoid
8. Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark design-consultation <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_REVISION`
- `BLOCKED`
9. End by recommending the next stage:
   - `plan-design-review` if the design still needs interaction-state review
   - direct implementation if the design system is now concrete enough to build

## Output

- An updated design artifact in `designs/`
- A clear visual-system direction with concrete constraints
- A readiness entry for `design-consultation`
