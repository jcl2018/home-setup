# Philosophy

## Purpose

This repo is a portable skill source. It ships the actual SKILL.md instruction files for 16 portable skills (standalone and adaptable) so any machine can install them without accessing gstack's GitHub repo or running a gstack install. A restricted machine clones this repo and copies skill files directly into its local skills directory. That is the core value proposition.

## Portable, Not Just Metadata

The previous iteration of this repo shipped only a catalog — a JSON manifest describing skills by name, portability, and dependencies. That was useful for browsing but insufficient for setup. A restricted machine could read the catalog and know what existed, but still had to find the actual SKILL.md files somewhere else. Now we ship the files themselves. The catalog remains as metadata, but the `skills/` directory contains the real instruction files that AI agents read at runtime.

## Upstream Skills Are Copies

The 15 gstack-sourced skills in `skills/` are direct copies of SKILL.md files from the live gstack install at `~/.claude/skills/gstack/`. They should match the upstream source exactly. Do not edit them here. Do not fork them. Do not add local modifications. When gstack upgrades and skill files change, re-copy them into this repo and commit the update. The repo is a distribution mirror, not a fork.

## Custom Skills Are Ours

The `skills/skill-status/` directory and the project-local skills in `.claude/skills/` and `.agents/skills/` are original work that lives in this repo. These are the skills we wrote ourselves — they do not exist upstream. `skill-status` reads the catalog, reports skill counts by portability level, checks the current machine's profile, and flags version mismatches between the catalog and the live gstack install. Custom skills are the repo's direct contribution to the workflow surface.

## Any Machine Can Reconstruct

The full portable setup requires three things: this repo, a home directory, and an AI host (Claude Code or Codex). The steps are:

1. Clone this repo (or download from GitHub).
2. Create the gstack directory structure: `mkdir -p ~/.gstack/{projects,analytics,sessions}`.
3. Copy skills from `skills/` to the local skills directory (e.g., `~/.claude/skills/` or `~/.codex/skills/`).
4. Invoke them: `/office-hours`, `/retro`, `/plan-eng-review`, `/careful`, etc.

This covers 16 of the 28 cataloged skills — the standalone and adaptable ones that need no gstack infrastructure. The remaining 12 (needs-gstack and needs-browse) require a full gstack install with its browse daemon, config system, and review pipeline. Those are documented in the catalog for reference but cannot be distributed as standalone files.

## Maintenance

After every gstack upgrade:

1. Re-copy the 15 gstack SKILL.md files from `~/.claude/skills/gstack/` into `skills/`.
2. Bump `gstack_version` in `skills-catalog.json`.
3. Check whether gstack added new portable skills. If so, add them to `skills/` and the catalog.
4. Commit the update.

The `/skill-status` skill flags when the catalog version does not match the live install. That is the primary drift detection mechanism.
