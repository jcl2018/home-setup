# Shared Knowledge Index

Shared knowledge files that should be deployed to `~/.claude/knowledge/` on every machine.
Machine-local domains (like `aedt/`) are declared in the machine's profile under
"Expected Local Content" and added to the installed INDEX.md on that machine only.

- Last checked: 2026-03-23

## Notes

- Use [code-change-comment-style.md](code-change-comment-style.md) for explanatory comment patterns on non-trivial code changes involving lifecycle, cache, ownership, or non-obvious call flow.
- Prefer explicit named-boolean guard comparisons in shared style guidance when that is the local review preference, for example `clear == false` instead of `!clear`.
- Use [function-comment-style.md](function-comment-style.md) for function header or banner comment conventions in codebases that already expect them, with C++-first examples.
- Use [commit-message-template.md](commit-message-template.md) for tracked commit-subject guidance that starts with the work item ID in `S1432239: ...` form.
- Use [pr-description-template.md](pr-description-template.md) whenever a task mentions a PR, pull request, PR description, or PR template, and for reusable reviewer-focused PR body guidance.
- Use [work-start-checklist.md](work-start-checklist.md) for the work-start checklist.

## Templates

- Use [pr-description-template.md](pr-description-template.md) for reusable PR body structure, including capped PR-form guidance.
- Use [commit-message-template.md](commit-message-template.md) for tracked commit-subject structure with the work item ID prefix.

## Boundaries

- Keep this directory focused on reusable cross-machine knowledge.
- Machine-local domains (AEDT, etc.) are declared in profiles, not tracked here.
- Move repo-specific deep dives into the repo's local knowledge docs.
- If repo code or docs disagree with a summary here, the repo wins.
