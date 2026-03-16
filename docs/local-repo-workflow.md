# Local Repo Workflow

This home setup includes a lightweight model for working in local repos. It does not replace repo-specific docs. It just sets the home-level habits and shared workflows that make repo work more reliable.

## Where Repos Typically Live

On the current reference machine, local repos live under `~/Documents/projects/`. Treat that as a preference, not a hard requirement. The important part is having a stable place for repos so the workflow is predictable.

## Starting Work In A Repo

1. Clone or create the repo in your preferred local workspace.
2. Read the nearest `AGENTS.md` before editing.
3. If present, read `.local-work/current.md` after `AGENTS.md` when resuming multi-session work.
4. Inspect the repo shape: `README`, manifests, tests, and top-level directories.
5. Find the lightest real verification command before editing.
6. Mention the active context sources before substantial work.

The work-start reminder in `~/.codex/knowledge/work-start-checklist.md` exists to reinforce this flow.

## Shared Skills For Repo Work

- `lv1-workflow-repo-bootstrap`
  Use when onboarding an existing repo or scaffolding a new one.
- `lv1-workflow-project-contract`
  Use when creating or tightening a repo `AGENTS.md`.
- `lv1-workflow-repo-knowledge-capture`
  Use when saving a reusable repo deep dive inside the repo.
- `lv1-workflow-session-handoff`
  Use when work is unfinished and should be easy to resume later.

These are home-level reusable workflows. They help with repo work, but they do not replace repo-local truth.

## Boundaries

- Home-level rules belong in `~/AGENTS.md`.
- Repo build, test, architecture, and safety rules belong in the repo.
- Repo-local deep dives belong in repo docs such as `docs/ai/knowledge/` when the repo uses that pattern.
- If repo docs and home notes disagree, the repo wins.

## New Local Repos

When you are starting a brand-new repo:

- prefer an official scaffold or standard generator when the stack has one
- let the scaffold settle first
- then add or tighten the repo `AGENTS.md`
- record real setup and verification commands in the repo itself

## Existing Local Repos

When you adopt an existing repo:

- map the real stack and verification commands
- avoid bloating the repo root contract
- move deeper reusable detail into repo docs only when it will actually save time later
- keep the home-level setup focused on cross-repo workflow, not repo-specific policy
