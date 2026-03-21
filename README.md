# home-setup

Static backup plus curated sync for Claude Code and Codex home setup. One repo, one script, one drift check. `gstack` on both hosts is snapshot-only here, not push-managed.

## Layout

```text
home-setup/
├── .agents/
│   └── skills/
│       └── audit/                       ← project-local Codex /audit skill
├── .claude/
│   └── skills/
│       └── audit/                       ← project-local Claude /audit skill
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
│       ├── custom/
│       │   └── cross-retro/             ← repo-backed Codex custom skill source
│       └── gstack/                      ← upstream Codex gstack snapshot (don't edit)
├── sync.sh                              ← push / pull / status
├── CLAUDE.md                            ← repo instructions
└── README.md                            ← this file
```

## Quick Start

```bash
git clone <your-remote> ~/Documents/projects/home-setup
cd ~/Documents/projects/home-setup
./sync.sh status
./sync.sh push
```

## Sync Workflow

| Command | What it does |
|---------|-------------|
| `./sync.sh push` | Mirrors Claude templates, pushes `codex/config.toml` and `codex/AGENTS.md`, never touches live gstack |
| `./sync.sh pull` | Backs up Claude settings/CLAUDE/gstack/memory plus Codex config/AGENTS/gstack |
| `./sync.sh status` | Shows Claude and Codex drift, including repo-local audit entrypoints and gstack snapshot age |

**Weekly ritual:**
1. `./sync.sh status` — check for drift
2. `./sync.sh pull` — capture current state
3. `git add . && git commit` — snapshot your configs

**New machine:**
1. `git clone && cd home-setup`
2. Install Claude, Codex, and gstack normally
3. `./sync.sh push` — deploy only the repo-owned curated layer

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

`gstack` is intentionally excluded from `push` on both hosts. Keep the live installs current with their native upgrade flow, then snapshot them back into this repo with `./sync.sh pull`.

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

## Audit Skills

The repo keeps matching project-local audit entrypoints:

- Claude: `.claude/skills/audit/SKILL.md`
- Codex: `.agents/skills/audit/SKILL.md`

They are meant to report on the same workflow surface from either host: gstack status, config drift, repo contract coverage, Claude memory, Codex config, and skill-usage health.
