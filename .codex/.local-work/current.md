# Last updated

- 2026-03-16

## Goal

- Export the live home Codex control layer under `/Users/chjiang` into the canonical `jcl2018/home-setup` mirror and verify the remote has no managed drift from this machine.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-settings-export`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, `~/.codex/knowledge/setup-prd/INDEX.md`, `~/.codex/knowledge/setup-prd/home-setup.md`, `~/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md`, `~/.codex/knowledge/setup-prd/lv0-home-codex-health.md`, and the live `weekly-codex-health` automation before exporting.
- Fast-forwarded the local mirror checkout at `/Users/chjiang/Documents/projects/home-setup` to `origin/main`, then exported the live home control layer into that repo with `$lv0-home-codex-settings-export`.
- The export updated the mirrored home tracker, weekly audit automation, home config, health-audit docs, repo-bootstrap links, and added the live `lv1-workflow-feature-dev` skill plus its PRD and templates.
- Pushed `Refresh Codex home mirror` as `fa615f5` to `origin/main`, then re-ran the export audit and confirmed the remote managed roots match this machine's live home-control files.
- No live home-control files changed during the work except this tracker refresh.

## Decisions / constraints

- Use `$lv0-home-codex-settings-export` as the only export path into the canonical mirror.
- Leave unrelated mirror-local files outside the managed export roots untouched.
- Compare remote and live state using the managed roots from the mirror manifest, not volatile runtime files under `~/.codex`.

## Files touched

- `~/.codex/.local-work/current.md`
- `~/.codex/automations/weekly-codex-health/automation.toml`
- `~/.codex/config.toml`
- `~/.codex/knowledge/setup-prd/INDEX.md`
- `~/.codex/knowledge/setup-prd/lv0-home-codex-health.md`
- `~/.codex/knowledge/setup-prd/lv1-workflow-feature-dev.md`
- `~/.codex/skills/lv0-home-codex-health/SKILL.md`
- `~/.codex/skills/lv1-workflow-feature-dev/`
- `~/.codex/skills/lv1-workflow-repo-bootstrap/SKILL.md`
- `~/.codex/skills/lv1-workflow-repo-bootstrap/references/existing-repo.md`

## Verification

- `sed -n '1,220p' /Users/chjiang/AGENTS.md` -> pass
- `sed -n '1,240p' /Users/chjiang/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/INDEX.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-health.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/config.toml` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/knowledge/INDEX.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/automations/weekly-codex-health/automation.toml` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup fetch origin main` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup rev-list --left-right --count origin/main...HEAD` -> pass, `3\t0` before the fast-forward and `0\t0` after sync and after the mirror push
- `git -C /Users/chjiang/Documents/projects/home-setup log --oneline --decorate --no-merges HEAD..origin/main` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup pull --ff-only origin main` -> pass
- `python3 /Users/chjiang/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /Users/chjiang/Documents/projects/home-setup` -> pass
- `git -C /Users/chjiang/Documents/projects/home-setup diff --stat origin/main -- AGENTS.md .codex/.local-work/current.md .codex/config.toml .codex/skills .codex/knowledge .codex/automations` -> pass, no output after the mirror refresh push
- `git -C /Users/chjiang/Documents/projects/home-setup diff --name-status origin/main -- AGENTS.md .codex/.local-work/current.md .codex/config.toml .codex/skills .codex/knowledge .codex/automations` -> pass, no output after the mirror refresh push

## Next steps

- No live home follow-up is required unless the mirror should be normalized further across machines instead of preserving the current machine-specific paths and settings.

## Blockers / risks

- Each audit-time re-export rewrites the generated `codex-home-manifest.toml` timestamp, so the mirror repo may look locally dirty even when the remote managed roots are in sync.
- The canonical mirror still contains machine-specific absolute paths because the export intentionally preserves live file contents.

## Rollback notes

- Re-run `$lv0-home-codex-settings-export` into `/Users/chjiang/Documents/projects/home-setup`, revert the mirror commit, and push the revert if the canonical mirror needs to be rolled back.
