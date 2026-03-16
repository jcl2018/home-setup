---
name: lv1-workflow-repo-bootstrap
description: Bootstrap a local software repository for reliable future Codex work. Use when Codex needs to onboard an existing local repo, inspect its stack and verification commands, create or tighten the repo's AGENTS.md and lightweight AI docs, or scaffold a brand-new repo from scratch with an initial structure, local workflow, and validation path.
---

# Repo Bootstrap

## Overview

Use this skill to make a repo easy for future Codex sessions to understand and work in. Favor the smallest reliable setup that produces a real working contract, a clear verification path, and a short summary of what matters.

## Workflow Decision

1. If the target already has source files, manifests, or a `.git` directory, treat it as an existing repo and read [references/existing-repo.md](references/existing-repo.md).
2. If the user wants a greenfield project or the target folder is empty, treat it as a new repo and read [references/new-repo.md](references/new-repo.md).
3. If the task is mostly about creating or tightening the repo contract, also consult [$lv1-workflow-project-contract](__HOME__/.codex/skills/lv1-workflow-project-contract/SKILL.md).
4. If the task will end with unfinished work that should survive sessions, also consult [$lv1-workflow-session-handoff](__HOME__/.codex/skills/lv1-workflow-session-handoff/SKILL.md).

## Common Rules

- Read the nearest repo `AGENTS.md` before editing if one exists.
- Identify the smallest real verification command early and rerun it after meaningful changes.
- Keep the repo root `AGENTS.md` short; move longer guidance into repo docs such as `docs/ai/`.
- If the repo needs reusable deep-dive notes, keep them under a single repo knowledge root such as `docs/ai/knowledge/` and name any non-default location in the repo `AGENTS.md`.
- Prefer official framework scaffolds or standard generators over hand-rolled boilerplate unless the user asks for a custom layout.
- Do not create extra docs just because a template exists. Add `docs/ai/`, `.local-work/current.md`, or architecture notes only when they will be reused.
- Make reasonable assumptions when the user omits details, but record them in the final summary.
- When versions, framework commands, or templates may have changed, verify them from primary sources instead of relying on memory.

## Expected Outcomes

For an existing repo, aim to leave behind:

- A short repo map: stack, package manager, key entrypoints, and real verification commands.
- A created or tightened `AGENTS.md` if the repo lacks a reliable local contract.
- Optional supporting docs only where they reduce repeated rediscovery.
- At least one verification command that has actually run.

For a new repo, aim to leave behind:

- A working scaffold or starter structure appropriate to the requested stack.
- Minimal commands for setup, run, build, test, or lint as applicable.
- A repo-local `AGENTS.md` created after the scaffold settles.
- A concise note of assumptions, follow-up work, and exact verification performed.

## How To Grow This Skill

Start with instructions and references only. Add more only when repetition proves they are worth it:

- Add `assets/` if you repeatedly create the same repo skeleton, starter files, or docs.
- Add `scripts/` if you keep redoing deterministic repo inspection or setup tasks.
- Add more `references/` only for stack-specific playbooks you expect to reuse often.

Keep the main `SKILL.md` focused on decision-making and workflow. Push longer checklists and stack-specific details into reference files.
