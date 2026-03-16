# Home Setup Project Contract

## Scope

- This repo is a documentation-first reference for a portable shared Codex layer that can be duplicated across machines.
- `docs/` explains the design logic, current catalog, Unix/mac adoption flow, Windows duplication flow, and the local repo workflow supported by this setup.
- `templates/` holds the shared files; `config/reference-paths.tsv` defines which parts are portable shared, Unix/mac-only, or optional automation.

## Safety

- Never add secrets, auth tokens, shell history, SSH keys, caches, logs, SQLite state, or session snapshots.
- Keep absolute home paths templated as `__HOME__` inside `templates/`; the install scripts render them per target machine.
- Prefer examples and placeholders for environment variables instead of checked-in real values.

## Verification

- Run `./scripts/check-export.sh` after changing docs, inventory, audit logic, templates, or install logic.
- If you change `scripts/audit-home.sh`, verify it against both the current home folder and a sparse temp home.
- If you change `scripts/install.sh`, also run `./scripts/install.sh --target-home "$(mktemp -d)" --with-automation` as a smoke test and report the result as secondary verification.
- If you change `scripts/install.ps1`, `scripts/audit-home.ps1`, or the Windows duplication docs, make sure the PowerShell smoke tests inside `./scripts/check-export.sh` pass when `pwsh` is available.

## Maintenance

- Keep the docs authoritative about intent and workflow.
- Keep `config/reference-paths.tsv` aligned with the template set and installer behavior.
- Keep custom home skills under `templates/.codex/skills/`.
- Do not vendor Codex runtime state such as `auth.json`, `logs_*.sqlite`, `state_*.sqlite*`, `models_cache.json`, `sessions/`, or `shell_snapshots/`.
- Keep the Brew bundle minimal and tied to what this setup actually relies on.
