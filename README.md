# home-setup

This repo exists to make your Claude and Codex home delta legible.

It does 4 jobs:
- back up the important live home state
- show which home customizations are uniquely yours
- track the upstream workflow repos you intentionally depend on
- let repo-local `/home-retro` reduce drift automatically in the right direction

`gstack` on both hosts is tracked here as an upstream dependency. Its snapshots are backup-only in this repo, not push-managed.

## Layout

```text
home-setup/
├── .agents/
│   └── skills/
│       └── home-retro/                  ← project-local Codex /home-retro wrapper
├── .claude/
│   └── skills/
│       └── home-retro/                  ← project-local Claude /home-retro wrapper
├── claude/
│   ├── settings.json                    ← global settings (redacted secrets)
│   ├── CLAUDE.md                        ← global CLAUDE.md archive
│   ├── skills/
│   │   └── gstack/                      ← upstream gstack snapshot (don't edit)
│   ├── templates/                       ← reusable CLAUDE.md templates
│   │   ├── python-project.md
│   │   └── terraform-project.md
│   └── projects/                        ← per-project memory backup
├── codex/
│   ├── config.toml                      ← curated Codex config
│   ├── AGENTS.md                        ← curated Codex home contract
│   └── skills/
│       └── gstack/                      ← upstream Codex gstack snapshot (don't edit)
├── home-inventory.json                  ← host-scoped source of truth for upstreams, customizations, and backups
├── home_health.py                       ← repo-local retro reconcile helper
├── sync.sh                              ← push / pull / status
├── CLAUDE.md                            ← repo instructions
└── README.md                            ← this file
```

## Quick Start

```bash
git clone <your-remote> ~/Documents/projects/home-setup
cd ~/Documents/projects/home-setup
./sync.sh status --host codex
/home-retro
```

## Repo Goal

This repo answers 3 questions:
- What upstream workflow repos do I track?
- What home customizations are mine?
- What personal state is just archived?

The inventory lives in [home-inventory.json](/Users/chjiang/Documents/projects/home-setup/home-inventory.json). It is split by host, so Codex runs only reason about Codex state and Claude runs only reason about Claude state.

## Retro Workflow

Use the commands differently:
- `/retro` — upstream gstack engineering retro only
- `/home-retro` — upstream `/retro` plus this repo's host-scoped home-health appendix

Repo-local `/home-retro` is the normal operator here:
- in Codex, it runs the upstream `/retro`, then `python3 ./home_health.py --host codex`
- in Claude, it runs the upstream `/retro`, then `python3 ./home_health.py --host claude`
- it auto-pulls backup-only drift
- it auto-pushes repo-owned drift only when the repo is on a safe baseline
- it reports upstream freshness separately from snapshot drift

`sync.sh` remains the manual escape hatch when you want direct control.

## Sync Workflow

| Command | What it does |
|---------|-------------|
| `./sync.sh push --host <claude|codex|all> --scope repo-owned` | Deploys only repo-owned curated files for the chosen host |
| `./sync.sh pull --host <claude|codex|all> --scope backup-only` | Backs up only backup-only surfaces for the chosen host |
| `./sync.sh status --host <claude|codex|all> --format json` | Emits machine-readable drift status for `home_health.py` |

**Weekly ritual:**
1. `/home-retro` — reconcile the current host automatically when it is safe
2. `git add . && git commit` — review and snapshot any backup refreshes
3. `./sync.sh status --host all` — optional full dual-host check

**New machine:**
1. `git clone && cd home-setup`
2. Install Claude, Codex, and gstack normally
3. `./sync.sh push --host all --scope repo-owned` — deploy only the repo-owned curated layer

## What Gets Backed Up

| Item | Source | Notes |
|------|--------|-------|
| `claude/settings.json` | `~/.claude/settings.json` | API keys and secrets are redacted |
| `claude/CLAUDE.md` | `~/.claude/CLAUDE.md` | Global Claude Code instructions |
| `claude/skills/gstack/` | `~/.claude/skills/gstack/` | Full Claude gstack snapshot |
| `claude/projects/*/memory/` | `~/.claude/projects/*/memory/` | Per-project memory only |
| `codex/config.toml` | `~/.codex/config.toml` | Current Codex config surface |
| `codex/AGENTS.md` | `~/AGENTS.md` | Global Codex home contract |
| `codex/skills/gstack/` | `~/.codex/skills/gstack/` | Full Codex gstack snapshot |

## What Push Manages

| Item | Destination | Notes |
|------|-------------|-------|
| `claude/templates/` | `~/.claude/templates/` | Exact mirror via `rsync --delete` |
| `codex/config.toml` | `~/.codex/config.toml` | Repo is the desired state |
| `codex/AGENTS.md` | `~/AGENTS.md` | Repo is the desired state |

`gstack` is intentionally excluded from `push` on both hosts. Keep the live installs current with their native upgrade flow, then let `/home-retro` or `./sync.sh pull --scope backup-only` snapshot them back into this repo.

## Status Model

For each host, the repo keeps 3 buckets:
- `tracked_upstreams` like `gstack`
- `customized_by_me` for repo-owned home files
- `backup_only_personal_state` for archived live state

The common statuses are:
- `in_sync`
- `needs_pull`
- `needs_push`
- `live_missing`
- `repo_missing`
- `upstream_current`
- `upstream_stale`
- `upstream_unknown`

## What's Excluded

- Build artifacts (`dist/`, `node_modules/`, `.deploy/`)
- Session data (subagent meta, tool results, SQLite state)
- Auth tokens and secrets (redacted in Claude settings)
- Live Codex runtime state (`auth.json`, history, logs, SQLite, caches)

## Creating Templates

Templates are reusable CLAUDE.md patterns for bootstrapping new projects. Add `.md` files to `claude/templates/`:

```text
claude/templates/
├── python-project.md
└── terraform-project.md
```

Use `{{project_name}}` and `{{one-line description}}` as placeholders. Templates are pushed as an exact mirror, so removing a template from the repo removes it from `~/.claude/templates/` on the next push.

## Testing

```bash
python3 -m unittest discover -s tests -p 'test_*.py'
```
