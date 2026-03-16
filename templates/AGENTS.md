# Global Codex Contract

This file holds global preferences only. Keep repo-specific build, test, architecture, and domain rules in the repo's `AGENTS.md` or in repo docs. Do not duplicate the same rule in both places unless the repo truly needs to restate it.

## Working Defaults

- Read the nearest `AGENTS.md` before editing, then inspect the code before deciding on a change.
- If a repo has `.local-work/current.md`, read it after the nearest `AGENTS.md` before resuming or planning multi-session work.
- At the start of substantial work, briefly name the active context sources being used, such as `~/AGENTS.md`, the nearest repo `AGENTS.md`, triggered skills, or specific docs consulted for the task.
- Keep always-loaded instructions short. Move repeatable workflows and long references into skills or linked docs.
- Private home knowledge may live under `~/.codex/knowledge/` if it is loaded on demand, kept concise, and limited to global or cross-repo context. Repo-specific deep dives belong in the repo's own docs.
- Prefer custom skills in `~/.codex/skills` for non-universal workflows instead of growing this file.

## Verification

- Do not claim a task is done until the smallest relevant verification has run, or you explicitly say why it could not run.
- Report verification as exact command plus pass or fail status.
- If a repo has no verification command, say that clearly and propose the lightest useful check.

## Safety Rails

- Ask before changing secrets, auth, billing, CI, production infra, schema migrations, lockfiles, or destructive file operations.
- Do not rewrite generated or vendor files unless the task requires it.
- Before any commit, show the diff summary and call out riskier files.

## Compacting And Handoffs

When compressing or handing work off, preserve in this order:

1. Architecture decisions and constraints.
2. Files changed and why.
3. Verification status with commands.
4. Open risks, TODOs, and rollback notes.
5. Only the important result from tool output.

## Skill Routing

- Skill names use `lv0-home-*`, `lv1-workflow-*`, and `lv2-<repo>-*`.
- Use `lv0-home-codex-health` to audit home or repo Codex setup for context, safety, and verification drift.
- Use `lv0-home-shared-context` to consult the smallest matching private note under `~/.codex/knowledge/global` or repo-local knowledge docs when they exist.
- Use `lv0-home-global-knowledge-capture` to save or refresh cross-repo knowledge under `~/.codex/knowledge/global`.
- Use `lv1-workflow-project-contract` to create or tighten a repo `AGENTS.md` and supporting AI docs.
- Use `lv1-workflow-repo-knowledge-capture` to save or refresh repo-specific deep-dive notes inside the current repo, defaulting to `docs/ai/knowledge/` unless the repo contract says otherwise.
- Use `lv1-workflow-repo-bootstrap` to onboard an existing repo or scaffold a new local repo with a reliable contract and verification flow.
- Use `lv1-workflow-session-handoff` when leaving unfinished work or resuming a stale branch.
