# CLAUDE.md — home-setup

This repo exists to make the Claude/Codex home delta legible.

It should tell you:
- which workflow repos are tracked upstreams
- which home customizations are yours
- which live surfaces are just archived
- and let repo-local `/home-retro` reduce drift safely

`gstack` on both sides is snapshot-only here; upgrade and manage the live installs separately.

## Commands

```bash
./sync.sh status --host codex --format json   # machine-readable Codex drift
./sync.sh push --host codex --scope repo-owned
./sync.sh pull --host codex --scope backup-only
python3 ./home_health.py --host codex
python3 -m unittest discover -s tests -p 'test_*.py'
```

## Layout

- `claude/settings.json` — global settings (redacted secrets)
- `claude/CLAUDE.md` — global CLAUDE.md archive (pulled from `~/.claude/CLAUDE.md`)
- `claude/skills/gstack/` — upstream gstack snapshot (DON'T edit, never pushed)
- `claude/templates/` — reusable CLAUDE.md templates for new projects
- `claude/projects/` — per-project memory backup
- `codex/config.toml` — curated Codex config
- `codex/AGENTS.md` — curated Codex home contract
- `codex/skills/gstack/` — upstream Codex gstack snapshot (DON'T edit, never pushed)
- `home-inventory.json` — host-scoped contract for tracked upstreams, customizations, and backups
- `home_health.py` — repo-local retro reconcile helper
- `.claude/skills/home-retro/` — project-local Claude `/home-retro` wrapper
- `.agents/skills/home-retro/` — project-local Codex `/home-retro` wrapper

## Rules

- Never edit either `*/skills/gstack/` snapshot directly.
- From Codex, `/home-retro` should only inspect and reconcile Codex-side state.
- From Claude, `/home-retro` should only inspect and reconcile Claude-side state.
- Prefer `/home-retro` for routine hygiene; use upstream `/retro` for engineering-only retros.
- `./sync.sh push` is only for repo-owned surfaces.
- `./sync.sh pull` is only for backup refreshes when scoped that way.
- `gstack` snapshots are backup-only. `push` does not install or overwrite them.

## Testing

Use the repo-native regression suite:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```
