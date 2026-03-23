# CLAUDE.md — home-setup

Portable skill source for Claude Code and Codex workflows. Ships actual SKILL.md files for 19 portable upstream skills + 1 custom skill (20 total). Multi-upstream ready (currently gstack).

## Layout

```
home-setup/
├── skills-catalog.json          ← every skill with portability metadata
├── skills/                      ← actual SKILL.md files for 19 portable upstream skills
│   ├── office-hours/SKILL.md    ← YC-style brainstorming
│   ├── plan-eng-review/SKILL.md ← architecture review
│   ├── ship/SKILL.md            ← ship workflow
│   ├── bin/                     ← shell scripts (gstack-config, gstack-diff-scope, etc.)
│   └── ... (19 upstream total)
├── PHILOSOPHY.md                ← why this repo exists
├── profiles/
│   ├── personal-mac.md          ← reference machine
│   ├── work-windows.md          ← restricted machine
│   └── setup-guide.md           ← new machine setup
├── .claude/skills/skill-status/ ← project-local Claude /skill-status
├── .agents/skills/skill-status/ ← project-local Codex /skill-status
├── CLAUDE.md                    ← this file
└── README.md
```

## Rules

- **Keep skills/ current.** After any upstream upgrade, re-copy portable SKILL.md files and `skills/bin/` scripts, then update `skills-catalog.json` (bump the version in `upstreams`). `/skill-status` flags version mismatches.
- **skills/ are copies, not forks.** Don't edit upstream SKILL.md files in skills/. They should match the live upstream install exactly. Custom skills live in `.claude/skills/` and `.agents/skills/`.
- **Profiles describe machines.** Each profile lists what skills are available. Update when constraints change.

## Remote Machine Setup

On a machine that can't install gstack:
1. Clone this repo (or read on GitHub)
2. `mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions`
3. Copy skills from `skills/` into your local skills directory (e.g., `~/.claude/skills/` or `~/.codex/skills/`)
4. Copy `skills/bin/` to a location on your PATH (shell scripts some skills depend on)
5. Invoke them: `/office-hours`, `/retro`, `/plan-eng-review`, `/ship`, etc.

## /skill-status

The only skill invocation relevant to this repo. It reads `skills-catalog.json`, reports skill counts by portability, identifies the current machine's profile, and checks whether live upstream versions match the catalog.
