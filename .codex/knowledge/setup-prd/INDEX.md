# Setup PRD Index

- Scope: home control-layer expectations and workflow contracts for `lv0-home-*` and `lv1-workflow-*` skills.
- When to use this note: when auditing or revising the home setup, a home/workflow skill, or the repo-local PRD convention for future `lv2` skills.
- Related sources: `~/AGENTS.md`, `~/.codex/knowledge/INDEX.md`, `~/.codex/skills/`
- Last checked: 2026-03-15

## Conventions

- PRDs are the source of truth for desired state, audit checklist, and success criteria.
- `SKILL.md` files stay lean and describe when to use the skill plus the operational workflow.
- `lv0` and `lv1` PRDs live in this directory and match the skill name exactly.
- Future `lv2-<repo>-*` PRDs live under `<repo-knowledge-root>/setup-prd/`, with one PRD per skill plus a repo-local `setup-prd/INDEX.md`.

## Home Control Layer

- [home-setup](home-setup.md)

## Lv0 Skills

- [lv0-home-codex-health](lv0-home-codex-health.md)
- [lv0-home-codex-settings-export](lv0-home-codex-settings-export.md)
- [lv0-home-codex-settings-restore](lv0-home-codex-settings-restore.md)
- [lv0-home-global-knowledge-capture](lv0-home-global-knowledge-capture.md)
- [lv0-home-shared-context](lv0-home-shared-context.md)

## Lv1 Skills

- [lv1-workflow-project-contract](lv1-workflow-project-contract.md)
- [lv1-workflow-repo-bootstrap](lv1-workflow-repo-bootstrap.md)
- [lv1-workflow-repo-knowledge-capture](lv1-workflow-repo-knowledge-capture.md)
- [lv1-workflow-session-handoff](lv1-workflow-session-handoff.md)
