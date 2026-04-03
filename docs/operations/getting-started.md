# Getting Started

5-minute onboarding for the home-setup governance framework.

## What This Is

A Git repo that is the single source of truth for Claude Code configuration on this machine. Skills, knowledge, settings, and audit infrastructure. Commits auto-deploy to `~/.claude/`.

## Quick Start

```bash
# 1. Verify the spec
bash scripts/validate-audit-spec.sh

# 2. Deploy to ~/.claude/
bash scripts/deploy.sh

# 3. Regenerate auto-docs
bash scripts/gen-docs.sh

# 4. Run the full audit
# (invoke /project:audit in a Claude Code session)
```

## Key Commands

| Command | What it does |
|---------|-------------|
| `bash scripts/deploy.sh` | Syncs repo to `~/.claude/` |
| `bash scripts/deploy.sh --dry-run` | Preview deploy without executing |
| `bash scripts/validate-audit-spec.sh` | Verify audit spec coverage closure |
| `bash scripts/gen-docs.sh` | Regenerate traceability + skills reference |
| `bash scripts/gen-docs.sh --check` | Verify generated docs are current |
| `/project:audit` | Full health + governance audit with snapshot |
| `/project:deploy` | Deploy (same as `bash scripts/deploy.sh`) |

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Contract for Claude: layout, rules, machine config |
| `audit-spec.json` | 42 checks mapped to 9 audit goals |
| `skills-catalog.json` | All skills with metadata |
| `docs/design/PHILOSOPHY.md` | 5 principles + audit goals |
| `docs/design/DECISIONS.md` | Decision journal |

## After Changes

The post-commit hook runs `deploy.sh` automatically. If you need to manually deploy:

```bash
bash scripts/deploy.sh
```

After editing `audit-spec.json` or `skills-catalog.json`:

```bash
bash scripts/gen-docs.sh
```

## Prerequisites

- `jq` (install via `brew install jq`)
- `git`, `gh` (GitHub CLI)
- Claude Code (VSCode extension or CLI)
