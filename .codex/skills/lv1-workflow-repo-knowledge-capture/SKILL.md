---
name: lv1-workflow-repo-knowledge-capture
description: Use when Codex should add or update repo knowledge for the current repository. Save concise deep-dive notes inside the repo's chosen knowledge root, defaulting to `docs/ai/knowledge/` only when the repo does not define another location, and link back to canonical repo files and docs.
---

# Repo Knowledge Capture

Use this skill when the user wants to save or refresh deep knowledge for the current repo, especially for a module, subsystem, flow, or hotspot that takes time to rediscover.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv1-workflow-repo-knowledge-capture.md](../../knowledge/setup-prd/lv1-workflow-repo-knowledge-capture.md).

## Workflow

1. Identify the current repo and choose a single repo knowledge root. Read the nearest repo `AGENTS.md` and existing repo docs first; default to `docs/ai/knowledge/` only when the repo does not define another location.
2. Decide the narrowest useful scope:
   - `lv2` skill PRD
   - repo overview
   - module
   - flow
   - hotspot file cluster
3. Update `<repo-knowledge-root>/INDEX.md` when the new note changes how future readers should navigate the repo knowledge. Update `<repo-knowledge-root>/setup-prd/INDEX.md` when the new note is an `lv2` skill PRD.
4. Save the deep dive in the smallest matching note file:
   - `<repo-knowledge-root>/setup-prd/<skill-name>.md` for `lv2` skill PRDs
   - `<repo-knowledge-root>/modules/<module>.md`
   - `<repo-knowledge-root>/flows/<flow>.md`
   - a hotspot note only when module or flow notes are not enough
5. Write a compact summary of stable structure, responsibilities, interactions, and recurring pitfalls.
6. Include source files, docs, and a `last checked` date.

## Note Shape

Each note should include:

- title
- scope
- when to use this note
- concise summary
- important files or docs
- `last checked: YYYY-MM-DD`

`lv2` skill PRDs should use the standard sections: Purpose, Desired State, Audit Checklist, Success Criteria, Out of Scope, Related Sources, Last Checked.

## Guidance

- Prefer module or flow summaries over file-by-file notes.
- Keep repo-local `lv2` PRDs separate from normal module or flow notes.
- Summarize stable structure and behavior, not temporary branch work.
- Use repo notes to reduce rediscovery cost, not to replace reading the code.
- If a note starts becoming cross-repo knowledge, move or summarize that part into global knowledge.

## Boundaries

- Do not store repo-specific deep dives under `~/.codex/knowledge/`.
- Do not store build, test, architecture, or safety rules here if they belong in the repo's own docs or `AGENTS.md`.
- If repo code or docs disagree with the cached note, the repo wins and the note should be refreshed.
