# Lv0 Home Global Knowledge Capture PRD

## Purpose

Define how cross-repo knowledge is captured in home knowledge without polluting the PRD contract area or repo-local docs.

## Desired State

- Global knowledge is saved only when it is stable across multiple repos or repeated enough to justify caching.
- Notes are stored under `~/.codex/knowledge/` in the smallest fitting file outside `setup-prd/`.
- `~/.codex/knowledge/setup-prd/` is reserved for home and workflow PRDs, not general cross-repo notes.
- Notes include sources and a `last checked` date.
- Repo-specific deep dives stay in the repo’s knowledge root instead of home knowledge.

## Audit Checklist

- New notes do not duplicate repo-local implementation detail.
- Existing global notes stay concise and navigable.
- PRDs and normal cross-repo notes are separated cleanly.
- The note shape stays lightweight and source-linked.

## Success Criteria

- Future sessions can reuse cross-repo knowledge without inflating always-loaded context.
- The PRD subtree remains focused on contracts instead of absorbing general notes.

## Out of Scope

- Saving repo-specific deep dives in home knowledge.
- Treating global notes as canonical when repo code or repo docs disagree.

## Related Sources

- `~/.codex/skills/lv0-home-global-knowledge-capture/SKILL.md`
- `~/.codex/knowledge/INDEX.md`

## Last Checked

- 2026-03-15
