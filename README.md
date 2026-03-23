# home-setup

A skill catalog for Claude Code and Codex workflows.

This repo answers one question: **what AI workflow skills are available, and what does each one need to run?**

## What's Here

- **`skills-catalog.json`** — every skill (upstream gstack + custom) with name, description, portability rating, and dependencies
- **`profiles/`** — per-machine specs listing which skills are available based on OS, network, and installed tools
- **`.claude/skills/` and `.agents/skills/`** — custom skills that live in this repo (currently just `/home-retro`)
- **`PHILOSOPHY.md`** — why this repo is a catalog and not a backup system

## How to Use

1. Read `skills-catalog.json` to see what exists
2. Find your machine's profile in `profiles/` to see what's available to you
3. For upstream skills: install [gstack](https://github.com/garrytan/gstack) and they appear automatically
4. For custom skills: copy from this repo to your local skills directory
5. Run `/home-retro` to verify the catalog matches your live install

## Portability Levels

| Level | Meaning |
|-------|---------|
| **standalone** | Works anywhere. No dependencies. |
| **adaptable** | Core logic works without gstack. Preamble fails harmlessly. |
| **needs-gstack** | Requires gstack infrastructure (config, review-log, diff-scope). |
| **needs-browse** | Requires the gstack browse daemon. Superset of needs-gstack. |
