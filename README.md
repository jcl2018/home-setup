# Portable Codex Home Layer

This repo is a documentation-first reference for a portable shared Codex layer. It captures the global Codex contract, shared skills, knowledge notes, and optional automation that can be duplicated across machines without copying secrets or runtime state.

## Start Here

Use one of these paths depending on what you need:

1. Understand the setup design:
   [docs/design-logic.md](docs/design-logic.md)
2. Inspect what is currently part of the reference model:
   [docs/setup-catalog.md](docs/setup-catalog.md)
3. Duplicate the portable shared layer onto a Windows machine:
   [docs/duplicate-to-windows.md](docs/duplicate-to-windows.md)
4. Audit an existing Unix/mac machine against the reference:
   `./scripts/audit-home.sh`
5. Adopt selected parts on an existing Unix/mac machine:
   [docs/adopt-existing-machine.md](docs/adopt-existing-machine.md)
6. Understand how this home setup supports local repo work:
   [docs/local-repo-workflow.md](docs/local-repo-workflow.md)
7. Read the product intent for local repo support:
   [docs/local-repo-prd.md](docs/local-repo-prd.md)

## What This Repo Owns

- Design intent for the portable shared Codex layer
- Reference templates for shared files under `templates/`
- Install and audit inventories under `config/reference-paths.tsv`
- Custom home skills under `templates/.codex/skills/`
- Shared knowledge note starters under `templates/.codex/knowledge/`
- Optional automation reference under `templates/.codex/automations/`
- Unix/mac and Windows install and audit scripts under `scripts/`

## What This Repo Does Not Own

- secrets and API keys
- `~/.codex/auth.json`
- Codex logs, caches, and SQLite state
- session snapshots and shell history
- SSH keys and other personal credentials
- repo-specific build, test, and architecture rules
- full Windows shell or package-manager parity with the source machine

## Windows Duplication Workflow

On a Windows machine that has cloned this repo, use the PowerShell audit and installer:

```powershell
pwsh -NoLogo -NoProfile -File .\scripts\audit-home.ps1
pwsh -NoLogo -NoProfile -File .\scripts\install.ps1
```

Add `-WithAutomation` if you also want the weekly Codex health automation. The Windows flow copies only the portable shared Codex layer and skips `.gitconfig`, `.zprofile`, Brew/Homebrew setup, and the Unix local secrets hook.

The underlying scripts are [scripts/audit-home.ps1](scripts/audit-home.ps1) and [scripts/install.ps1](scripts/install.ps1).

See [docs/duplicate-to-windows.md](docs/duplicate-to-windows.md) for the full walkthrough and post-install local-only steps.

## Unix/mac Workflow

For an already-lived-in Unix/mac machine, start with a read-only audit:

```sh
./scripts/audit-home.sh
```

Then follow the compare-and-merge guidance in [docs/adopt-existing-machine.md](docs/adopt-existing-machine.md).

## Optional Unix/mac Bootstrap

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
