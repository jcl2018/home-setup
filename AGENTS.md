# Home Setup Project Contract

## Scope

- This repo is a documentation-first reference for the home-level Codex setup under `~`.
- `docs/` explains the design logic, current catalog, adoption flow for an existing machine, and the local repo workflow supported by this setup.
- `templates/` holds example rendered files for the shared parts of the setup. Treat them as reference material or optional clean-machine bootstrap input, not the default migration path.

## Safety

- Never add secrets, auth tokens, shell history, SSH keys, caches, logs, SQLite state, or session snapshots.
- Keep absolute home paths templated as `__HOME__` inside `templates/`; `scripts/install.sh` may render them for optional bootstrap use.
- Prefer examples and placeholders for environment variables instead of checked-in real values.

## Verification

- Run `./scripts/check-export.sh` after changing docs, audit logic, templates, or install logic.
- If you change `scripts/audit-home.sh`, verify it against both the current home folder and a sparse temp home.
- If you change install behavior, also run `./scripts/install.sh --target-home "$(mktemp -d)" --with-automation` as a smoke test and report the result as secondary verification.

## Maintenance

- Keep the docs authoritative about intent and workflow.
- Keep custom home skills under `templates/.codex/skills/`.
- Do not vendor Codex runtime state such as `auth.json`, `logs_*.sqlite`, `state_*.sqlite*`, `models_cache.json`, `sessions/`, or `shell_snapshots/`.
- Keep the Brew bundle minimal and tied to what this setup actually relies on.
