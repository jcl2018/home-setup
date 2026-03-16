# Lv1 Workflow Repo Knowledge Capture PRD

## Purpose

Define how durable repo-local knowledge is captured, including the special PRD workflow for repo-specific `lv2` skills.

## Desired State

- Repo-local knowledge lives under a single knowledge root chosen from the repo contract.
- Normal deep-dive notes use the smallest useful scope such as repo overview, module, flow, or hotspot cluster.
- Repo-specific `lv2` skills use `<repo-knowledge-root>/setup-prd/<skill-name>.md` and a repo-local `setup-prd/INDEX.md`.
- `lv2` skill PRDs use the standard sections: Purpose, Desired State, Audit Checklist, Success Criteria, Out of Scope, Related Sources, Last Checked.
- All notes include source files or docs plus a `last checked` date.

## Audit Checklist

- Repo-local PRDs are kept separate from module or flow deep dives.
- The repo knowledge root matches the local contract.
- Notes summarize stable behavior and responsibilities rather than temporary branch work.
- Repo-local notes yield to the repo code and docs when they diverge.

## Success Criteria

- Future sessions can find durable repo knowledge quickly.
- Repo-specific reusable skills have a matching local contract note instead of burying expectations in the skill file alone.

## Out of Scope

- Saving repo-specific notes under `~/.codex/knowledge/`.
- Replacing repo code reading or putting build/test/safety rules in the wrong place.

## Related Sources

- `~/.codex/skills/lv1-workflow-repo-knowledge-capture/SKILL.md`

## Last Checked

- 2026-03-15
