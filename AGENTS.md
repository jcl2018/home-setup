# Codex Home Contract

This file defines the always-on Codex home workflow only. Repo-specific build, test, architecture, and domain rules belong in each repo's `AGENTS.md` or repo docs.

## Default Workflow

- `office-hours -> plan-ceo-review -> plan-eng-review -> plan-design-review -> investigate or repo work -> review -> qa or qa-only -> ship -> document-release -> retro`
- Use the direct stage skills in `~/.codex/skills/` instead of the retired `lv0/lv1` workflow.
- Keep durable work state under `~/.codex/projects/<project-slug>/`.
- Derive the slug with `~/.codex/bin/codex-project-slug` and initialize the store with `~/.codex/bin/codex-project-log ensure`.
- Use `design-consultation` when a feature needs a design system or visual direction invented before implementation.
- Use `design-review` after implementation when UI changes need rendered-state review or visual cleanup.

## Operating Principles

- Prefer complete, well-tested implementations over shortcuts when the remaining work is a bounded "lake" rather than an open-ended "ocean".
- When a planning or tradeoff discussion hinges on effort, show both the likely human-team effort and the likely Codex effort when that helps scope the decision.
- For workflow-stage closeouts, use one of `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_CONTEXT`.

## Artifacts

- `project.md` is the durable project summary.
- `designs/`, `reviews/`, `qa/`, `ship/`, and `retro/` hold stage outputs.
- `~/.codex/docs/skills.md` is the skill catalog.
- `~/.codex/docs/architecture.md` is the home layout contract.

## Verification

- Do not call work done until the smallest relevant verification has run, or state why it could not run.
- Report verification as exact command plus pass or fail.
- Prefer repo-native tests, linters, and browser tooling for `qa` work.

## Guardrails

- If `~/.codex/guardrails/current.toml` exists, honor it.
- Use `careful`, `freeze`, `guard`, and `unfreeze` to manage that state.
- Before invasive Codex home rewrites, snapshot the live home with `~/.codex/bin/codex-home-export --repo ~/Documents/projects/home-setup`.

## Boundaries

- Do not modify anything under `~/.claude` unless the user explicitly asks.
- Do not keep legacy Codex workflow files active when they conflict with this contract.
- Before any commit, show the diff summary and call out riskier files.
