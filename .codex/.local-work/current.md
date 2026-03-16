# Last updated

- 2026-03-16

## Goal

- Export the current live home control layer into the canonical mirror repo, push the refreshed snapshot, and verify the remote mirror matches this machine's tracked home-control files.

## Current state

- Re-read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, the repo contract and tracking note for `/Users/chjiang/Documents/projects/home-setup`, `$lv0-home-codex-settings-export`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, and the export PRD.
- `python3` on this machine already has the TOML parser needed by the export workflow.
- The canonical mirror repo at `/Users/chjiang/Documents/projects/home-setup` is on `main` with `origin` set to `https://github.com/jcl2018/home-setup.git`.
- Local repo noise outside the managed export roots currently includes untracked `.gitignore` and an untracked swap file in the mirror repo.
- Exported the live home tree into the canonical mirror repo, reviewed the managed diff, committed it as `63901f8` (`Refresh Codex home mirror`), and pushed it to `origin/main`.

## Decisions / constraints

- Keep export explicit through the home-settings-export skill rather than manual copying.
- Push only after reviewing the managed diff summary, and leave unrelated local repo noise untouched.
- Audit the remote by comparing a fresh export against the pushed remote head for the tracked home-control roots.

## Files touched

- `~/.codex/.local-work/current.md`
- `/Users/chjiang/Documents/projects/home-setup/.local-work/current.md`

## Verification

- `sed -n '1,220p' /Users/chjiang/AGENTS.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' /Users/chjiang/Documents/projects/home-setup/AGENTS.md` -> pass
- `sed -n '1,220p' /Users/chjiang/Documents/projects/home-setup/.local-work/current.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv1-workflow-session-handoff/SKILL.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup status --short --branch` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup remote -v` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup rev-parse --abbrev-ref HEAD` -> pass
- `python3 /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /Users/chjiang/Documents/projects/home-setup` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --stat -- . ':(exclude).gitignore' ':(exclude).codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp'` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --name-status -- . ':(exclude).gitignore' ':(exclude).codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp'` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- .codex/.local-work/current.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- .codex/automations/weekly-codex-health/automation.toml` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- .codex/knowledge/setup-prd/home-setup.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- .codex/knowledge/setup-prd/lv0-home-codex-health.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- .codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff -- codex-home-manifest.toml` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup add .codex/.local-work/current.md .codex/automations/weekly-codex-health/automation.toml .codex/knowledge/setup-prd/home-setup.md .codex/knowledge/setup-prd/lv0-home-codex-health.md .codex/skills/lv0-home-codex-health/SKILL.md codex-home-manifest.toml` -> pass, warned that `.codex/.local-work/current.md` is ignored by a local `.gitignore` but staged successfully because it is already tracked
- `git -C /Users/chjiang/Documents/projects/home-setup diff --cached --name-status` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup commit -m "Refresh Codex home mirror"` -> pass, created `63901f8`
- `git -C /Users/chjiang/Documents/projects/home-setup push origin main` -> pass

## Next steps

- Refresh the tracking notes one last time so the mirror snapshot records the completed export.
- Re-run the export and compare the managed tracked files to `origin/main`.
- Record the parity audit result in both tracking notes.

## Blockers / risks

- No home-control blocker is known at this point.
- Unrelated local mirror-repo noise may still appear in working-tree status, but it should not affect the tracked parity audit.

## Rollback notes

- Re-run the export from the live home tree and replace the mirror commit if the pushed snapshot is found to be incomplete.
