# Last updated

- 2026-03-15

## Goal

- Export the current Codex home settings into `__HOME__/Documents/projects/home-setup` using `lv0-home-codex-settings-export`.

## Current state

- Reviewed `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `~/.codex/skills/lv0-home-codex-settings-export/SKILL.md`, and `~/.codex/skills/lv1-workflow-session-handoff/SKILL.md`.
- The destination path exists and is already a git repo with remote `https://github.com/jcl2018/home-setup.git`.
- The export script completed and wrote 38 managed files into `__HOME__/Documents/projects/home-setup`.
- The destination diff is now the old repo contents being replaced by the managed snapshot roots and regenerated `README.md` and `codex-home-manifest.toml`.

## Decisions / constraints

- Do not push anything unless the user explicitly asks.
- The user explicitly approved overwriting the remote state for this repo.
- Keep the export limited to the snapshot workflow from `export_codex_home.py`.

## Files touched

- `~/.codex/.local-work/current.md`
- `__HOME__/Documents/projects/home-setup/AGENTS.md`
- `__HOME__/Documents/projects/home-setup/README.md`
- `__HOME__/Documents/projects/home-setup/codex-home-manifest.toml`
- `__HOME__/Documents/projects/home-setup/.codex/`

## Verification

- `sed -n '1,220p' __HOME__/AGENTS.md` -> pass
- `sed -n '1,220p' __HOME__/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' __HOME__/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,220p' __HOME__/.codex/skills/lv1-workflow-session-handoff/SKILL.md` -> pass
- `test -e __HOME__/Documents/projects/home-setup && printf 'exists\n' || printf 'missing\n'` -> pass
- `ls -la __HOME__/Documents/projects/home-setup` -> pass
- `git -C __HOME__/Documents/projects/home-setup status --short --branch` -> pass
- `git -C __HOME__/Documents/projects/home-setup remote -v` -> pass
- `git -C __HOME__/Documents/projects/home-setup rev-parse --short HEAD` -> pass
- `python3 __HOME__/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo __HOME__/Documents/projects/home-setup` -> pass
- `git -C __HOME__/Documents/projects/home-setup status --short --branch` -> pass
- `git -C __HOME__/Documents/projects/home-setup diff --stat` -> pass
- `sed -n '1,220p' __HOME__/Documents/projects/home-setup/README.md` -> pass
- `sed -n '1,220p' __HOME__/Documents/projects/home-setup/codex-home-manifest.toml` -> pass

## Next steps

- Re-export after refreshing this tracking doc so the snapshot captures the latest session state, then commit and force-push `main`.

## Blockers / risks

- Force-pushing will replace the current remote history tip for `main` with the exported snapshot commit(s).

## Rollback notes

- If the new snapshot needs to be reverted, recover from the previous remote commit history before the force-push or re-run the restore/export flow from a known-good snapshot.
