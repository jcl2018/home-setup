# Last updated

- 2026-03-16

## Goal

- Normalize the canonical `jcl2018/home-setup` mirror so future home audits compare portable content instead of machine-specific paths and host-only config.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-settings-export`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, and the home setup PRDs before revising the export contract.
- Updated the export workflow so mirrored text files rewrite the source home root to `~`, mirrored `.codex/config.toml` drops top-level OS-specific tables such as `[windows]`, `[macos]`, and `[linux]`, and the manifest records those normalization rules.
- Updated the home audit and home-setup PRDs so future audits compare normalized live content against the canonical mirror instead of raw local absolute paths.
- Restored the repo-bootstrap skill links back to relative paths so they stay portable in both the live home tree and the mirror.
- Exported the normalized snapshot into `~/Documents/projects/home-setup`; the mirror diff now shows portable automation paths plus the new normalization-aware manifest and README.

## Decisions / constraints

- Use `$lv0-home-codex-settings-export` as the only export path into the canonical mirror.
- Leave unrelated mirror-local files outside the managed export roots untouched.
- Compare remote and live state using the managed roots from the mirror manifest, not volatile runtime files under `~/.codex`.
- Treat `codex-home-manifest.toml` timestamp churn as mirror-local noise unless one of the managed roots actually differs.
- Normalize only the exported mirror; do not rewrite the live home files just to make the mirror portable.
- Use `~` as the portable home marker in exported text and treat top-level OS-specific config tables as host-local, not canonical mirror state.

## Files touched

- `~/.codex/.local-work/current.md`
- `~/.codex/skills/lv0-home-codex-settings-export/SKILL.md`
- `~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py`
- `~/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md`
- `~/.codex/skills/lv0-home-codex-health/SKILL.md`
- `~/.codex/knowledge/setup-prd/lv0-home-codex-health.md`
- `~/.codex/knowledge/setup-prd/home-setup.md`
- `~/.codex/skills/lv1-workflow-repo-bootstrap/SKILL.md`
- `~/.codex/skills/lv1-workflow-repo-bootstrap/references/existing-repo.md`

## Verification

- `sed -n '1,220p' ~/AGENTS.md` -> pass
- `sed -n '1,240p' ~/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' ~/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,260p' ~/.codex/skills/lv0-home-codex-settings-export/SKILL.md` -> pass
- `sed -n '1,260p' ~/.codex/knowledge/setup-prd/lv0-home-codex-settings-export.md` -> pass
- `sed -n '1,240p' ~/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,220p' ~/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `python3 -m py_compile ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py` -> pass
- `python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo /tmp/.../repo` -> pass
- `python3 - <<'PY' ... normalize_text_for_export('.codex/config.toml', sample_with_windows_table, Path('~')) ... PY` -> pass
- `python3 ~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py --repo ~/Documents/projects/home-setup` -> pass
- `git -C ~/Documents/projects/home-setup diff --stat` -> pass

## Next steps

- No live home follow-up is required unless future home-control changes need another export.
- Optional: re-run `lv0-home-codex-health` from a different machine later to validate the normalized mirror contract end-to-end.

## Blockers / risks

- Each audit-time re-export rewrites the generated `codex-home-manifest.toml` timestamp, so the mirror repo may look locally dirty even when the managed roots are otherwise in sync.
- The exported tracker is now portability-normalized too, so mirrored shell snippets are documentation rather than guaranteed copy-paste commands.

## Rollback notes

- Restore the previous export script and PRD wording, re-run `$lv0-home-codex-settings-export` into `~/Documents/projects/home-setup`, and push the resulting revert snapshot if the canonical mirror should go back to raw machine-specific exports.
