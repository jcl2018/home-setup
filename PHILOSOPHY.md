# Philosophy

## Purpose

This repo is a portable skill source for AI-assisted development workflows. It ships the actual SKILL.md instruction files so any machine can install them directly — no upstream repo access required. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack), but the architecture supports multiple upstreams.

## Portable, Not Just Metadata

The `skills/` directory contains the real instruction files that AI agents (Claude Code, Codex) read at runtime. The `skills-catalog.json` describes every skill with portability ratings and dependency tags. Together: the catalog tells you what's available, the files let you install it.

## Upstream Skills Are Copies

Upstream-sourced skills in `skills/` are direct copies of SKILL.md files from the live upstream install. They should match the upstream source exactly. Do not edit them here — do not fork, do not add local modifications. When an upstream upgrades and skill files change, re-copy them into this repo and commit. This repo is a distribution mirror, not a fork.

Currently all 15 upstream skills come from gstack. If a second upstream is added, its skills follow the same pattern: copy SKILL.md files into `skills/`, add entries to the catalog with a different `source` value, register the upstream in `skills-catalog.json` under `upstreams`.

## Custom Skills Are Ours

`.claude/skills/` and `.agents/skills/` contain skills we authored — they don't exist upstream. `/skill-status` is the current custom skill: it reads the catalog, reports skill counts, checks the machine profile, and flags version mismatches between the catalog and live upstream installs.

## Any Machine Can Reconstruct

Setup requires three things: this repo, a home directory, and an AI host.

1. Clone this repo (or read on GitHub).
2. `mkdir -p ~/.gstack/{projects,analytics,sessions}`
3. Copy skills from `skills/` to the local skills directory.
4. Invoke them: `/office-hours`, `/retro`, `/plan-eng-review`, etc.

This covers 16 of 28 cataloged skills — the standalone and adaptable ones. The remaining 12 require upstream infrastructure (gstack's browse daemon, config system, review pipeline) and cannot be distributed as standalone files.

## Maintenance

After any upstream upgrade:

1. Re-copy the upstream SKILL.md files into `skills/`.
2. Bump the upstream version in `skills-catalog.json` (under `upstreams`).
3. Check for new portable skills; add them if found.
4. Commit.

`/skill-status` flags when catalog versions don't match live installs.
