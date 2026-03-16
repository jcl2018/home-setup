---
name: lv0-home-codex-settings-export
description: Export the current Codex home control layer into a static local git mirror. Use when the user wants to back up or version the current home setup, including `~/AGENTS.md`, custom home skills, home knowledge, automation TOML, and setup docs, while excluding secrets and volatile runtime state.
---

# Codex Settings Export

Use this skill to mirror the current Codex home setup into a local git repo for backup or versioning.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv0-home-codex-settings-export.md](../../knowledge/setup-prd/lv0-home-codex-settings-export.md).

## Workflow

1. Choose a repo path outside the managed home trees such as `~/Documents/projects/home-setup`.
2. Run the export script:

```bash
python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /path/to/codex-home-settings
```

3. Review the summary, `README.md`, and `git status` in the target repo.
4. Commit or push only if the user explicitly asks.

## What the mirror includes

- `~/AGENTS.md`
- `~/.codex/.local-work/current.md`
- `~/.codex/config.toml`
- custom skills under `~/.codex/skills/` except `.system`
- home knowledge under `~/.codex/knowledge/`, including PRDs under `~/.codex/knowledge/setup-prd/`
- `automation.toml` files under `~/.codex/automations/`

## What stays local

- `~/.codex/auth.json`
- sqlite databases, logs, sessions, memories, caches, shell snapshots, and vendor imports
- automation runtime state outside `automation.toml`
- `~/.codex/skills/.system`

## Mirror rules

- Copy the managed home control layer into the mirror, but normalize machine-specific text values for portability.
- Rewrite the source home root to `~` inside exported text files so the mirror does not hard-code one machine's absolute paths.
- Omit top-level OS-specific tables such as `[windows]`, `[macos]`, and `[linux]` from exported `.codex/config.toml`.
- Regenerate `codex-home-manifest.toml` and `README.md` on each export.
- Treat the managed mirror roots in the repo as authoritative and prune stale files there on refresh.
- Do not add install or restore scripts to the exported repo.
- Keep the mirror repo separate from normal project repos. Store actual project repos under a stable workspace root and keep repo-specific rules inside each repo.

## Script

- Use `scripts/export_codex_home.py` for the actual snapshot work.
- Pass `--home-root` only for testing or dry-runs against a non-default home tree.

## Boundaries

- Do not export secrets or volatile runtime state.
- Do not mutate the live home files while normalizing the exported mirror.
- Do not run `git push` unless the user asks.
- If the target repo already contains unrelated files outside the managed mirror roots, leave them alone.
