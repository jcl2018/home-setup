# Commit Message Template

- Scope: reusable commit-message structure and subject-line guidance for tracked code changes that should remain easy to trace back to a work item.
- When to use this note: when writing a commit message for a substantive local change and you want a consistent, review-friendly subject that carries the tracked work item ID.

## Summary

- Start the commit subject with the tracked work item ID, followed by a colon and a concise imperative summary.
- Use the form `S1432239: fix array instancing after save` as the default pattern.
- Keep the subject focused on the outcome or behavioral fix, not on file names.
- Add a commit body only when extra context materially helps future readers.

## Default template

Copy and adapt this:

```text
S1432239: fix array instancing after save
```

## Optional body template

Include a body when the change is non-obvious, risky, or bundles multiple related updates:

```text
S1432239: fix array instancing after save

- Rebuild optimized instance renderers after invalidation.
- Keep repeated owner show paths from rebuilding valid per-view state.
- Preserve save/synchronize recovery when the owner drawing is already visible.
```

## How to use it well

- `Work item`
  - Put the canonical tracked work item ID first, for example `S1432239: ...`.
  - Use the same work item ID format across commit subjects, PR bodies, and non-trivial code comments.
- `Subject`
  - Keep it short, imperative, and behavior-focused.
  - Prefer "fix", "update", "avoid", "add", or "refactor" phrasing over vague wording.
  - Avoid turning the subject into a file list.
- `Body`
  - Add one only when it improves future traceability.
  - Use it to explain the why, the risky path, or the grouped changes, not to restate the diff line by line.

## Trim for simple commits

- For a straightforward, single-purpose change, the subject line alone is enough.
- Do not force a body for tiny commits that are already clear from the subject.

## Anti-patterns

- Do not omit the work item ID from the subject for tracked work.
- Do not bury the work item ID only in the body.
- Do not use a generic subject like `S1432239: updates`.
- Do not list touched files in the subject.
- Do not write a long prose paragraph when a short imperative summary is enough.

## Source files or docs

- `C:\Users\chjiang\AGENTS.md`
- `C:\Users\chjiang\.codex\knowledge\code-change-comment-style.md`
- `C:\Users\chjiang\.codex\knowledge\pr-description-template.md`

## Last checked

- 2026-03-17
