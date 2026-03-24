# Philosophy

## Goal

Single source of truth for Claude Code configuration across all machines. Ships skills, shared knowledge, and settings templates. Clone, run `/sync-audit`, deploy. Any machine — including a restricted work Windows box with no bun — can reconstruct a complete Claude Code setup from this repo plus its declared machine-local content.

## Non-Goals

- **Config backup or sync** — deleted. The repo tried to be a backup system with sync.sh, home_health.py, and 26 tests. Wrong goal. Git history preserves it.
- **Automatic sync** — the repo provides visibility (via `/sync-audit`), not automation. You see what's different and decide what to copy.
- **Health checks or drift detection** — deleted. Over-engineered for a personal workflow repo. `/sync-audit` replaces this with a simple compare-and-report model.
- **UI/browse testing skills** — excluded. They require the gstack browse daemon (a bun-compiled binary). Not portable.
- **Snapshotting entire upstream repos** — eliminated. Shipping 1000+ file snapshots created drift. Now we ship only the SKILL.md files + shell scripts that actually run.
- **gstack-upgrade** — excluded. Only useful where gstack is already installed.

## How It Works

This repo is the single source of truth for Claude Code configuration. It ships the actual SKILL.md instruction files, shared knowledge files, and settings templates so any machine can deploy them directly. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack), but the architecture supports multiple upstreams.

## Source of Truth, Not Sync Automation

The repo owns what's shared. The installed `~/.claude/` is a deployment of that truth plus machine-local additions. Each machine's profile declares what local content is expected (like domain-specific knowledge corpora that are too large or proprietary to share). `/sync-audit` compares the two and explains every difference.

This is deliberate: visibility over automation. You see what's different, you understand why, you decide what to copy. No magic sync that might overwrite intentional local changes.

## Shared Knowledge

The `knowledge/` directory contains cross-machine, cross-repo knowledge files — coding conventions, commit templates, PR templates, work checklists. These are deployed to `~/.claude/knowledge/` alongside any machine-local content. The repo's `knowledge/INDEX.md` is the shared routing file; each machine's installed INDEX.md may have additional entries for local domains.

## Upstream Skills Are Copies

Upstream-sourced skills in `skills/` are direct copies of SKILL.md files from the live upstream install. They should match the upstream source exactly. Do not edit them here — do not fork, do not add local modifications. When an upstream upgrades and skill files change, re-copy them into this repo and commit. This repo is a distribution mirror, not a fork.

Currently all 19 upstream skills come from gstack. Custom skills (project-contract, repo-bootstrap, domain-context, skill-status, sync-audit) are authored in this repo. If a second upstream is added, its skills follow the same pattern: copy SKILL.md files into `skills/`, add entries to the catalog with a different `source` value, register the upstream in `skills-catalog.json` under `upstreams`.

## Custom Skills Are Ours

`.claude/skills/` contains skills we authored — they don't exist upstream. `/skill-status` reads the catalog, reports skill counts, checks the machine profile, and flags version mismatches. `/project-contract` writes or tightens a `CLAUDE.md` for any repo. `/repo-bootstrap` onboards a repo for Claude Code work. `/domain-context` loads or captures domain knowledge from `~/.claude/knowledge/`. `/sync-audit` compares the repo against the installed `~/.claude/` state and explains every difference.

## Any Machine Can Reconstruct

Setup requires three things: this repo, a home directory, and Claude Code.

1. Clone this repo.
2. `mkdir -p ~/.gstack/{projects,analytics,sessions}`
3. Copy skills from `skills/` and `.claude/skills/` to `~/.claude/skills/`.
4. Copy knowledge files from `knowledge/` to `~/.claude/knowledge/`.
5. Run `/sync-audit` to verify everything is in sync.

All 24 cataloged skills (19 upstream + 5 custom) are portable. Skills that previously required gstack infrastructure (autoplan, land-and-deploy, review, ship) now ship with bundled shell scripts in `skills/bin/`. UI/browse-dependent skills and gstack-upgrade are excluded from the catalog.

## Maintenance

After any upstream upgrade:

1. Re-copy the upstream SKILL.md files into `skills/`.
2. Re-copy the shell scripts from `bin/` into `skills/bin/`.
3. Bump the upstream version in `skills-catalog.json` (under `upstreams`).
4. Check for new portable skills; add them if found.
5. Run `/sync-audit` to verify, then deploy to each machine.
6. Commit.

`/skill-status` flags when catalog versions don't match live installs. `/sync-audit` flags when the repo doesn't match the installed state.
