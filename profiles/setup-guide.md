# Setup Guide

## Step 1: Read the Catalog

Open `skills-catalog.json` at the repo root (on GitHub or locally). Each skill entry tells you:
- **name** — the skill's slash command
- **description** — what it does
- **portability** — what it requires (standalone or adaptable)
- **dependencies** — specific runtime requirements

## Step 2: Find Your Profile

Look in `profiles/` for your machine:
- [personal-mac.md](personal-mac.md) — macOS, unrestricted, Claude Code + Codex, all skills available
- [work-windows.md](work-windows.md) — Windows, restricted, Codex only, standalone + adaptable skills only

If no profile matches, create one. The key questions: What OS? Which AI hosts? Is gstack installed? Is the browse daemon available?

## Step 3: Pick Your Skills

Based on your profile's available portability levels:
- **standalone** skills work everywhere, no dependencies
- **adaptable** skills work everywhere — the gstack preamble fails harmlessly and the AI agent continues

All 21 cataloged skills are standalone or adaptable. UI/browse-dependent skills are not tracked here (install [gstack](https://github.com/garrytan/gstack) directly for those).

## Step 4: Install

Copy the SKILL.md files from the `skills/` directory in this repo to your local skills directory (`~/.claude/skills/` for Claude Code, `~/.codex/skills/` for Codex). No gstack install needed.

`skills/bin/` contains shell scripts that some skills depend on (autoplan, land-and-deploy, review, ship). Copy `skills/bin/` to a location on your PATH or set your PATH to include it.

For custom skills from this repo: copy from `.claude/skills/` or `.agents/skills/` to the corresponding location in your home directory.

## Step 5: Verify

Run `/skill-status` from this repo to confirm the catalog matches your live install. It reports skill counts, profile match, and gstack version alignment.
