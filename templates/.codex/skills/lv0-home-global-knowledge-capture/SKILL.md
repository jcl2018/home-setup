---
name: lv0-home-global-knowledge-capture
description: Use when Codex should add or update private global knowledge that is stable across multiple repos. Save concise summaries under `~/.codex/knowledge/global`, include source references, and avoid repo-specific implementation detail unless it is needed to explain a shared concept.
---

# Home Global Knowledge Capture

Use this skill when the user wants to save or refresh knowledge that is shared across multiple repos or is useful as general cross-repo context.

## Workflow

1. Confirm the knowledge belongs in global scope:
   - shared terminology
   - system relationships
   - shared services
   - architecture patterns reused across repos
   - recurring cross-repo gotchas
2. If the knowledge is mainly about one repo or one module, do not store it here. Use repo knowledge capture in that repo instead.
3. Choose the smallest fitting target file under `~/.codex/knowledge/global/`.
4. Write a compact summary that helps future work without duplicating large amounts of repo detail.
5. Include the source files, docs, or repos the note was derived from.
6. Add or refresh a `last checked` date.

## File Guidance

Prefer these targets when they fit:

- `global/INDEX.md`
- `global/glossary.md`
- `global/system-map.md`
- `global/shared-services.md`
- `global/common-gotchas.md`

Create a new global note only when an existing file would become unclear or overloaded.

## Note Shape

Each note should include:

- title
- scope
- when to use this note
- concise summary
- source files or docs
- `last checked: YYYY-MM-DD`

## Boundaries

- Do not copy large repo-specific implementation detail into global notes.
- Do not treat global notes as canonical truth.
- If the information is unstable or only locally true in one repo, store it in that repo's local knowledge docs instead.
