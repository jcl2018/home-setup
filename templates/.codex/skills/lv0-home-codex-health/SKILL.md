---
name: lv0-home-codex-health
description: Use to audit Codex setup for drift and context bloat.
---

# Codex Health

Use this when the user wants to review a Codex home folder, a repo's `AGENTS.md` setup, or why sessions feel noisy, repetitive, or inconsistent.

## Scope

First decide what is being audited:

- Home setup: `~/AGENTS.md`, `~/.codex/config.toml`, custom skills in `~/.codex/skills`, home knowledge notes in `~/.codex/knowledge`, supporting home docs such as `~/.codex/home_setup_summary.md`, and relevant automations in `~/.codex/automations`.
- Repo setup: the nearest repo `AGENTS.md`, any nested `AGENTS.md`, repo verification commands, and repo AI docs such as `docs/ai/`.
- Both, when the user asks for the full picture.

## Translation Layer

Read [references/claude-to-codex.md](references/claude-to-codex.md) before auditing. It maps the Claude guidance to Codex so you do not force Claude-only patterns into places where Codex works differently.

## Audit Checks

### 1. Root contract quality

- Keep `AGENTS.md` short, executable, and specific to its scope.
- Flag duplicated rules across home and repo `AGENTS.md`.
- Flag conflicting rules across home and repo `AGENTS.md`.
- Flag missing verification guidance.
- Flag missing compacting or handoff priorities.

### 2. Context cost

- Flag long root files that should become skills or linked docs.
- Flag vague skill descriptions that could trigger too broadly.
- Flag `SKILL.md` files that duplicate detailed reference content instead of linking to supporting files.
- Flag stale or overlapping skills that teach the same workflow twice.
- Flag empty or stale home knowledge template starters that add noise without saving future work.

### 3. Workflow placement

- Global preferences belong in `~/AGENTS.md`.
- Repo build, test, architecture, and safety rules belong in the repo `AGENTS.md`.
- Reusable but low-frequency workflows belong in home skills.
- Deep repo detail belongs in linked docs, not in the root contract.

### 4. Safety and continuity

- Check for clear approval boundaries around secrets, CI, migrations, production, or destructive edits.
- Check whether the repo has a handoff pattern if work often spans sessions.
- Check whether home automations or summary docs still match the current home setup and skill layout.

### 5. Verification

- Verify that done-conditions map to real commands in the repo.
- Prefer small, relevant checks over heavy suites unless the task calls for a full run.

## Output Format

Report findings in three sections:

- Critical
- Structural
- Incremental

Each finding should say:

- what is wrong
- where it lives
- why it costs context or reliability
- the smallest fix
