---
name: review
description: Pre-landing diff review. Use when the user asks for code review, PR review, or a structural check before shipping.
---

# Review

Use this to review the current diff against the repo's base branch.

## Hard Gate

- Findings come first.
- Default to report-only review.
- Only fix mechanical issues during review when the user explicitly asks for fixes or when the review is part of a release workflow.

## Step 0: Detect The Base Branch

Use the repo's PR target if it exists, otherwise the repo default branch, otherwise `main`.

All diff and log commands should compare against that base.

## Step 1: Scope Drift Detection

Before judging code quality, ask:

1. what the branch was supposed to do
2. what the diff actually does
3. whether there is scope creep
4. whether any obvious requirement is still missing

Write a short scope check at the top of the artifact.

## Step 2: Two-Pass Review

Review in two passes.

### Pass 1: Critical

- data safety
- concurrency and state risks
- trust-boundary mistakes
- missing enum or edge-case completeness
- irreversible side effects

### Pass 2: Informational

- tests and verification gaps
- magic coupling or dead code
- prompt or UX issues when relevant
- documentation or TODO drift

Use [references/review-template.md](references/review-template.md) as the artifact shape.

## Step 3: Fix-First Option

If the user wants a fix-first review or the review is running as part of `ship`:

1. classify issues into `AUTO-FIX` or `ASK`
2. auto-fix only low-risk mechanical items
3. batch the real judgment calls back to the user
4. re-run any now-stale verification after fixes land

If the user asked only for review, stay report-only.

## Step 4: Readiness

If the diff includes meaningful user-facing UI changes, call out whether `design-review` would add value before shipping.

Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark review <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `NEEDS_FIX`
- `BLOCKED`

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a review artifact path with `~/.codex/bin/codex-project-log stamp reviews review`.
3. Run scope drift detection.
4. Run the two-pass review.
5. Optionally run the fix-first loop when appropriate.
6. Record readiness.

## Output

- A review note under `reviews/`
- A readiness entry in `reviews/review-readiness.jsonl`
