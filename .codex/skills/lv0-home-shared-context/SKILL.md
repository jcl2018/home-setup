---
name: lv0-home-shared-context
description: Use when the user explicitly wants cached knowledge consulted, or when a task clearly points to a known shared concept or known repo-local knowledge note. Read the smallest relevant note under `~/.codex/knowledge` or the current repo's configured local knowledge docs, and prefer repo truth if cached notes are stale.
---

# Home Shared Context

Use this skill when the user explicitly wants saved knowledge consulted, or when a task clearly refers to a known shared concept or a known repo-local knowledge note that may already exist.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv0-home-shared-context.md](../../knowledge/setup-prd/lv0-home-shared-context.md).

## Workflow

1. Identify whether the task is mainly about:
   - a home or workflow contract
   - a shared global concept
   - a specific repo
   - a specific module, flow, or file area inside a repo
2. For repo-local work, identify the repo knowledge root from the nearest repo `AGENTS.md` or existing repo docs. Use `docs/ai/knowledge/` only if the repo does not define another location.
3. Read only the smallest matching note set:
   - `~/.codex/knowledge/setup-prd/INDEX.md` for home or workflow contracts
   - `~/.codex/knowledge/INDEX.md` and the smallest matching note under `~/.codex/knowledge/` for shared cross-repo concepts
   - `<repo-knowledge-root>/setup-prd/INDEX.md` for repo-local `lv2` skill or workflow contracts
   - `<repo-knowledge-root>/INDEX.md` for repo-level context
   - the smallest matching note under `<repo-knowledge-root>` for a module or flow
4. Prefer repo or module notes over broad global notes when the task is local and specific.
5. If no clear note matches, do normal repo exploration and do not force-load the knowledge base.
6. Treat home knowledge as a compact cache, not the source of truth. If repo code or repo docs disagree, the repo wins.

## Loading Rules

- Start with `setup-prd/INDEX.md` when the task is about home setup or workflow contracts.
- Start with `INDEX.md` only when the task is clearly cross-repo.
- Start with `<repo-knowledge-root>/setup-prd/INDEX.md` when the task is about repo-local `lv2` skills or repo workflow contracts.
- Start with `<repo-knowledge-root>/INDEX.md` when the task is clearly about one repo and that repo has local knowledge docs.
- Read deeper notes only when the task needs them.
- Avoid loading unrelated repos or broad global notes for narrow tasks.

## Boundaries

- Do not use this skill to save new knowledge.
- Do not assume a note is current without checking linked repo files or docs when correctness matters.
