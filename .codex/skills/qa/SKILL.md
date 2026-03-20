---
name: qa
description: Test, fix, and re-verify. Use when a feature or branch needs repo-native QA with follow-up fixes.
---

# QA

Use this when the user wants bugs found and fixed, not just reported.

## Modes

- diff-aware: default when on a feature branch and no explicit URL or scope is given
- full-app: when the user gives a URL, page, or app area
- regression: compare against a prior QA artifact or baseline

## Tiers

- quick: critical and high only
- standard: plus medium
- exhaustive: include low and cosmetic issues

## Setup

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a QA artifact path with `~/.codex/bin/codex-project-log stamp qa qa`.
3. Prefer repo-native browser or test tooling first.
4. If the working tree is dirty and QA will likely write fixes, preserve or isolate unrelated work before starting.

Use [references/qa-report-template.md](references/qa-report-template.md) as the report shape.

## Test -> Fix -> Verify Loop

1. Build a test matrix for the targeted surface:
   - happy path
   - loading, empty, and error states
   - permission and boundary cases
   - adjacent regression risk
2. Triage issues by severity.
3. Fix the issues that are in scope for the chosen tier.
4. Add regression tests when the repo has a suitable test surface and the fix is durable enough to encode.
5. Re-run the focused checks after each meaningful fix group.

## Output Discipline

Capture:

- what was tested
- what failed
- what was fixed
- what still remains
- what verification actually ran

## Readiness

Record a readiness status with:

`~/.codex/bin/codex-review-readiness mark qa <status> --artifact <path>`

Suggested statuses:

- `CLEAR`
- `DONE_WITH_CONCERNS`
- `BLOCKED`

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create the QA artifact.
3. Choose mode and tier.
4. Run the test -> fix -> verify loop.
5. Record readiness.

## Output

- A QA artifact under `qa/`
- Verified fixes or a clear blockers list
- A readiness entry for QA
