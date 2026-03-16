# Codex Home Settings

This repo stores a static mirror of a Codex home control layer.

## What it tracks

- `AGENTS.md`
- `.codex/.local-work/current.md`
- `.codex/config.toml`
- custom home skills under `.codex/skills/` except `.system`
- home knowledge under `.codex/knowledge/`, including workflow PRDs under `.codex/knowledge/setup-prd/`
- automation definitions at `.codex/automations/*/automation.toml`

## What it excludes

- auth and secret files such as `.codex/auth.json`
- sqlite state, logs, sessions, memories, caches, shell snapshots, and vendor imports
- automation runtime state outside `automation.toml`
- system-managed skills under `.codex/skills/.system`

## Mirror behavior

Managed files are copied from the current home tree as-is, within the tracked roots and exclusions listed in `codex-home-manifest.toml`.

This repo intentionally does not include install or restore scripts.

## Layout guidance

Use this repo only for the Codex home control layer. Keep your normal coding repos outside this mirror repo under a stable workspace root such as `~/Documents/projects` or another single parent you control. Each project repo should keep its own `AGENTS.md`, verification commands, and repo-local AI docs.

## Export

```bash
python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /path/to/this/repo
```
