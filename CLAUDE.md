# CLAUDE.md — home-setup (AI Workflow Lab)

This is a meta-repo for managing AI tool configurations across machines. It's NOT a software project — it's the control center for Claude Code + Codex workflows.

## What this repo does

- **Backup**: Mirrors Claude Code settings, gstack skills, project memory, and Codex configs
- **Audit**: Scans your AI config surface and suggests improvements
- **Extend**: Custom skills in `claude/skills/custom/`, community skills in `claude/skills/community/`
- **Sync**: `./sync.sh push` deploys to any machine, `./sync.sh pull` backs up

## Commands

```bash
./sync.sh status   # show what's in sync vs out of sync
./sync.sh push     # deploy custom skills + templates to ~/.claude/
./sync.sh pull     # backup settings + gstack + memory from ~/.claude/
```

## Layout

- `claude/skills/gstack/` — upstream gstack backup (DON'T edit, managed by gstack-upgrade)
- `claude/skills/custom/` — YOUR skills (edit freely, synced by push)
- `claude/skills/community/` — skills from others (try before adopting)
- `claude/templates/` — reusable CLAUDE.md templates for new projects
- `claude/projects/` — per-project memory backup
- `.codex/` — Codex home configs

## Rules

- Never edit `claude/skills/gstack/` directly — it's a snapshot of upstream
- Custom skills go in `claude/skills/custom/`
- Run `./sync.sh pull` before committing to get the latest state
- Run `./sync.sh push` after cloning on a new machine
