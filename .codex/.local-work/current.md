# Last updated

- 2026-03-16

## Goal

- Export the live Codex home control layer from `/Users/chjiang` into `/Users/chjiang/Documents/projects/home-setup` and keep the pushed mirror aligned with the finished export session.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-settings-export`, the matching PRD, and the export script before acting.
- Confirmed the local mirror repo at `/Users/chjiang/Documents/projects/home-setup` is on `main` with `origin` set to `https://github.com/jcl2018/home-setup.git`.
- Ran the export script against the mirror repo, reviewed the managed diff summary, and committed only managed mirror changes while leaving the untracked local `.gitignore` and swap file untouched.
- Pushed the refreshed mirror to `origin/main`.
- Refreshing this handoff note and re-exporting once more so the mirror also captures the completed home-session state.

## Decisions / constraints

- Use `lv0-home-codex-settings-export` as the workflow source of truth for the mirror refresh.
- Export only the managed home-control roots and exclude secrets, auth, runtime state, `.system` skills, and other transient data.
- Keep unrelated untracked mirror-repo files out of the export commits.
- Regenerated mirror metadata such as `codex-home-manifest.toml` should stay in sync with the exported file set.

## Files touched

- `~/.codex/.local-work/current.md`
- `/Users/chjiang/Documents/projects/home-setup`

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
- `python3 /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /Users/chjiang/Documents/projects/home-setup` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --stat` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --name-status` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup add -u` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup add .codex/skills/lv1-workflow-repo-bootstrap/references/umbrella-repo.md` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --cached --stat` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --cached --name-status` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup commit -m "Refresh Codex home mirror"` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup push origin main` -> pass

## Next steps

- Re-run the export once more after this handoff refresh, then push the final sync commit if the mirror changes.

## Blockers / risks

- Untracked local mirror-repo noise still exists as `.gitignore` and `.codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp`, but both were intentionally left out of the export commit.
- The only expected post-push drift should now be the refreshed home handoff note plus regenerated manifest metadata.

## Rollback notes

- Revert the latest mirror commit(s) in `/Users/chjiang/Documents/projects/home-setup` and push the revert if this export snapshot needs to be undone.
