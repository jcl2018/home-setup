# home-setup

Single source of truth for Claude Code configuration across all machines.

This repo ships the actual SKILL.md files for **19 portable upstream skills + 5 custom skills** (24 total), plus shared knowledge files and settings templates. Any machine can deploy a complete Claude Code setup from this repo. Currently the primary upstream is [gstack](https://github.com/garrytan/gstack); the architecture supports multiple upstreams.

## What's Here

- **`skills/`** — the actual SKILL.md instruction files for 19 portable upstream skills (standalone + adaptable)
- **`skills/bin/`** — shell helper scripts (gstack-config, gstack-diff-scope, etc.) that some skills depend on
- **`.claude/skills/`** — 5 custom skills (`/skill-status`, `/project-contract`, `/repo-bootstrap`, `/domain-context`, `/sync-audit`)
- **`knowledge/`** — shared knowledge files deployed to `~/.claude/knowledge/` on every machine
- **`settings/`** — settings baseline and per-machine overrides
- **`skills-catalog.json`** — every skill (upstream + custom) with name, description, portability rating, and dependencies
- **`profiles/`** — per-machine specs listing which skills are available and what machine-local content is expected
- **`PHILOSOPHY.md`** — why this repo exists and how maintenance works

## How to Use

1. Clone this repo to your machine
2. Read `profiles/` to find your machine's profile
3. Copy skills from `skills/` and `.claude/skills/` to `~/.claude/skills/`
4. Copy knowledge files from `knowledge/` to `~/.claude/knowledge/`
5. Run `/sync-audit` to verify everything is in sync

## Source of Truth Model

This repo is the **source of truth**. The installed `~/.claude/` is a deployment target. Each machine may have additional machine-local content (like domain-specific knowledge corpora) that doesn't belong in the shared repo — these are declared in the machine's profile under "Expected Local Content."

`/sync-audit` compares the repo against the installed state and categorizes every difference: IN SYNC, MISSING, DRIFTED, LOCAL-EXPECTED, or LOCAL-UNDECLARED.

## Portability Levels

| Level | Meaning |
|-------|---------|
| **standalone** | Works anywhere. No dependencies. |
| **adaptable** | Core logic works without gstack. Preamble fails harmlessly. Some use bundled shell scripts from `skills/bin/`. |

UI/browse-dependent skills (benchmark, browse, canary, design-review, qa, qa-only, setup-browser-cookies) and gstack-upgrade are not tracked here — install [gstack](https://github.com/garrytan/gstack) directly for those.
