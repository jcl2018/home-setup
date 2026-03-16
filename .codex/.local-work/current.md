# Last updated

- 2026-03-16

## Goal

- Export the live Codex home control layer from `/Users/chjiang` into the local mirror repo `/Users/chjiang/Documents/projects/home-setup`, then commit and push the managed mirror update to `origin`.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-settings-export`, the matching PRD, and the export script before acting.
- Confirmed the mirror repo is `/Users/chjiang/Documents/projects/home-setup` on branch `main` with remote `origin` set to `https://github.com/jcl2018/home-setup.git`.
- Found pre-existing local repo noise before export: a timestamp-only modification in `codex-home-manifest.toml` plus untracked `.gitignore` and `.codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp`.
- Intend to run the export script, review the mirror diff, commit only managed mirror changes, and leave unrelated untracked local files alone.

## Decisions / constraints

- Use `lv0-home-codex-settings-export` as the workflow source of truth for the mirror refresh.
- Export only the managed home-control roots and do not include secrets, auth, runtime state, `.system` skills, or other excluded transient data.
- Show the mirror diff summary and call out any riskier files before committing, per `~/AGENTS.md`.
- Do not add unrelated untracked repo files to the commit unless the export workflow itself starts tracking them.

## Files touched

- `~/.codex/.local-work/current.md`

## Verification

- `sed -n '1,220p' /Users/chjiang/AGENTS.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/.local-work/current.md` -> pass
- `sed -n '1,240p' /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,240p' /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup status --short` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup branch --show-current` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup remote -v` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- codex-home-manifest.toml` -> pass
- `sed -n '1,200p' /Users/chjiang/Documents/projects/home-setup/.gitignore` -> pass
- `ls -la /Users/chjiang/Documents/projects/home-setup/.codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp` -> pass

## Next steps

- Run the export script against `/Users/chjiang/Documents/projects/home-setup`.
- Inspect `git status`, `git diff --stat`, and the staged file list.
- Commit the managed export update and push `main` to `origin`.

## Blockers / risks

- The mirror repo contains unrelated untracked local files; they should stay out of the export commit unless intentionally cleaned up later.
- The export will refresh generated files such as `README.md` and `codex-home-manifest.toml`, so their diffs may include broad timestamp or inventory updates.

## Rollback notes

- Revert the mirror repo commit or reset the mirror worktree to `origin/main` if the export snapshot needs to be discarded after review.
