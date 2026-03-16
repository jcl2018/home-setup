---
name: lv0-home-codex-health
description: Use to audit Codex setup for drift and context bloat.
---

# Codex Health

Use this when the user wants to review a Codex home folder, a repo's `AGENTS.md` setup, or why sessions feel noisy, repetitive, or inconsistent.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv0-home-codex-health.md](../../knowledge/setup-prd/lv0-home-codex-health.md).

## Scope

First decide what is being audited:

- Home setup: `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `~/.codex/config.toml`, custom skills in `~/.codex/skills`, home knowledge notes in `~/.codex/knowledge`, the PRDs under `~/.codex/knowledge/setup-prd/`, and relevant automations in `~/.codex/automations`.
- Repo setup: the nearest repo `AGENTS.md`, `.local-work/current.md`, any nested `AGENTS.md`, the repo knowledge root when defined, any repo-local `setup-prd/` entries for `lv2` skills, repo verification commands, and repo AI docs such as `docs/ai/`.
- Both, when the user asks for the full picture.

Exported mirror repos are not part of the default home-audit scope. Only inspect them when the user explicitly asks to audit the export flow or the mirror repo itself.

## Audit Inputs

- For home audits, start with `~/AGENTS.md`, `~/.codex/.local-work/current.md`, [../../knowledge/setup-prd/INDEX.md](../../knowledge/setup-prd/INDEX.md), and [../../knowledge/setup-prd/home-setup.md](../../knowledge/setup-prd/home-setup.md), then load only the matching skill PRDs.
- For repo audits, start with the nearest repo `AGENTS.md` and `.local-work/current.md`. Identify the repo knowledge root from the repo contract, then read `<repo-knowledge-root>/setup-prd/INDEX.md` and the matching PRDs when the repo has `lv2` skills or repo-local workflow contracts.

## Translation Layer

Read [references/claude-to-codex.md](references/claude-to-codex.md) before auditing. It maps the Claude guidance to Codex so you do not force Claude-only patterns into places where Codex works differently.

## Audit Checks

### 1. Root contract quality

- Keep `AGENTS.md` short, executable, and specific to its scope.
- Flag duplicated rules across home and repo `AGENTS.md`.
- Flag conflicting rules across home and repo `AGENTS.md`.
- Flag missing verification guidance.
- Flag missing required tracking-doc rules or missing required tracking docs.
- Flag missing compacting or handoff priorities.

### 2. Context cost

- Flag long root files that should become skills or linked docs.
- Flag vague skill descriptions that could trigger too broadly.
- Flag `SKILL.md` files that duplicate detailed reference content instead of linking to supporting files.
- Flag stale or overlapping skills that teach the same workflow twice.
- Flag missing PRDs for `lv0`/`lv1` skills or missing repo-local PRDs for `lv2` skills.
- Flag empty or stale home knowledge template starters that add noise without saving future work.

### 3. Workflow placement

- Global preferences belong in `~/AGENTS.md`.
- Repo build, test, architecture, and safety rules belong in the repo `AGENTS.md`.
- Reusable but low-frequency workflows belong in home skills.
- Deep repo detail belongs in linked docs, not in the root contract.

### 4. Safety and continuity

- Check for clear approval boundaries around secrets, CI, migrations, production, or destructive edits.
- Check whether home and repo tracking docs exist, are read in the required order, and reflect the current verification and next steps.
- Check whether home automations or PRDs still match the current home setup and skill layout.

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
