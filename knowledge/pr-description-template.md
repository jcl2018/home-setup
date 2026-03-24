# PR Description Template

- Scope: reusable PR-description structure and writing guidance for substantive cross-repo code changes that will be reviewed or submitted.
- When to use this note: when preparing a PR description for a non-trivial code change and you want a clear, review-friendly summary that scales from moderate to complex work without becoming noisy.

## Summary

- Use one default PR template with optional sections that can be removed when they do not add value.
- Keep the PR description outcome-focused, behavior-focused, and reviewer-friendly.
- Assume some PR systems may impose a `4000` character limit; keep the first draft concise enough to trim quickly.
- Prefer plain language and short prompts that are easy to scan and easy to fill in.
- Prefer grouping by user-visible behavior, subsystem, or risk area instead of listing files.
- Start the PR body with the formal work item ID in bracketed form so the review stays traceable to the tracked task.
- Use the reviewer section to direct attention to non-obvious logic or risky flows.
- Use an `Affected Workflows` section to bridge behavior changes to the later test matrix.
- Use the test matrix to show what was checked, how, and the result in a compact format.

## Quick start

1. Start with the bracketed work item ID, for example `[S1432239]`.
2. Write `Summary` and `What Changed` in plain language.
3. If behavior or lifecycle changed, add `Affected Workflows`.
4. Reuse the same workflow names or labels in `Test Matrix`.
5. If the target field is capped, trim to the highest-signal sections first and keep the body within the limit.
6. Delete any section that does not add value for this PR.

## Lightweight version

Use this when the PR is real but still fairly small:

```md
[S1432239]

## Summary

Brief outcome of the change.

## What Changed

- Main behavior or implementation change.
- Any non-obvious detail that matters for review.

## Affected Workflows

- Workflow name: why it changed, important call path or state if relevant.

## Test Matrix

| Scenario | How verified | Result |
| --- | --- | --- |
| Same workflow name as above | Exact repro step, command, or manual check | Pass / Fail |
```

## Default template

Copy and adapt this:

```md
[S1432239]

## Summary

Briefly state the outcome of the change and the main behavior difference.

## Motivation / Context

Explain why this PR exists now, what problem it addresses, or what gap it closes.

## What Changed

- Group changes by behavior or subsystem, not by file.
- Call out any non-obvious implementation choice only if it matters for review.

## Affected Workflows

- One bullet per workflow or scenario.
- Keep each bullet short.
- Include only the details that help review:
  - what triggers the workflow
  - why it is affected
  - the main functions or call path involved when that context matters
  - any important state, cache, or flags updated, especially when scope matters such as per-view vs global
- Use the same workflow names or scenario labels again in the `Test Matrix`.

## Reviewer Focus

- Point reviewers to the riskiest logic, non-obvious control flow, or behavior changes.
- Call out areas where the output may look similar even though the implementation changed.

## Test Matrix

| Scenario | How verified | Result |
| --- | --- | --- |
| Example path | Exact command, repro steps, or manual check | Pass / Fail |

## User Impact

Include when the change alters user-visible behavior, workflows, or outputs.

## Breaking Changes / Migration

Include when callers, configs, schemas, or workflows must change.

## Screenshots / Logs

Include when visuals, terminal output, or logs make review faster.
```

## How to use it well

- `Summary`
  - State the outcome, not a restatement of the PR title.
- `Work item`
  - Put the tracked work item ID at the very top of the PR body in bracketed form, for example `[S1432239]`.
  - If the system has both a work item and a defect/task link, prefer the canonical work item ID and add the other references under `Linked Issues / Docs`.
- `Motivation / Context`
  - Explain the problem or trigger for the work so the reviewer does not need to reconstruct it from commits.
- `What Changed`
  - Group by behavior, subsystem, or responsibility boundary.
  - Avoid turning this into a file inventory unless file names are essential for orientation.
- `Reviewer Focus`
  - Use this to save reviewer time.
  - Point to risky branches, lifecycle changes, cache invalidation, ownership changes, migrations, or control-flow changes.
- `Affected Workflows`
  - Use this when the change touches product behavior, lifecycle paths, or non-trivial user flows.
  - Keep it behavior-oriented, not file-oriented.
  - Prefer one bullet per workflow or scenario.
  - Use the same names, order, or labels later in the `Test Matrix` so reviewers can see how each affected workflow was verified.
  - If a workflow entry gets long, split the detail between `Affected Workflows` and `Reviewer Focus` instead of making one giant bullet.
- `Test Matrix`
  - Show only executable verification scenarios, not review or hygiene checks.
  - Align rows with the workflows or scenarios listed in `Affected Workflows` when that section is present.
  - Each row should describe the setup or design used, the workflow or action performed, and the expected behavior or outcome.
  - Prefer rows like: create or open a specific design, run a concrete workflow step, verify a visible or runtime result.
  - Do not include source review, code inspection, branch hygiene, or bare commands such as `git diff --check` in the matrix.
  - If a check does not exercise product behavior or workflow behavior, mention it outside the matrix only if it still adds context.

## Trim for simple PRs

- For smaller but still reviewable changes, keep only:
  - `Work item`
  - `Summary`
  - `What Changed`
  - `Affected Workflows`
  - `Test Matrix`
- Omit optional sections when they would just say "none" or repeat obvious facts.
- Do not force a heavy PR description for a small, low-risk change.

## Length limits

- When a PR form has a strict limit, assume `4000` characters unless the user gives a different target.
- Preserve these sections first:
  - `Work item`
  - `Summary`
  - `What Changed`
  - `Affected Workflows`
  - `Test Matrix`
- Trim or merge these sections first when space is tight:
  - `Motivation / Context`
  - `Reviewer Focus`
  - `User Impact`
  - `Breaking Changes / Migration`
  - `Screenshots / Logs`
- Compress workflow bullets and test rows so they stay specific without repeating the same setup details.
- Do not leave placeholder text or empty optional sections in a size-constrained PR body.

## Accessibility tips

- Prefer short sentences over dense paragraphs.
- Prefer bullets over prose blocks when listing behaviors or workflows.
- Use the same workflow label in both `Affected Workflows` and `Test Matrix`.
- Remove any section that would only contain filler text.
- If a reviewer can understand the PR faster from a shorter version, choose the shorter version.
- Under a `4000` character cap, prefer the lightweight structure unless the missing detail would create review risk.

## Optional section guidance

- `User Impact`
  - Include when reviewers should understand the external behavior difference.
- `Risks / Rollout`
  - Include when there is meaningful regression risk, rollout ordering, or fallback logic.
- `Breaking Changes / Migration`
  - Include when downstream callers or users must change behavior.
- `Screenshots / Logs`
  - Include when visuals or logs materially reduce reviewer effort.
- `Known Gaps / Follow-ups`
  - Include when this PR intentionally does not finish the whole story.
- `Linked Issues / Docs`
  - Include when traceability or background context will help review.

## Anti-patterns

- Do not paste a file-by-file changelog as the main PR body.
- Do not repeat commit messages section by section.
- Do not leave every optional section present with placeholder text.
- Do not bury the work item ID only at the bottom of the PR or only in the title.
- Do not hide the risky part of the change inside a generic summary.
- Do not claim testing without naming the scenario or verification method.
- Do not use the test matrix for source review, static inspection, or "verified by reading code."
- Do not use the test matrix for repo hygiene checks such as `git diff --check`, branch cleanliness, or similar non-behavioral validation.
- Do not include vague rows like "manual testing" without naming the design/setup, the action taken, and the expected outcome.

## Source files or docs

- `C:\Users\chjiang\AGENTS.md`
- `C:\Users\chjiang\.codex\knowledge\INDEX.md`
- `C:\Users\chjiang\.codex\knowledge\code-change-comment-style.md`

## Last checked

- 2026-03-18
