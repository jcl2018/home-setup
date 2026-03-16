---
name: lv0-home-codex-health
description: Use to audit Codex home setup, a repo contract, or an umbrella workspace for drift, missing verification, and context bloat.
---

# Codex Health

Use this when the user wants to review a Codex home folder, a repo's `AGENTS.md` setup, an umbrella workspace, or why sessions feel noisy, repetitive, or inconsistent.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv0-home-codex-health.md](../../knowledge/setup-prd/lv0-home-codex-health.md).

## Scope

First decide what is being audited:

- Home setup: `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `~/.codex/config.toml`, custom skills in `~/.codex/skills`, home knowledge notes in `~/.codex/knowledge`, the PRDs under `~/.codex/knowledge/setup-prd/`, and relevant automations in `~/.codex/automations`.
- Repo setup: the nearest repo or umbrella-root `AGENTS.md`, `.local-work/current.md`, any nested child-repo `AGENTS.md`, the repo knowledge root when defined, any repo-local `setup-prd/` entries for `lv2` skills, repo verification commands, and repo AI docs such as `docs/ai/`.
- Both, when the user asks for the full picture.

Exported mirror repos are not part of the default home-audit scope. Exception: for this machine's home audits, compare the live home control layer against the current remote state of the canonical mirror `jcl2018/home-setup` and treat any drift as a home-setup finding, not a full mirror-repo audit.
Do not auto-export during the audit. Only inspect the export workflow or the mirror repo itself beyond that narrow remote comparison when the user explicitly asks.

## Audit Inputs

- For home audits, start with `~/AGENTS.md`, `~/.codex/.local-work/current.md`, [../../knowledge/setup-prd/INDEX.md](../../knowledge/setup-prd/INDEX.md), and [../../knowledge/setup-prd/home-setup.md](../../knowledge/setup-prd/home-setup.md), then load only the matching skill PRDs.
- For this machine's home audits, use the current remote state of `https://github.com/jcl2018/home-setup.git` as the comparison target. Prefer direct remote inspection and use a local checkout only as a convenience cache after confirming it matches the remote head. Compare only the tracked home-control roots rather than repo-local noise.
- For repo audits, start with the nearest repo or umbrella-root `AGENTS.md` and `.local-work/current.md`.
- If that root declares `Child Repos`, audit the root contract first, then traverse only the listed child repos. Do not auto-discover additional repos once the explicit list exists.
- For each audited scope, identify the knowledge root from that contract, then read `<repo-knowledge-root>/setup-prd/INDEX.md` and the matching PRDs when the scope has `lv2` skills or repo-local workflow contracts.

## Translation Layer

Read [references/claude-to-codex.md](references/claude-to-codex.md) before auditing. It maps the Claude guidance to Codex so you do not force Claude-only patterns into places where Codex works differently.

## Audit Checks

### 1. Root contract quality

- Keep `AGENTS.md` short, executable, and specific to its scope.
- Flag duplicated rules across home and repo `AGENTS.md`.
- Flag conflicting rules across home and repo `AGENTS.md`.
- Flag missing verification guidance.
- Flag missing required tracking-doc rules or missing required tracking docs.
- Flag umbrella roots that are missing a `Child Repos` section or that duplicate child build and test commands in the root contract.
- Flag listed child repos that are duplicated, missing, outside the umbrella root, or not actual git repos.
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
- Check whether home, repo, and umbrella-root tracking docs exist, are read in the required order, and reflect the current verification and next steps.
- For umbrella roots, check whether the root tracking doc stays umbrella-level and whether the listed child repos keep their own local tracking docs.
- Check whether home automations or PRDs still match the current home setup and skill layout.
- For this machine, check whether the live home control layer is consistent with the current remote state of the canonical mirror `jcl2018/home-setup`. Flag tracked-file drift or an unverifiable remote comparison, and keep export as a separate explicit workflow.

### 5. Verification

- Verify that done-conditions map to real commands in the repo or, for umbrella roots, in each touched child repo.
- Prefer small, relevant checks over heavy suites unless the task calls for a full run.

## Output Format

Report findings in three sections:

- Critical
- Structural
- Incremental

Each finding should say:

- what is wrong
- where it lives
- which child repo path it belongs to when the finding is inside an umbrella workspace
- why it costs context or reliability
- the smallest fix
