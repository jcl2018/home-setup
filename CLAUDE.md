# CLAUDE.md — home-setup

Static backup plus curated sync for Claude Code and Codex home setup. `gstack` on both sides is snapshot-only here; upgrade and manage the live installs separately.

## Commands

```bash
./sync.sh status   # compare repo vs live Claude/Codex homes
./sync.sh push     # deploy curated repo-owned files
./sync.sh pull     # back up live Claude/Codex state into this repo
```

## Layout

- `claude/settings.json` — global settings (redacted secrets)
- `claude/CLAUDE.md` — global CLAUDE.md archive (pulled from `~/.claude/CLAUDE.md`)
- `claude/skills/gstack/` — upstream gstack snapshot (DON'T edit, never pushed)
- `claude/templates/` — reusable CLAUDE.md templates for new projects
- `claude/projects/` — per-project memory backup
- `codex/config.toml` — curated Codex config
- `codex/AGENTS.md` — curated Codex home contract backup
- `codex/skills/gstack/` — upstream Codex gstack snapshot (DON'T edit, never pushed)
- `codex/skills/custom/` — repo-backed Codex custom skill sources
- `.claude/skills/audit/` — project-local Claude `/audit` skill
- `.agents/skills/audit/` — project-local Codex `/audit` skill

## Rules

- Never edit either `*/skills/gstack/` snapshot directly.
- Run `./sync.sh pull` before committing to get the latest state.
- Run `./sync.sh push` after cloning on a new machine.
- Run `./sync.sh status` weekly to catch drift.
- `gstack` snapshots are backup-only. `push` does not install or overwrite them.

## /audit

The repo ships matching project-local `/audit` skills for Claude and Codex in `.claude/skills/audit/SKILL.md` and `.agents/skills/audit/SKILL.md`. They scan the dual-host workflow surface and report on config drift, gstack snapshots, repo contracts, memory, and skill usage.
