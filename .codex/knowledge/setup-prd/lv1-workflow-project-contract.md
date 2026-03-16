# Lv1 Workflow Project Contract PRD

## Purpose

Define the desired state for a repo or umbrella-root `AGENTS.md` so each scope has a small, executable local contract with a clear knowledge root and `lv2` PRD convention.

## Desired State

- A repo `AGENTS.md` captures only repo-specific always-loaded rules.
- An umbrella root `AGENTS.md` may capture shared always-loaded rules plus an explicit `Child Repos` section with relative paths only.
- Verification guidance points to real commands.
- The repo contract requires `.local-work/current.md` and states exactly when it is read and refreshed.
- The repo names its knowledge root when it keeps durable repo-local notes.
- If the repo uses any `lv2-<repo>-*` skills, the repo contract requires matching PRDs under `<repo-knowledge-root>/setup-prd/`.
- Long reference material lives in repo docs, not in the root contract.

## Audit Checklist

- The repo contract avoids duplicating home-level rules.
- Umbrella root contracts keep child-repo paths explicit and avoid duplicating child build or test commands.
- The tracking doc rule is explicit and consistent with the home-level workflow.
- The knowledge root is explicit when non-trivial repo notes or `lv2` skills exist.
- The repo contract is short enough to survive context pressure.
- The contract points future work toward repo-local PRDs when `lv2` skills exist.

## Success Criteria

- A new session can understand how to work in the repo from the local contract alone.
- A new session can understand whether the root is an umbrella workspace and which child repos it owns from the local contract alone.
- Repo-local `lv2` skill contracts are discoverable without storing repo detail in home files.

## Out of Scope

- Replacing deeper repo docs or architecture notes.
- Moving child-repo implementation detail into an umbrella root contract.
- Inventing repo-local PRDs when the repo does not actually use `lv2` skills.

## Related Sources

- `~/.codex/skills/lv1-workflow-project-contract/SKILL.md`
- `~/.codex/skills/lv1-workflow-project-contract/references/agent-template.md`

## Last Checked

- 2026-03-16
