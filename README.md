# Codex Home Settings

This repo stores a portable snapshot of a Codex home control layer.

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

## Portability

Home-rooted absolute paths are stored as `__HOME__` in tracked text files and rebound to the active home directory during restore.

## Layout guidance

Use this repo only for the Codex home control layer. Keep your normal coding repos outside this snapshot repo under a stable workspace root such as `~/Documents/projects` or another single parent you control. Each project repo should keep its own `AGENTS.md`, verification commands, and repo-local AI docs.

## Export

```bash
python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /path/to/this/repo
```

## Restore

Preview before writing anything:

```bash
python3 /path/to/this/repo/.codex/skills/lv0-home-codex-settings-restore/scripts/restore_codex_home.py --source /path/to/this/repo
```

Apply the restore after reviewing the preview:

```bash
python3 /path/to/this/repo/.codex/skills/lv0-home-codex-settings-restore/scripts/restore_codex_home.py --source /path/to/this/repo --apply
```

If the repo is remote-backed, the restore script can clone or pull first.
