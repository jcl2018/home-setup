# Lv0 Home Codex Settings Export PRD

## Purpose

Define what a portable home snapshot must include, exclude, and regenerate when exporting the Codex home control layer.

## Desired State

- Export includes `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `~/.codex/config.toml`, custom home skills except `.system`, home knowledge, and automation `automation.toml` files.
- Export includes the PRD tree through `~/.codex/knowledge/` rather than any special summary file.
- Export excludes secrets, auth, caches, sessions, sqlite state, runtime logs, and other volatile artifacts.
- Export rewrites home-rooted absolute paths to `__HOME_TOKEN_LITERAL__` in text files, refreshes the manifest, and refreshes the snapshot `README.md`.
- Managed snapshot roots are authoritative inside the snapshot repo, and stale managed files are pruned on refresh.

## Audit Checklist

- No retired standalone summary files are listed as first-class managed inputs.
- The generated README describes the PRD-backed knowledge tree accurately.
- Export leaves unrelated files outside managed roots untouched.
- Export still works when run against a non-default home root for testing.

## Success Criteria

- A fresh export produces a complete portable snapshot of the current home control layer.
- Restoring from the snapshot can recreate the home workflow docs and PRDs without manual copy steps.

## Out of Scope

- Exporting secrets or volatile runtime state.
- Pushing the snapshot repo unless the user explicitly asks.

## Related Sources

- `~/.codex/skills/lv0-home-codex-settings-export/SKILL.md`
- `~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py`

## Last Checked

- 2026-03-15
