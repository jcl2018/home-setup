# Design Logic

This repo documents the reference design for a portable shared Codex layer. The goal is not to clone one machine exactly. The goal is to preserve the shared Codex logic so another machine can duplicate the same control layer without copying machine-local state.

## Core Design

- Keep the always-loaded home contract small.
- Put reusable but low-frequency workflows into skills.
- Keep deeper notes on demand instead of always in root context.
- Let each actual repo own its own build, test, architecture, and safety rules.
- Keep secrets and runtime state local to each machine.

## Portable Shared Codex Layer

### `~/AGENTS.md`

The root home contract is intentionally short. It sets global working defaults, verification expectations, safety rails, and the skill-routing rules that should apply across repos.

### `~/.codex/config.toml`

This is minimal runtime configuration for Codex itself. It should stay small and stable.

### `~/.codex/skills/`

This holds the custom shared workflows that should not live in `~/AGENTS.md`. The current setup uses `lv0-home-*` for home-level workflows and `lv1-workflow-*` for reusable repo workflows.

### `~/.codex/knowledge/`

This is for compact, on-demand notes. Global notes belong here only when the information is stable across multiple repos and worth reusing. Repo-specific deep dives should live inside the repo instead.

### `~/.codex/automations/`

Automation is optional. In the current reference model it is used for a weekly Codex health review, not for every day-to-day edit.

These portable items are the part of the setup that should duplicate cleanly across machines, including Windows under `%USERPROFILE%`.

## Platform-Specific Integration

### Unix/mac reference files

- `~/.gitconfig`
  Minimal shared Git defaults.
- `~/.zprofile`
  Homebrew shell bootstrap plus a hook for `~/.config/home-setup/secrets.zsh`.
- `~/.config/home-setup/secrets.zsh.example`
  Example local secrets file for Unix-style shell setup.

The Unix/mac installer and audit include these files in addition to the portable shared Codex layer.

### Windows duplication flow

- The Windows PowerShell installer copies only the portable shared Codex layer plus optional automation.
- It intentionally skips `.gitconfig`, `.zprofile`, Homebrew, and the Unix `secrets.zsh` hook.
- When the installer renders `__HOME__`, it uses a slash-normalized absolute home path such as `C:/Users/name` so Markdown links inside skills, summaries, and automation prompts still work.

### `~/.config/home-setup/secrets.zsh`

This is the machine-local override point. It is where secrets, local environment variables, and host-specific shell differences belong. It is intentionally outside the shared reference model.

## Docs Versus Templates

- `docs/` is the authoritative explanation of the setup.
- `templates/` is the source for the shared files that installers render onto target machines.
- `config/reference-paths.tsv` is the inventory that tells the Unix/mac and Windows installers and audits which template roots are portable shared, Unix/mac-only, or optional automation.
- `scripts/audit-home.sh` is the default way to compare an existing Unix/mac machine to the reference model.
- `scripts/install.sh` is an optional Unix/mac bootstrap helper, not the primary workflow for an already-lived-in home folder.
- `scripts/audit-home.ps1` and `scripts/install.ps1` are the Windows duplication tools for the portable shared layer.

## Boundaries

- This repo owns shared home-level intent.
- This repo does not own machine-local auth, logs, caches, sessions, or secrets.
- This repo does not promise full shell or package-manager parity across operating systems.
- This repo does not own repo-specific commands or architecture.
- If a repo has its own `AGENTS.md` or local AI docs, that repo remains the source of truth for local work.

## Local Repo Workflow

This home setup also supports local repo work:

- start with the nearest repo `AGENTS.md`
- use the `lv1-workflow-*` skills when onboarding or tightening repo workflow
- find a real verification command before editing
- keep repo contracts and deep repo docs inside the repo

See [local-repo-workflow.md](local-repo-workflow.md) for the working model.
