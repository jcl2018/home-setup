# CLAUDE.md — home-setup

Skill catalog and portable skill source for Claude Code and Codex workflows. Ships the actual SKILL.md files for all 16 portable skills so any machine can install them without accessing the upstream gstack repo.

## Layout

```
home-setup/
├── skills-catalog.json          ← every skill with portability metadata
├── skills/                      ← actual SKILL.md files for 16 portable skills
│   ├── office-hours/SKILL.md    ← YC-style brainstorming
│   ├── plan-eng-review/SKILL.md ← architecture review
│   ├── retro/SKILL.md           ← weekly retrospective
│   └── ... (16 total)
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

- **Keep skills/ current.** After every gstack upgrade, re-copy the 16 portable SKILL.md files from `~/.claude/skills/gstack/` and update `skills-catalog.json` (including `gstack_version`). `/skill-status` flags version mismatches.
- **skills/ are copies, not forks.** Don't edit the upstream SKILL.md files in skills/. They should match the live gstack install exactly. Custom skills live in `.claude/skills/` and `.agents/skills/`.
- **Profiles describe machines.** Each profile lists what skills are available. Update when constraints change.

## Remote Machine Setup

On a machine that can't install gstack:
1. Clone this repo (or read on GitHub)
2. `mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions`
3. Copy skills from `skills/` into your local skills directory (e.g., `~/.claude/skills/` or `~/.codex/skills/`)
4. Invoke them: `/office-hours`, `/retro`, `/plan-eng-review`, etc.

## /skill-status

The only skill invocation relevant to this repo. It reads `skills-catalog.json`, reports skill counts by portability, identifies the current machine's profile, and checks whether the live gstack version matches the catalog.
