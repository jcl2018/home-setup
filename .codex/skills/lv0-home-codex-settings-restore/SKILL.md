---
name: lv0-home-codex-settings-restore
description: Restore a portable Codex home snapshot from a local or remote-backed repo. Use when the user wants to preview, back up, and apply a saved home setup, or pull the latest exported settings before restoring them into the current home directory.
---

# Codex Settings Restore

Use this skill to restore a repo created by `lv0-home-codex-settings-export`, including optional clone or pull, preview mode, local backups, and home-path rebinding.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv0-home-codex-settings-restore.md](../../knowledge/setup-prd/lv0-home-codex-settings-restore.md).

## Workflow

1. Start with a preview run:

```bash
python3 ~/.codex/skills/lv0-home-codex-settings-restore/scripts/restore_codex_home.py --source /path/to/codex-home-settings
```

2. If the snapshot repo should be cloned or refreshed first, add `--remote <url>` and `--pull`.
3. Review the planned add, update, and delete list with the user.
4. Run the same command again with `--apply` only after the user confirms.

## What the restore does

- validate `codex-home-manifest.toml`
- clone or pull the repo when requested
- rewrite `__HOME_TOKEN_LITERAL__` back to the active home path for text files
- restore `~/.codex/.local-work/current.md` with the rest of the home control layer
- back up changed or deleted local files under `~/.codex/restore_backups/<timestamp>/`
- remove stale managed files after backup when the snapshot no longer contains them

## What it does not do

- restore excluded secrets or auth state
- restore sqlite runtime state, logs, sessions, memories, caches, or shell snapshots
- restore automation run history outside `automation.toml`
- modify `.codex/skills/.system`

## Script

- Use `scripts/restore_codex_home.py`.
- Pass `--source` for the local snapshot path.
- Pass `--remote` when the local snapshot path should be cloned if missing.
- Pass `--pull` to refresh an existing git repo before previewing or applying.
- Pass `--home-root` only for testing against a non-default home tree.
- On a fresh machine, it is fine to run the script directly from the cloned snapshot repo copy before the skill has been restored into `~/.codex/skills/`.

## Boundaries

- Preview before apply.
- Treat the snapshot as authoritative for the managed roots during `--apply`.
- Expect local-only secrets to be re-added manually after restore.
