# CLAUDE.md — home-setup

Skill catalog for Claude Code and Codex workflows. References upstream gstack skills by metadata; custom skills live here directly.

## Layout

```
home-setup/
├── skills-catalog.json          ← central artifact: every skill with portability metadata
├── PHILOSOPHY.md                ← why this repo exists and how it works
├── profiles/
│   ├── personal-mac.md          ← reference machine (all skills available)
│   ├── work-windows.md          ← restricted machine (standalone + adaptable only)
│   └── setup-guide.md           ← how to read the catalog and set up a new machine
├── .claude/skills/
│   └── skill-status/              ← project-local Claude /skill-status skill
├── .agents/skills/
│   └── skill-status/              ← project-local Codex /skill-status skill
├── CLAUDE.md                    ← this file
└── README.md
```

## Rules

- **Keep the catalog current.** After every gstack upgrade, re-audit skills and update `skills-catalog.json` (including `gstack_version`). `/skill-status` flags version mismatches.
- **Never edit upstream skill content here.** Upstream skills live in their home installs and in the gstack repo. This repo only references them by metadata.
- **Custom skills are the exception.** `.claude/skills/` and `.agents/skills/` contain custom skill source files that this repo owns directly.
- **Profiles describe machines.** Each profile lists what skills are available based on the machine's constraints. Update profiles when machine constraints change.

## /skill-status

The only skill invocation relevant to this repo. It reads `skills-catalog.json`, reports skill counts by portability, identifies the current machine's profile, and checks whether the live gstack version matches the catalog.
