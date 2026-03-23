# Philosophy

## Goal

Ship a portable skill source that lets any machine — including a restricted work Windows box with Codex only and no bun — run 98% of my AI-assisted development workflow. Clone, copy, use. No upstream repo access, no runtime installs beyond bash.

## Non-Goals

- **Config backup or sync** — deleted. The repo tried to be a backup system with sync.sh, home_health.py, and 26 tests. Wrong goal. Git history preserves it.
- **Health checks or drift detection** — deleted. Over-engineered for a personal workflow repo.
- **UI/browse testing skills** — excluded. They require the gstack browse daemon (a bun-compiled binary). Not portable.
- **Snapshotting entire upstream repos** — eliminated. Shipping 1000+ file snapshots created drift. Now we ship only the SKILL.md files + shell scripts that actually run.
- **gstack-upgrade** — excluded. Only useful where gstack is already installed.

## How It Works

This repo is a portable skill source. It ships the actual SKILL.md instruction files so any machine can install them directly — no upstream repo access required. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack), but the architecture supports multiple upstreams.

## Portable, Not Just Metadata

The `skills/` directory contains the real instruction files that AI agents (Claude Code, Codex) read at runtime. The `skills-catalog.json` describes every skill with portability ratings and dependency tags. Together: the catalog tells you what's available, the files let you install it.

## Upstream Skills Are Copies

Upstream-sourced skills in `skills/` are direct copies of SKILL.md files from the live upstream install. They should match the upstream source exactly. Do not edit them here — do not fork, do not add local modifications. When an upstream upgrades and skill files change, re-copy them into this repo and commit. This repo is a distribution mirror, not a fork.

Currently all 19 upstream skills come from gstack. If a second upstream is added, its skills follow the same pattern: copy SKILL.md files into `skills/`, add entries to the catalog with a different `source` value, register the upstream in `skills-catalog.json` under `upstreams`.

## Custom Skills Are Ours

`.claude/skills/` and `.agents/skills/` contain skills we authored — they don't exist upstream. `/skill-status` reads the catalog, reports skill counts, checks the machine profile, and flags version mismatches between the catalog and live upstream installs. `/self-audit` performs a broader diagnostic sweep across the dual-host workflow surface.

## Any Machine Can Reconstruct

Setup requires three things: this repo, a home directory, and an AI host.

1. Clone this repo (or read on GitHub).
2. `mkdir -p ~/.gstack/{projects,analytics,sessions}`
3. Copy skills from `skills/` to the local skills directory.
4. Copy `skills/bin/` to your PATH (shell scripts that some skills depend on).
5. Invoke them: `/office-hours`, `/retro`, `/plan-eng-review`, `/ship`, etc.

All 21 cataloged skills (19 upstream + 2 custom) are portable. Skills that previously required gstack infrastructure (autoplan, land-and-deploy, review, ship) now ship with bundled shell scripts in `skills/bin/`. UI/browse-dependent skills (benchmark, browse, canary, design-review, qa, qa-only, setup-browser-cookies) and gstack-upgrade are excluded from the catalog — they require the gstack browse daemon or a live gstack install and cannot be made portable.

## Maintenance

After any upstream upgrade:

1. Re-copy the upstream SKILL.md files into `skills/`.
2. Re-copy the shell scripts from `bin/` into `skills/bin/`.
3. Bump the upstream version in `skills-catalog.json` (under `upstreams`).
4. Check for new portable skills; add them if found.
5. Commit.

`/skill-status` flags when catalog versions don't match live installs.
