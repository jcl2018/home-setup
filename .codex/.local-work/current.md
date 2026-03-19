# Last updated

- 2026-03-19

## Goal

- Export the live home Codex control layer under `~` into the canonical `jcl2018/home-setup` mirror and verify the remote has no managed drift from this machine.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-settings-export`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, `~/.codex/knowledge/setup-prd/INDEX.md`, `~/.codex/knowledge/setup-prd/home-setup.md`, and `~/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` before exporting.
- Confirmed the local mirror checkout at `~/Documents/projects/home-setup` was already synced to `origin/main` before the export, with only the mirror-local untracked `.gitignore` and swap file outside the managed roots.
- The export added the live `lv1-workflow-youtube-knowledge-capture` skill plus its PRD and helper files, and it refreshed the mirrored home tracker and PRD index.
- Pushed `Refresh Codex home mirror` as `2530630` to `origin/main`, then re-ran the export-based parity audit and confirmed the remote managed roots match this machine's live home-control files.
- No live home-control files changed during the work except this tracker refresh.

## Decisions / constraints

- Use `$lv0-home-codex-settings-export` as the only export path into the canonical mirror.
- Leave unrelated mirror-local files outside the managed export roots untouched.
- Compare remote and live state using the managed roots from the normalized mirror manifest, not volatile runtime files under `~/.codex`.

## Files touched

- `~/.codex/.local-work/current.md`
- `~/.codex/knowledge/setup-prd/INDEX.md`
- `~/.codex/knowledge/setup-prd/lv1-workflow-youtube-knowledge-capture.md`
- `~/.codex/skills/lv1-workflow-youtube-knowledge-capture/`

## Verification

- `sed -n '1,220p' ~/AGENTS.md` -> pass
- `sed -n '1,260p' ~/.codex/.local-work/current.md` -> pass
- `sed -n '1,260p' ~/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,260p' ~/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,240p' ~/.codex/skills/lv1-workflow-session-handoff/SKILL.md` -> pass
- `sed -n '1,220p' ~/.codex/knowledge/setup-prd/INDEX.md` -> pass
- `sed -n '1,260p' ~/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `sed -n '1,240p' ~/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` -> pass
- `git -C ~/Documents/projects/home-setup fetch origin main` -> pass
- `git -C ~/Documents/projects/home-setup rev-list --left-right --count origin/main...HEAD` -> pass, `0\t0`
- `python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo ~/Documents/projects/home-setup` -> pass
- `git -C ~/Documents/projects/home-setup diff --stat origin/main -- AGENTS.md .codex/.local-work/current.md .codex/config.toml .codex/skills .codex/knowledge .codex/automations` -> pass, no output after the mirror refresh push
- `git -C ~/Documents/projects/home-setup diff --name-status origin/main -- AGENTS.md .codex/.local-work/current.md .codex/config.toml .codex/skills .codex/knowledge .codex/automations` -> pass, no output after the mirror refresh push

## Next steps

- No live home follow-up is required after the closing tracker refresh is exported and pushed unless more home-control files change again.

## Blockers / risks

- Because `~/.codex/.local-work/current.md` is part of the managed mirror, any tracker refresh creates fresh live-vs-remote drift until the next export.
- The local mirror checkout can still show unrelated untracked `.gitignore` and swap-file noise even when the managed roots are in sync.

## Rollback notes

- Re-run `$lv0-home-codex-settings-export` into `~/Documents/projects/home-setup`, then reset or revert the resulting mirror commit if the canonical remote needs to return to an earlier snapshot.
