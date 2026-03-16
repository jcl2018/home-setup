# Last updated

- 2026-03-16

## Goal

- Audit the normalized canonical `jcl2018/home-setup` mirror and confirm the live home control layer has no remaining in-scope drift.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-health`, and `~/.codex/knowledge/setup-prd/home-setup.md` before re-running the home audit.
- Re-fetched `origin/main` for `~/Documents/projects/home-setup` and confirmed the local mirror checkout, `origin/main`, and the current remote `HEAD` all resolve to `cf6334a5a0325ca5bcd9dc41d0301045bc29419d`.
- Compared every managed home file by applying the export normalization rules to the live `~` content and matching the result against the mirror manifest entries; the normalized comparison returned `NO_DIFFS`.
- Searched the canonical mirror managed roots for hard-coded `/Users/...` or `C:/Users/...` paths and found none after the portability cleanup.
- Re-checked live home skill and PRD coverage; every current `lv0` and `lv1` skill still has a matching home PRD.
- No in-scope audit findings remain after the portability cleanup.

## Decisions / constraints

- Audit the live home against the canonical mirror by applying the same normalization rules the export workflow uses.
- Keep exported mirror repos out of the default audit scope except for the narrow managed-root consistency check against the canonical remote.
- Ignore mirror-local untracked noise outside the managed roots when deciding whether the home control layer itself is healthy.

## Files touched

- `~/.codex/.local-work/current.md`

## Verification

- `sed -n '1,220p' ~/AGENTS.md` -> pass
- `sed -n '1,240p' ~/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' ~/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,220p' ~/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `git -C ~/Documents/projects/home-setup fetch origin main && git -C ~/Documents/projects/home-setup rev-parse HEAD origin/main && git ls-remote https://github.com/jcl2018/home-setup.git HEAD` -> pass (`cf6334a5a0325ca5bcd9dc41d0301045bc29419d` for all three)
- `python3 - <<'PY' ... transform_for_export(raw, rel, home_root) ... PY` against `codex-home-manifest.toml` entries -> pass (`NO_DIFFS`)
- `rg -n '/Users/[^/]+|C:/Users/[^/]+' ~/Documents/projects/home-setup/AGENTS.md ~/Documents/projects/home-setup/.codex/.local-work/current.md ~/Documents/projects/home-setup/.codex/config.toml ~/Documents/projects/home-setup/.codex/skills ~/Documents/projects/home-setup/.codex/knowledge ~/Documents/projects/home-setup/.codex/automations` -> pass (no output)
- `find ~/.codex/skills -mindepth 1 -maxdepth 1 -type d` and `find ~/.codex/knowledge/setup-prd -maxdepth 1 -type f` -> pass

## Next steps

- No live home follow-up is required unless future home-control changes need another export.
- Optional: clean the local mirror checkout's untracked `.swp`, `.gitignore`, `.DS_Store`, or `.local-work/` noise if you want that checkout itself to look pristine.

## Blockers / risks

- The canonical remote is clean, but the local mirror checkout still has out-of-scope untracked noise that does not affect the managed export.
- Future audit-time tracker refreshes will create fresh live drift unless they are followed by another export, because `~/.codex/.local-work/current.md` is itself part of the managed mirror.

## Rollback notes

- Re-run `$lv0-home-codex-settings-export` into `~/Documents/projects/home-setup`, then revert and push the resulting mirror commit if the canonical remote needs to return to an earlier snapshot.
