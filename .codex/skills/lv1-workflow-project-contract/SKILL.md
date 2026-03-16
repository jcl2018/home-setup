---
name: lv1-workflow-project-contract
description: Use when creating or tightening a repo AGENTS.md.
---

# Project Contract

Use this when the user wants to bootstrap or clean up a repo so Codex has a reliable local contract without bloating startup context.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv1-workflow-project-contract.md](../../knowledge/setup-prd/lv1-workflow-project-contract.md).

## Goal

Create or update the repo's `AGENTS.md` so it contains only the rules that should always be in context for that repo.

## Workflow

1. Inspect the repo shape.
   - Find the main languages, build system, and verification commands.
   - Look for existing `AGENTS.md`, `.local-work/current.md`, `docs/ai/`, architecture docs, or handoff notes.

2. Decide what belongs in the repo root contract.
   - Build and test commands.
   - Architecture boundaries.
   - Repo-specific safety rails.
   - Verification rules by task type.
   - The required repo tracking doc path and exact read and refresh rules.
   - The repo knowledge root when the repo keeps durable notes.
   - The local `setup-prd/` rule when the repo uses any `lv2-<repo>-*` skills.
   - Compacting or handoff priorities.

3. Split detail out instead of bloating the root.
   - Use nested `AGENTS.md` only for real module boundaries.
   - Put long reference material in repo docs such as `docs/ai/` or `docs/architecture/`.
   - If the repo keeps reusable deep-dive notes, define the repo knowledge root in `AGENTS.md`; default to `docs/ai/knowledge/` only when no better location exists.
   - Keep `.local-work/current.md` as the required active tracking doc and avoid storing durable reference material there.
   - If the repo uses `lv2` skills, keep matching PRDs under `<repo-knowledge-root>/setup-prd/` with filenames that match the skill name exactly.
   - Keep reusable cross-repo workflows in home skills, not in the repo root contract.

4. Remove duplication.
   - Do not restate generic global rules already covered in `~/AGENTS.md`.
   - Keep the repo contract focused on what changes from repo to repo.

5. Validate the contract.
   - Make sure every verification rule maps to a real command.
   - Make sure the required tracking doc path and refresh triggers are explicit.
   - Make sure the repo knowledge root and `lv2` PRD rule are explicit when the repo uses durable local workflow contracts.
   - Make sure each rule is short enough to survive context pressure.

## Template

Start from [references/agent-template.md](references/agent-template.md) and adapt it instead of inventing a large outline from scratch.
