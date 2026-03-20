---
name: design-review
description: Audit rendered UI and optionally fix obvious visual issues. Use when UI work needs visual QA, layout polish, state coverage review, or design-system cleanup after implementation.
---

# Design Review

Use this after implementation when the user wants the actual rendered experience reviewed.

## Modes

- report-only: default when the user asks for review
- fix-first: when the user asks for cleanup or when design review is part of a release workflow

## Setup

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a review artifact path with `~/.codex/bin/codex-project-log stamp reviews design-review`.
3. Prefer rendered evidence over static code inspection:
   - repo-native browser tooling such as Playwright, Storybook, Cypress, or screenshot commands
   - existing screenshots or mockups in the repo
   - user-provided local images
4. If rendered evidence is unavailable, say so explicitly and fall back to a code-level visual risk review instead of pretending you performed visual QA.

## Review Passes

Audit in passes:

- information hierarchy and focal point
- spacing, rhythm, and density
- typography, contrast, and readability
- interaction states, empty states, and error states
- design-system fit and consistency
- responsiveness and accessibility
- AI-slop risk: generic patterns, weak visual intent, or low-distinction styling

## Fix Loop

When running in `fix-first` mode:

1. Fix the obvious low-risk issues directly.
2. Re-run the narrowest relevant visual or browser checks.
3. Call out any remaining tradeoffs that need user judgment.

## Readiness

Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark design-review <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_FIX`
- `BLOCKED`

## Output

- A design-review artifact under `reviews/`
- A clear list of visual issues, fixes, and residual risks
- A readiness entry for `design-review`
