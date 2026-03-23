# home-setup

A portable skill source for Claude Code and Codex workflows.

This repo ships the actual SKILL.md files for **15 portable upstream skills + 1 custom skill** so any machine can install them without accessing upstream repos directly. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack); the architecture supports multiple upstreams.

## What's Here

- **`skills/`** — the actual SKILL.md instruction files for 15 portable upstream skills (standalone + adaptable)
- **`skills-catalog.json`** — every skill (upstream + custom) with name, description, portability rating, and dependencies
- **`profiles/`** — per-machine specs listing which skills are available based on OS, network, and installed tools
- **`.claude/skills/` and `.agents/skills/`** — custom skills that live in this repo (currently just `/skill-status`)
- **`PHILOSOPHY.md`** — why this repo ships portable skills and how maintenance works

## How to Use

1. Read `skills-catalog.json` to see what exists
2. Find your machine's profile in `profiles/` to see what's available to you
3. Copy skills from `skills/` to your local skills directory (e.g., `~/.claude/skills/` or `~/.codex/skills/`)
4. Run `/skill-status` to verify the catalog matches your live install

For the 12 non-portable skills (needs-gstack, needs-browse), install [gstack](https://github.com/garrytan/gstack) on an unrestricted machine.

## Portability Levels

| Level | Meaning |
|-------|---------|
| **standalone** | Works anywhere. No dependencies. |
| **adaptable** | Core logic works without gstack. Preamble fails harmlessly. |
| **needs-gstack** | Requires gstack infrastructure (config, review-log, diff-scope). |
| **needs-browse** | Requires the gstack browse daemon. Superset of needs-gstack. |
