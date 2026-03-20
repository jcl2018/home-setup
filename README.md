# AI Workflow Config Backup

Backup of AI tool configs and workflows for Claude Code + Codex. This repo stores settings, skills, project memory, and workflow definitions so they can be restored, shared, or customized.

## Layout

```
home-setup/
├── claude/                          ← Claude Code configs
│   ├── settings.json                ← global Claude Code settings
│   ├── skills/gstack/               ← gstack skill suite (21 skills)
│   └── projects/                    ← project-specific memory + configs
│
├── .codex/                          ← Codex configs
│   ├── config.toml
│   ├── skills/                      ← Codex skills
│   ├── docs/                        ← helper docs
│   ├── bin/                         ← helper scripts
│   ├── projects/                    ← project artifacts
│   ├── guardrails/                  ← guardrail state
│   └── automations/                 ← automation definitions
│
├── AGENTS.md                        ← Codex home contract
├── codex-home-manifest.toml         ← Codex export manifest
└── README.md                        ← this file
```

## Claude Code

### What's backed up

| Item | Source | Description |
|------|--------|-------------|
| `claude/settings.json` | `~/.claude/settings.json` | Global settings (permissions, model, theme) |
| `claude/skills/gstack/` | `~/.claude/skills/gstack/` | 21 gstack skills (office-hours, ship, review, qa, etc.) |
| `claude/projects/*/memory/` | `~/.claude/projects/*/memory/` | Per-project memory (user identity, feedback, preferences) |

### What's excluded

- Build artifacts (`dist/`, `node_modules/`, `.deploy/`)
- Session data (subagent meta, tool results, SQLite state)
- Auth/secrets

### Refresh Claude backup

```bash
cd /path/to/home-setup

# Copy settings
cp ~/.claude/settings.json claude/

# Copy gstack skills (exclude build artifacts)
rsync -av --exclude='.git' --exclude='node_modules' --exclude='dist' --exclude='.deploy' \
  --exclude='*.sqlite*' --exclude='__pycache__' \
  ~/.claude/skills/gstack/ claude/skills/gstack/

# Copy project memory (exclude session data)
rsync -av --exclude='subagents' --exclude='tool-results' \
  --include='*/memory/**' --include='*/' --exclude='*' \
  ~/.claude/projects/ claude/projects/
```

## Codex

### Refresh Codex backup

```bash
~/.codex/bin/codex-home-export --repo /path/to/home-setup
```

See `codex-home-manifest.toml` for managed files and exclusions.

## Customization (future)

This repo is also a place to experiment with custom workflows:
- Custom SKILL.md files (your own skills beyond gstack)
- Modified gstack skills (fork + edit)
- Workflow templates (reusable CLAUDE.md patterns)
- Custom hooks (pre/post tool execution)

Add custom skills under `claude/skills/custom/` to keep them separate from gstack upstream.
