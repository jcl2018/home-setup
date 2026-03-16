# New Repo Bootstrap

Use this path when the user wants a project created from scratch or the target folder is effectively empty.

## Checklist

1. Clarify the goal, stack, and deployment shape if the user already provided them.
2. Make the smallest safe assumptions if some choices are missing.
3. Prefer an official or standard scaffold for the chosen stack.
4. Add only the minimum project files needed to start building.
5. Create the repo-local `AGENTS.md` after the scaffold exists.
6. Run a real smoke test or verification command.

## Gather The Minimum Inputs

Try to resolve these quickly from the request or from reasonable defaults:

- Product type: CLI, library, API, web app, automation, data project.
- Preferred language or framework.
- Package manager or build tool.
- Whether the repo should start with git.
- Whether tests, linting, formatting, CI, or containerization are expected immediately.

If the user leaves some of these unspecified, choose conservative defaults and record them in the final summary instead of blocking.

## Prefer Standard Scaffolds

When the framework has an official or widely accepted bootstrap command, prefer that over handwritten boilerplate. This usually gives better defaults, working scripts, and easier upgrades.

Only hand-roll the initial structure when:

- The user asks for a custom layout.
- The project is intentionally minimal.
- The ecosystem does not have a stable scaffold worth using.

When scaffold commands are version-sensitive, verify them from primary sources before running them.

## Add The Repo Contract After The Scaffold

Once the project files exist, create or update `AGENTS.md` with:

- The actual setup, run, build, test, lint, and format commands.
- Any important architecture or directory boundaries.
- The lightest verification rules for common task types.

Keep the contract short and push details into repo docs only when the repo becomes complex.

## Good Default Outputs

A strong first pass usually leaves:

- A working scaffold with dependency manager metadata.
- A short `README.md` or equivalent quick-start note if the scaffold does not already provide one.
- A repo-local `AGENTS.md`.
- Optional `docs/ai/` notes only if the structure is non-obvious.

## Done Condition

Before finishing, provide:

- The assumptions you made.
- The exact commands used to scaffold and verify the repo.
- The next one or two recommended follow-up steps.
