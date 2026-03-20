# AI Workflow Lab

Backup, audit, extend, and sync your AI tool configurations across machines. This repo is the control center for Claude Code + Codex workflows — managing settings, skills, project memory, templates, and more.

## Layout

```
home-setup/
├── claude/                              ← Claude Code configs
│   ├── settings.json                    ← global settings (redacted secrets)
│   ├── skills/
│   │   ├── gstack/                      ← upstream gstack backup (don't edit)
│   │   ├── custom/                      ← your custom skills (edit freely)
│   │   │   └── audit/                   ← /audit — scan & suggest improvements
│   │   └── community/                   ← skills from others (try before adopting)
│   ├── templates/                       ← reusable CLAUDE.md templates
│   │   ├── python-project.md
│   │   └── terraform-project.md
│   └── projects/                        ← per-project memory backup
│
├── .codex/                              ← Codex configs
│   ├── config.toml
│   ├── skills/
│   ├── docs/
│   ├── bin/
│   ├── projects/
│   ├── guardrails/
│   └── automations/
│
├── sync.sh                              ← push / pull / status
├── CLAUDE.md                            ← instructions for Claude Code in this repo
├── AGENTS.md                            ← Codex home contract
├── codex-home-manifest.toml             ← Codex export manifest
└── README.md                            ← this file
```

## Quick Start

```bash
# Clone on a new machine
git clone <your-remote> ~/Documents/projects/home-setup
cd ~/Documents/projects/home-setup

# Deploy custom skills + templates to ~/.claude/
./sync.sh push

# Run the audit skill to check your setup
# (inside any Claude Code session)
/audit
```

## Sync Workflow

The `sync.sh` script keeps your repo and `~/.claude/` in sync.

| Command | What it does |
|---------|-------------|
| `./sync.sh push` | Symlinks custom + community skills into `~/.claude/skills/`, copies templates to `~/.claude/templates/` |
| `./sync.sh pull` | Backs up `settings.json` (secrets redacted), gstack snapshot, and project memory into this repo |
| `./sync.sh status` | Shows gstack version sync, skill deployment status, settings diff, template + memory counts |

**Typical workflow:**
1. `./sync.sh pull` — capture current state before committing
2. `git add . && git commit` — snapshot your configs
3. On another machine: `git pull && ./sync.sh push` — deploy everything

## Adding Custom Skills

1. Create a directory under `claude/skills/custom/` with a `SKILL.md`:
   ```
   claude/skills/custom/my-skill/
   └── SKILL.md
   ```
2. Run `./sync.sh push` to symlink it into `~/.claude/skills/`
3. Use `/my-skill` in any Claude Code session

Custom skills are symlinked, so edits in this repo take effect immediately.

## Trying Community Skills

1. Drop a skill directory into `claude/skills/community/`:
   ```
   claude/skills/community/some-skill/
   └── SKILL.md
   ```
2. Run `./sync.sh push` to deploy
3. Test it out — if you like it, move it to `custom/`

## Creating Templates

Templates are reusable CLAUDE.md patterns for bootstrapping new projects. Add `.md` files to `claude/templates/`:

```
claude/templates/
├── python-project.md        ← Python project template
└── terraform-project.md     ← Terraform/IaC template
```

Use `{{project_name}}` and `{{one-line description}}` as placeholders. When starting a new project, copy a template and fill in the blanks.

## What Gets Backed Up

| Item | Source | Notes |
|------|--------|-------|
| `claude/settings.json` | `~/.claude/settings.json` | API keys and secrets are redacted |
| `claude/skills/gstack/` | `~/.claude/skills/gstack/` | Full gstack snapshot (excludes build artifacts) |
| `claude/projects/*/memory/` | `~/.claude/projects/*/memory/` | Per-project memory only (no session data) |
| `.codex/` | `~/.codex/` | Codex configs, skills, automations |

### What's Excluded

- Build artifacts (`dist/`, `node_modules/`, `.deploy/`)
- Session data (subagent meta, tool results, SQLite state)
- Auth tokens and secrets (redacted in settings.json)

## Codex

Codex configs live in `.codex/`. To refresh:

```bash
~/.codex/bin/codex-home-export --repo /path/to/home-setup
```

See `codex-home-manifest.toml` for managed files and exclusions.
