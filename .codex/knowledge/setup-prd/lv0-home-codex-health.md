# Lv0 Home Codex Health PRD

## Purpose

Define the expected behavior for auditing Codex home, repo, or umbrella-workspace setup for drift, context bloat, safety gaps, and verification gaps.

## Desired State

- The audit reads the smallest relevant contracts before judging the setup.
- Home audits compare the observed state against `setup-prd/home-setup.md`, `~/.codex/.local-work/current.md`, and any relevant `lv0`/`lv1` PRDs in the live home control layer.
- Home audits compare the observed state against `setup-prd/home-setup.md`, `~/.codex/.local-work/current.md`, and any relevant `lv0`/`lv1` PRDs in the live home control layer.
- Repo audits read the nearest repo or umbrella-root `AGENTS.md`, `.local-work/current.md`, the repo knowledge root when defined, and any repo-local `setup-prd/` entries for `lv2` skills.
- When a repo uses feature PRDs, the audit also reads the feature PRDs and the matching feature tracker notes.
- Umbrella repo audits use the explicit `Child Repos` list as the traversal source of truth and then apply the normal repo-audit checks to each listed child repo.
- Findings are prioritized into `Critical`, `Structural`, and `Incremental`.
- Each finding explains what is wrong, where it lives, why it matters, and the smallest fix.
- Exported home mirror repos stay out of the default audit path, except for a narrow comparison between this machine's live home setup and the current remote state of the canonical mirror `jcl2018/home-setup`.

## Audit Checklist

- Confirm home and repo contracts are short, scoped, and non-duplicative.
- Check whether the required home and repo tracking docs exist and match the published read and refresh rules.
- For umbrella roots, check whether `Child Repos` is present, explicit, relative, and limited to real child git repos.
- Check whether skill docs point to the matching PRDs instead of embedding bulky detailed rules.
- Check whether `lv0`/`lv1` skills have matching home PRDs.
- Check whether repos with `lv2` skills also have a repo knowledge root and matching repo-local PRDs.
- Check whether repos that use feature PRDs also keep a matching feature tracker note for each PRD.
- When the canonical home mirror is reachable, verify the live tracked home-control files are consistent with the current remote state of `jcl2018/home-setup` or explain why the remote comparison could not run.
- When the canonical home mirror is portability-normalized, apply the same normalization to the live home snapshot before deciding whether drift exists.
- Verify done-conditions and verification guidance map to real commands.

## Success Criteria

- The audit identifies the highest-leverage reliability and context issues first.
- The audit can explain whether the current setup matches the published PRD backbone at both the umbrella root and child-repo levels when applicable.
- The audit stays small and actionable instead of turning into a generic cleanup list.

## Out of Scope

- Rewriting the setup automatically without user request.
- Auto-discovering child repos beyond an explicit umbrella-root list.
- Auto-exporting or pushing the mirror repo as part of an audit.
- Deep product or architecture review beyond what the local contracts claim.
- Performing a full mirror-repo hygiene review beyond tracked home-control consistency unless the user explicitly asks.

## Related Sources

- `~/.codex/skills/lv0-home-codex-health/SKILL.md`
- `~/.codex/skills/lv0-home-codex-health/references/claude-to-codex.md`
- `~/.codex/knowledge/setup-prd/home-setup.md`

## Last Checked

- 2026-03-16
