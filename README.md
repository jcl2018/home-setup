# home-setup

A portable skill source for Claude Code and Codex workflows.

This repo ships the actual SKILL.md files for **19 portable upstream skills + 2 custom skills** (21 total) so any machine can install them without accessing upstream repos directly. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack); the architecture supports multiple upstreams.

## What's Here

- **`skills/`** — the actual SKILL.md instruction files for 19 portable upstream skills (standalone + adaptable)
- **`skills/bin/`** — shell helper scripts (gstack-config, gstack-diff-scope, etc.) that some skills depend on
- **`skills-catalog.json`** — every skill (upstream + custom) with name, description, portability rating, and dependencies
- **`profiles/`** — per-machine specs listing which skills are available based on OS, network, and installed tools
- **`.claude/skills/` and `.agents/skills/`** — custom skills that live in this repo (currently `/skill-status` and `/self-audit`)
- **`PHILOSOPHY.md`** — why this repo ships portable skills and how maintenance works

## How to Use

1. Read `skills-catalog.json` to see what exists
2. Find your machine's profile in `profiles/` to see what's available to you
3. Copy skills from `skills/` to your local skills directory (e.g., `~/.claude/skills/` or `~/.codex/skills/`)
4. Copy `skills/bin/` to a location on your PATH (or set PATH to include it)
5. Run `/skill-status` to verify the catalog matches your live install

UI/browse-dependent skills (benchmark, browse, canary, design-review, qa, qa-only, setup-browser-cookies) and gstack-upgrade are not tracked here — install [gstack](https://github.com/garrytan/gstack) directly for those.

## Portability Levels

| Level | Meaning |
|-------|---------|
| **standalone** | Works anywhere. No dependencies. |
| **adaptable** | Core logic works without gstack. Preamble fails harmlessly. Some use bundled shell scripts from `skills/bin/`. |
