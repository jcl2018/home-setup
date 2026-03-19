# Last updated

- 2026-03-18

## Goal

- Audit the home control layer against the canonical `jcl2018/home-setup` mirror and identify any current drift, contract gaps, or context-setup issues.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-health`, the health skill translation reference, `~/.codex/knowledge/setup-prd/INDEX.md`, and `~/.codex/knowledge/setup-prd/home-setup.md` before rerunning the audit.
- Confirmed the local mirror checkout at `~/Documents/projects/home-setup` still matches `origin/main` and the current remote `HEAD`, all at `f8dbd80dd25ecb22148dc78ab875cb64218fed1d` from 2026-03-16 16:58:24 -0700 (`Refresh home audit tracker`).
- Compared the normalized live home control layer against that canonical mirror snapshot by reusing the export workflow's `transform_for_export(...)` rules and managed-root file collection.
- The live home now contains a new `lv1-workflow-youtube-knowledge-capture` skill plus its PRD, but the canonical mirror does not contain those files yet.
- The mirror's tracked `~/.codex/.local-work/current.md` and `~/.codex/knowledge/setup-prd/INDEX.md` are also stale relative to the live home, which is consistent with the missing YouTube skill export.
- Live `lv0` and `lv1` skill-to-PRD coverage remains complete; no additional contract or context-bloat issue surfaced during this audit.

## Decisions / constraints

- Audit the live home against the canonical mirror by applying the same portability normalization rules the export workflow uses.
- Treat the remote `jcl2018/home-setup` state as the audit baseline, not the local mirror checkout's untracked noise.
- Keep exported mirror repos out of default audit scope except for the narrow managed-root consistency check against the canonical remote.

## Files touched

- `~/.codex/.local-work/current.md`

## Verification

- `sed -n '1,220p' ~/AGENTS.md` -> pass
- `sed -n '1,260p' ~/.codex/.local-work/current.md` -> pass
- `sed -n '1,260p' ~/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,220p' ~/.codex/skills/lv0-home-codex-health/references/claude-to-codex.md` -> pass
- `sed -n '1,220p' ~/.codex/knowledge/setup-prd/INDEX.md` -> pass
- `sed -n '1,260p' ~/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `git -C ~/Documents/projects/home-setup fetch origin main && git -C ~/Documents/projects/home-setup rev-parse HEAD origin/main && git ls-remote https://github.com/jcl2018/home-setup.git HEAD` -> pass (`f8dbd80dd25ecb22148dc78ab875cb64218fed1d` for all three)
- `git -C ~/Documents/projects/home-setup status --short` -> pass (`?? .codex/knowledge/setup-prd/.lv0-home-codex-health.md.swp`, `?? .gitignore`)
- `git -C ~/Documents/projects/home-setup diff --stat origin/main -- AGENTS.md .codex/.local-work/current.md .codex/config.toml .codex/skills .codex/knowledge .codex/automations` -> pass (no output)
- `python3 - <<'PY' ... collect_home_files(home_root) / collect_repo_snapshot_files(repo_root) / transform_for_export(...) ... PY` -> pass (`missing_in_repo=5`, `changed=2`, `missing_in_live=0`)
- `python3 - <<'PY' ... enumerate lv0/lv1 skills and matching PRDs ... PY` -> pass

## Next steps

- Re-run `$lv0-home-codex-settings-export` into `~/Documents/projects/home-setup` and push the result if you want the canonical mirror to match the current live home again.
- Ignore the local mirror checkout's untracked `.swp` and `.gitignore` noise unless you want that checkout itself to look pristine.

## Blockers / risks

- The canonical mirror is stale relative to live home, so future home audits against the remote will continue to complain until the new skill export is pushed.
- Because `~/.codex/.local-work/current.md` is part of the managed mirror, any audit-time tracker refresh also creates live-vs-remote drift until the next export.

## Rollback notes

- Re-run `$lv0-home-codex-settings-export` into `~/Documents/projects/home-setup`, then revert and push the resulting mirror commit if the canonical remote needs to return to an earlier snapshot.
