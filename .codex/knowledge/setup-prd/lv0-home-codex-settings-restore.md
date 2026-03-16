# Lv0 Home Codex Settings Restore PRD

## Purpose

Define how a portable home snapshot is previewed and restored safely into an active Codex home directory.

## Desired State

- Restore starts with preview mode and only writes on `--apply`.
- Restore validates the snapshot manifest, rebinds `__HOME_TOKEN_LITERAL__` placeholders, and restores managed files such as `~/.codex/.local-work/current.md` from the snapshot repo.
- Restore backs up changed and deleted local files before applying.
- Restore removes stale managed files when the snapshot no longer includes them.
- Restore works from a local snapshot repo or an optionally cloned or refreshed remote-backed repo.

## Audit Checklist

- The workflow emphasizes preview before apply.
- The script validates manifest structure and file hashes.
- Restore operates on the current managed roots and no longer expects the retired standalone home summary file.
- Restore keeps `.codex/skills/.system`, secrets, runtime state, and automation history outside its managed scope.

## Success Criteria

- A preview run can explain adds, updates, and deletes clearly.
- An apply run can restore the home control layer without losing the previous local state.

## Out of Scope

- Restoring excluded secrets, auth state, caches, sqlite files, or system-managed skills.
- Making snapshot repos authoritative for unrelated local files.

## Related Sources

- `~/.codex/skills/lv0-home-codex-settings-restore/SKILL.md`
- `~/.codex/skills/lv0-home-codex-settings-restore/scripts/restore_codex_home.py`

## Last Checked

- 2026-03-15
