---
name: lv1-workflow-project-contract
description: Use when creating or tightening a repo AGENTS.md.
---

# Project Contract

Use this when the user wants to bootstrap or clean up a repo so Codex has a reliable local contract without bloating startup context.

## Goal

Create or update the repo's `AGENTS.md` so it contains only the rules that should always be in context for that repo.

## Workflow

1. Inspect the repo shape.
   - Find the main languages, build system, and verification commands.
   - Look for existing `AGENTS.md`, `docs/ai/`, architecture docs, or handoff notes.

2. Decide what belongs in the repo root contract.
   - Build and test commands.
   - Architecture boundaries.
   - Repo-specific safety rails.
   - Verification rules by task type.
   - Compacting or handoff priorities.

3. Split detail out instead of bloating the root.
   - Use nested `AGENTS.md` only for real module boundaries.
   - Put long reference material in repo docs such as `docs/ai/` or `docs/architecture/`.
   - If the repo keeps reusable deep-dive notes, define the repo knowledge root in `AGENTS.md`; default to `docs/ai/knowledge/` only when no better location exists.
   - Keep reusable cross-repo workflows in home skills, not in the repo root contract.

4. Remove duplication.
   - Do not restate generic global rules already covered in `~/AGENTS.md`.
   - Keep the repo contract focused on what changes from repo to repo.

5. Validate the contract.
   - Make sure every verification rule maps to a real command.
   - Make sure each rule is short enough to survive context pressure.

## Template

Start from [references/agent-template.md](references/agent-template.md) and adapt it instead of inventing a large outline from scratch.
