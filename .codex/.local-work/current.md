# Last updated

- 2026-03-16

## Goal

- Audit the live home Codex control layer under `/Users/chjiang` for contract drift, mirror drift, context cost, and verification gaps.

## Current state

- Read `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `$lv0-home-codex-health`, `$lv1-workflow-session-handoff`, `~/.codex/knowledge/setup-prd/INDEX.md`, `~/.codex/knowledge/setup-prd/home-setup.md`, `~/.codex/knowledge/setup-prd/lv0-home-codex-health.md`, `~/.codex/knowledge/work-start-checklist.md`, `~/.codex/config.toml`, `~/.codex/knowledge/INDEX.md`, and the live `weekly-codex-health` automation before concluding the audit.
- Cloned the current `https://github.com/jcl2018/home-setup.git` remote at `f90afa9c25d70b6e292003c925f320e69960c325` to compare only the managed home-control roots against the live setup.
- The live home contract is still lean: `~/AGENTS.md` is short, skill descriptions are specific, and each live `lv0` and `lv1` skill has a matching home PRD.
- The canonical mirror is no longer aligned with this machine's live home setup. The remote export still reflects `C:/Users/chang`, keeps a Windows-specific `[windows] sandbox = "elevated"` config stanza, and is missing the live `lv1-workflow-feature-dev` skill plus the matching PRD and audit updates.
- No live home-control files were changed during the audit except this tracker refresh.

## Decisions / constraints

- Treat `jcl2018/home-setup` drift as a home-setup finding only; do not auto-export or mutate the mirror during an audit.
- Keep the audit read-only unless the user explicitly asks to repair or export the mirror.
- Compare remote and live state using the managed roots from the mirror manifest, not volatile runtime files under `~/.codex`.

## Files touched

- `~/.codex/.local-work/current.md`

## Verification

- `sed -n '1,220p' /Users/chjiang/AGENTS.md` -> pass
- `sed -n '1,240p' /Users/chjiang/.codex/.local-work/current.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/skills/lv0-home-codex-health/references/claude-to-codex.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/INDEX.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/home-setup.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-health.md` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/knowledge/work-start-checklist.md` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/config.toml` -> pass
- `sed -n '1,220p' /Users/chjiang/.codex/knowledge/INDEX.md` -> pass
- `find /Users/chjiang/.codex/skills -mindepth 1 -maxdepth 1 -type d | sort` -> pass
- `find /Users/chjiang/.codex/automations -mindepth 1 -maxdepth 1 -type d | sort` -> pass
- `sed -n '1,260p' /Users/chjiang/.codex/automations/weekly-codex-health/automation.toml` -> pass
- `tmpdir=$(mktemp -d /tmp/home-setup-audit.XXXXXX) && git clone --depth=1 https://github.com/jcl2018/home-setup.git "$tmpdir/repo" >/dev/null 2>&1 && git -C "$tmpdir/repo" rev-parse HEAD` -> pass
- `sed -n '1,260p' /tmp/home-setup-audit.v7LzJc/repo/codex-home-manifest.toml` -> pass
- `git ls-remote https://github.com/jcl2018/home-setup.git HEAD` -> pass
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/config.toml /Users/chjiang/.codex/config.toml` -> pass (difference observed)
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/automations/weekly-codex-health/automation.toml /Users/chjiang/.codex/automations/weekly-codex-health/automation.toml` -> pass (difference observed)
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/knowledge/setup-prd/INDEX.md /Users/chjiang/.codex/knowledge/setup-prd/INDEX.md` -> pass (difference observed)
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/knowledge/setup-prd/lv0-home-codex-health.md /Users/chjiang/.codex/knowledge/setup-prd/lv0-home-codex-health.md` -> pass (difference observed)
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/skills/lv0-home-codex-health/SKILL.md /Users/chjiang/.codex/skills/lv0-home-codex-health/SKILL.md` -> pass (difference observed)
- `diff -u /tmp/home-setup-audit.v7LzJc/repo/.codex/.local-work/current.md /Users/chjiang/.codex/.local-work/current.md` -> pass (difference observed)

## Next steps

- If `jcl2018/home-setup` is still the canonical mirror for this machine, run `$lv0-home-codex-settings-export` into the intended local mirror checkout and push the refreshed export so future audits have a trustworthy baseline.
- Decide whether the mirror should stay machine-specific or become a normalized cross-platform reference; the current remote mixes shared content with machine-specific absolute paths and config.
- Re-run `$lv0-home-codex-health` after the mirror strategy is settled to confirm the remaining findings are limited to actual contract issues.

## Blockers / risks

- Until the mirror strategy is clarified, remote comparison will keep producing noisy drift from OS-specific paths and config even when the live home contract is healthy.
- The live home control layer is intentionally ahead of the remote mirror right now because the recent feature-dev workflow additions have not been exported.

## Rollback notes

- Revert only this tracker refresh if you need to restore the previous handoff; the audit itself was otherwise read-only.
