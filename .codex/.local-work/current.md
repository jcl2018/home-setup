# Last updated

- 2026-03-16

## Goal

- Export the current live home control layer into the canonical mirror repo, push the refreshed snapshot, and verify the remote mirror matches this machine's tracked home-control files.

## Current state

- Re-read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, the repo contract and tracking note for `/Users/chjiang/Documents/projects/home-setup`, `$lv0-home-codex-settings-export`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, and the export PRD.
- `python3` on this machine already has the TOML parser needed by the export workflow.
- The canonical mirror repo at `/Users/chjiang/Documents/projects/home-setup` is on `main` with `origin` set to `https://github.com/jcl2018/home-setup.git`.
- Local repo noise outside the managed export roots currently includes untracked `.gitignore` and an untracked swap file in the mirror repo.

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

## Next steps

- Run the export script into `/Users/chjiang/Documents/projects/home-setup`.
- Review and push the managed mirror diff.
- Re-run the export and compare the result to `origin/main` to confirm tracked parity.

## Blockers / risks

- No home-control blocker is known at this point.
- Unrelated local mirror-repo noise may still appear in working-tree status, but it should not affect the tracked parity audit.

## Rollback notes

- Re-run the export from the live home tree and replace the mirror commit if the pushed snapshot is found to be incomplete.
