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
- `PHILOSOPHY.md` — why this repo exists and how you think about agentic workflows
- `profiles/` — per-machine reference specs (personal-mac.md, work-windows.md)
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
- Read PHILOSOPHY.md before making structural changes.
- Each machine gets its own profile in profiles/.

## Adding an Upstream

To track a new upstream in `home-inventory.json`, add an entry to the relevant host's `tracked_upstreams` array using this schema:

```json
{
  "id": "example-tool",
  "label": "Example Tool",
  "kind": "directory",
  "repo_path": "claude/skills/example-tool",
  "live_path": "~/.claude/skills/example-tool",
  "sync_scope": "backup-only",
  "owner": "upstream",
  "freshness": ["snapshot", "upstream"],
  "repo_url": "https://github.com/org/example-tool",
  "install_method": "git",
  "version_file": "~/.claude/skills/example-tool/VERSION",
  "update_check_bin": "~/.claude/skills/example-tool/bin/update-check"
}
```

Required fields: `id`, `label`, `kind`, `repo_path`, `live_path`, `sync_scope`.

Optional fields:
- `repo_url` — GitHub URL for the upstream repo
- `install_method` — how the upstream is installed (`git`, `vendored`, etc.)
- `version_file` — path to a file containing the version string; used for snapshot-vs-live comparison
- `update_check_bin` — path to a binary that checks for upstream updates (prints `UPGRADE_AVAILABLE old new` or nothing); if absent, only snapshot-vs-live comparison runs

Fallback behavior: upstreams without `update_check_bin` compare `VERSION` files only. If no `VERSION` file either, freshness is reported as `upstream_unknown`.

No code changes to `home_health.py` are needed to add a new upstream — the existing reconcile loop reads `tracked_upstreams` generically.

## Testing

Use the repo-native regression suite:

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```
