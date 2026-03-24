# Shared Knowledge Index

Shared knowledge files that should be deployed to `~/.claude/knowledge/` on every machine.
Machine-local domains (like `aedt/`) are declared in the machine's profile under
"Expected Local Content" and added to the installed INDEX.md on that machine only.

- Last checked: 2026-03-23

## Notes

- Use [code-best-practices.md](code-best-practices.md) for all code documentation conventions: commit messages, PR descriptions, inline comments, and function banners. Includes work item traceability (`S1432239:` format).
- Use [repo-item-tracking.md](repo-item-tracking.md) for per-repo `.local-work/` tracking conventions.
- Use [work-start-checklist.md](work-start-checklist.md) for the lightweight start-of-work checklist.
- Prefer explicit named-boolean guard comparisons when that is the local review preference, for example `clear == false` instead of `!clear`.

## Boundaries

- Keep this directory focused on reusable cross-machine knowledge.
- Machine-local domains (AEDT, etc.) are declared in profiles, not tracked here.
- Move repo-specific deep dives into the repo's local knowledge docs.
- If repo code or docs disagree with a summary here, the repo wins.
