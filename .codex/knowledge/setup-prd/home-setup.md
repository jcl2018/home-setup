# Home Setup PRD

## Purpose

Define the desired state for the Codex home control layer so audits and future edits can compare the current setup against a stable contract.

## Desired State

- `~/AGENTS.md` stays short, global, and cross-repo only.
- `~/.codex/config.toml` stays minimal and does not absorb workflow guidance.
- Reusable workflows live in `~/.codex/skills/`, with `lv0-home-*` for home control logic, `lv1-workflow-*` for reusable cross-repo workflows, and `lv2-<repo>-*` for repo-local reusable workflows.
- Home-control work keeps a required tracking doc at `~/.codex/.local-work/current.md`, read immediately after `~/AGENTS.md`.
- Substantial work begins with a minimal 1-2 line context snapshot that names only the active sources in play and the current verification plan.
- Home knowledge lives under `~/.codex/knowledge/`, with `~/.codex/knowledge/setup-prd/` reserved for home and workflow PRDs.
- Repo work keeps a required tracking doc at `<repo>/.local-work/current.md`, read immediately after the nearest repo `AGENTS.md`.
- Repo-specific build, test, architecture, safety, and deep-dive knowledge stays in the repo, not in home files.
- Automations are optional and used for periodic review, not as the primary way to remember workflow rules.
- Snapshot and restore treat the home control layer as a separate portable asset from normal coding repos.

## Audit Checklist

- Home instructions are split cleanly between `~/AGENTS.md`, skill docs, and on-demand knowledge.
- `~/.codex/.local-work/current.md` exists, stays concise, and is refreshed after material state changes and before pause or handoff.
- `~/AGENTS.md` requires a minimal context snapshot at the start of substantial work instead of a heavy always-loaded checklist.
- Every existing `lv0` and `lv1` skill has a matching PRD in `~/.codex/knowledge/setup-prd/`.
- Shared global notes outside `setup-prd/` stay concise and cross-repo.
- Repo contracts require `.local-work/current.md` in every repo and define the exact read and refresh triggers.
- Any repo that introduces `lv2` skills defines a repo knowledge root and keeps matching PRDs under `<repo-knowledge-root>/setup-prd/`.
- Export and restore include `~/.codex/.local-work/current.md`, `~/.codex/knowledge/`, and no longer depend on a standalone home summary file.

## Success Criteria

- Future sessions can discover home workflow expectations by reading the smallest relevant contract.
- Audits can compare the current home setup against a clear checklist without relying on ad hoc summary files.
- The home control layer remains small, composable, and portable across machines.

## Out of Scope

- Repo-specific implementation detail and project-local commands.
- Volatile runtime state such as sessions, caches, auth, or sqlite files.
- Turning PRDs into full execution manuals; the skill docs remain the operational guides.

## Related Sources

- `~/AGENTS.md`
- `~/.codex/knowledge/INDEX.md`
- `~/.codex/knowledge/work-start-checklist.md`
- `~/.codex/skills/`
- Reference repo: `https://github.com/tw93/claude-health`

## Last Checked

- 2026-03-15
