# Lv1 Workflow Feature Dev PRD

## Purpose

Define the expected cross-repo workflow for delivering one or more feature items with a complete per-item PRD and a durable per-item implementation tracker.

## Desired State

- A reusable home `lv1-workflow-feature-dev` skill exists for local repo work.
- Multi-item requests are split into separate feature items with stable slugs.
- Each feature item has a complete PRD under the repo knowledge root.
- Each feature item has a detailed progress note at `.local-work/feature/<slug>.md` or a documented repo-specific equivalent.
- Repo-level `.local-work/current.md` remains the required session tracker and points to the active feature notes instead of absorbing all feature detail.
- The default feature-doc convention is `<repo-knowledge-root>/features/<slug>.md` paired with `.local-work/feature/<slug>.md`.
- If a repo uses a non-default convention, the mapping is documented so audits can still verify it.
- Repo audits can detect feature PRDs that are missing a matching tracker note.

## Audit Checklist

- The skill tells the agent to read the repo contract and repo-level tracking doc first.
- The skill defines how to split grouped requests into separate feature items.
- The skill requires both a complete PRD and a detailed tracker per feature item.
- The skill keeps the repo-level `.local-work/current.md` requirement intact.
- The skill points to reusable PRD and progress templates instead of embedding long examples in `SKILL.md`.
- The default PRD-to-tracker mapping is explicit and auditable.
- The home audit workflow knows to check the mapping when repos use this feature-doc convention.

## Success Criteria

- Another session can resume an active feature item quickly from the PRD plus its feature tracker.
- Multi-item delivery does not collapse into a single ambiguous planning note.
- Repo audits can flag missing tracker notes before the workflow drifts.

## Out Of Scope

- Defining repo-specific product strategy or architecture.
- Replacing the repo-level `.local-work/current.md`.
- Forcing every repo to adopt the default path when it already has an explicit equivalent convention.

## Related Sources

- `~/.codex/skills/lv1-workflow-feature-dev/SKILL.md`
- `~/.codex/skills/lv1-workflow-feature-dev/references/feature-prd-template.md`
- `~/.codex/skills/lv1-workflow-feature-dev/references/feature-progress-template.md`
- `~/.codex/skills/lv0-home-codex-health/SKILL.md`

## Last Checked

- 2026-03-16
