# Lv0 Home Codex Health PRD

## Purpose

Define the expected behavior for auditing Codex home or repo setup for drift, context bloat, safety gaps, and verification gaps.

## Desired State

- The audit reads the smallest relevant contracts before judging the setup.
- Home audits compare the observed state against `setup-prd/home-setup.md`, `~/.codex/.local-work/current.md`, and any relevant `lv0`/`lv1` PRDs.
- Repo audits read the nearest repo `AGENTS.md`, `.local-work/current.md`, the repo knowledge root when defined, and any repo-local `setup-prd/` entries for `lv2` skills.
- Findings are prioritized into `Critical`, `Structural`, and `Incremental`.
- Each finding explains what is wrong, where it lives, why it matters, and the smallest fix.

## Audit Checklist

- Confirm home and repo contracts are short, scoped, and non-duplicative.
- Check whether the required home and repo tracking docs exist and match the published read and refresh rules.
- Check whether skill docs point to the matching PRDs instead of embedding bulky detailed rules.
- Check whether `lv0`/`lv1` skills have matching home PRDs.
- Check whether repos with `lv2` skills also have a repo knowledge root and matching repo-local PRDs.
- Verify done-conditions and verification guidance map to real commands.

## Success Criteria

- The audit identifies the highest-leverage reliability and context issues first.
- The audit can explain whether the current setup matches the published PRD backbone.
- The audit stays small and actionable instead of turning into a generic cleanup list.

## Out of Scope

- Rewriting the setup automatically without user request.
- Deep product or architecture review beyond what the local contracts claim.

## Related Sources

- `~/.codex/skills/lv0-home-codex-health/SKILL.md`
- `~/.codex/skills/lv0-home-codex-health/references/claude-to-codex.md`
- `~/.codex/knowledge/setup-prd/home-setup.md`

## Last Checked

- 2026-03-15
