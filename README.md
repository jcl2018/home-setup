# Home Setup Reference Repo

This repo is a documentation-first reference for a home-level Codex setup. It captures the design logic, the current shared skills and automation, and a safe compare-and-adopt path for a new machine that already has its own home folder state.

## Start Here

Use one of these paths depending on what you need:

1. Understand the setup design:
   [docs/design-logic.md](docs/design-logic.md)
2. Inspect what is currently part of the reference model:
   [docs/setup-catalog.md](docs/setup-catalog.md)
3. Audit an existing machine against the reference:
   `./scripts/audit-home.sh`
4. Adopt selected parts on an existing machine:
   [docs/adopt-existing-machine.md](docs/adopt-existing-machine.md)
5. Understand how this home setup supports local repo work:
   [docs/local-repo-workflow.md](docs/local-repo-workflow.md)
6. Read the product intent for local repo support:
   [docs/local-repo-prd.md](docs/local-repo-prd.md)

## What This Repo Owns

- Design intent for the shared home setup
- Reference templates for shared files under `templates/`
- Custom home skills under `templates/.codex/skills/`
- Shared knowledge note starters under `templates/.codex/knowledge/`
- Optional automation reference under `templates/.codex/automations/`
- Read-only auditing and safety verification scripts under `scripts/`

## What This Repo Does Not Own

- secrets and API keys
- `~/.codex/auth.json`
- Codex logs, caches, and SQLite state
- session snapshots and shell history
- SSH keys and other personal credentials
- repo-specific build, test, and architecture rules

## Default Workflow For A New Machine

For an already-lived-in machine, start with a read-only audit:

```sh
./scripts/audit-home.sh
```

Then follow the compare-and-merge guidance in [docs/adopt-existing-machine.md](docs/adopt-existing-machine.md).

## Optional Clean-Machine Bootstrap

If you want a faster starting point on a cleaner machine, the installer is still available as a secondary convenience:

```sh
./scripts/install.sh --brew
```

Add `--with-automation` if you also want the weekly Codex health automation rendered into `~/.codex/automations/`.

## Local Repo Workflow

This home setup also defines a lightweight way to work in local repos. The short version is:

- keep home-level rules in `~/AGENTS.md`
- let each repo own its own `AGENTS.md`, verification, and architecture details
- use the `lv1-workflow-*` skills when onboarding or tightening repo workflows

See [docs/local-repo-workflow.md](docs/local-repo-workflow.md) for the full reference.
The product intent behind that workflow lives in [docs/local-repo-prd.md](docs/local-repo-prd.md).

## Verify Changes

```sh
./scripts/check-export.sh
```
