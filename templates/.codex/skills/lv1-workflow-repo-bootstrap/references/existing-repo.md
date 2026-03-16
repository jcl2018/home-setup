# Existing Repo Onboarding

Use this path when the folder already contains code, manifests, or git history.

## Checklist

1. Inspect the repo shape.
2. Identify the real development and verification commands.
3. Create or tighten the repo contract only where needed.
4. Add lightweight supporting docs if they will save repeated rediscovery.
5. Run the smallest useful verification command before finishing.

## Inspect The Repo Shape

Start by learning the minimum needed to work safely:

- Top-level files and directories.
- Primary languages and frameworks.
- Package manager and runtime.
- Entry points, app folders, and test locations.
- Existing AI docs such as `AGENTS.md`, `docs/ai/`, or `.local-work/current.md`.
- Existing CI or scripts that reveal the intended verification path.

Good places to inspect:

- Build manifests such as `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `Gemfile`.
- Lockfiles only to infer the package manager, not to edit unless required.
- `README.md`, CI workflows, Docker files, and test config files.

## Derive The Working Contract

Create or update the repo's `AGENTS.md` only if the repo lacks a clear local contract or the current one is stale.

Include only durable repo-specific guidance:

- Build, test, lint, and format commands that actually exist.
- Architecture boundaries that matter for future edits.
- Safety rails specific to this repo.
- Pointers to deeper docs when the root contract would otherwise get noisy.

Avoid:

- Repeating global home-folder rules.
- Copying long architecture docs into `AGENTS.md`.
- Inventing commands that do not exist in the repo.

If the task is mostly contract work, use [$lv1-workflow-project-contract](__HOME__/.codex/skills/lv1-workflow-project-contract/SKILL.md) for the template and decision rules.

## Add Supporting Docs Sparingly

Create supporting docs only when they reduce future rediscovery. Useful examples:

- `docs/ai/overview.md` for a quick architecture map.
- `docs/ai/commands.md` for non-obvious command recipes.
- `.local-work/current.md` when the work is likely to span sessions.

Do not add all of these by default.

## Done Condition

Before finishing, provide:

- The detected stack and package manager.
- The exact verification command that ran.
- The files created or updated.
- Any assumptions or gaps that still need user input.
