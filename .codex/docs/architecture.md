# Codex Home Architecture

## Scope

This home layer is a Codex-only operating system. It does not manage or mutate `~/.claude`.

## Active Roots

- `~/AGENTS.md`: always-on global contract
- `~/.codex/skills/`: direct stage skills
- `~/.codex/bin/`: helper scripts for project state, readiness, guardrails, health, and export
- `~/.codex/docs/`: workflow and layout docs
- `~/.codex/projects/`: durable project artifacts
- `~/.codex/guardrails/current.toml`: active guardrail state
- `~/.codex/automations/`: recurring Codex-only tasks

## Project Store

Each project lives under `~/.codex/projects/<project-slug>/`.

Standard layout:

- `project.md`
- `designs/`
- `reviews/`
- `qa/`
- `ship/`
- `retro/`
- `reviews/review-readiness.jsonl`

Use `~/.codex/bin/codex-project-log ensure` to create the layout and `~/.codex/bin/codex-project-log stamp` to reserve a new artifact path.

Design flow:

- `office-hours` creates or revises the primary design doc in `designs/`
- `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, and `design-consultation` refine that same design doc in place
- implementation-stage skills consume the approved design rather than inventing a new source of truth
- `design-review`, `review`, `qa`, and `ship` record stage readiness in a shared ledger so later stages can detect missing or stale review passes

## Helper Scripts

- `codex-project-slug`: derive a stable project slug from the current repo or path
- `codex-project-log`: create the project store and append stage artifacts
- `codex-review-readiness`: append, display, or dashboard plan/review/QA/ship readiness
- `codex-guardrails`: manage careful, freeze, and guard modes, plus manual command and path checks
- `codex-skill-check`: verify the active skill tree
- `codex-home-health`: audit the active Codex home layout
- `codex-home-export`: export the active Codex home layout into the mirror repo

## Retired Layout

The old `lv0-home-*` and `lv1-workflow-*` custom workflow layer is retired.

- `~/.codex/.local-work/current.md` is no longer authoritative.
- `~/.codex/knowledge/setup-prd/` is no longer the active control plane.
- Home maintenance should target the roots in this document only.
