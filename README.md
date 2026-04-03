# home-setup

Self-governing Claude Code configuration repo. Governance-as-code: principles trace to audit goals, goals trace to checks, checks auto-generate their own documentation. Commits auto-deploy to `~/.claude/`.

Reference implementation for the AI tooling community. See `skills-catalog.json` for the current skill count.

## Quick Start

```bash
bash scripts/deploy.sh          # deploy to ~/.claude/
bash scripts/validate-audit-spec.sh  # verify audit spec
bash scripts/gen-docs.sh         # regenerate auto-docs
```

Then run `/project:audit` in a Claude Code session for a full health + governance check.

## Documentation

| Tier | What | Where |
|------|------|-------|
| **Design** | Why this exists | [docs/design/](docs/design/) |
| | Principles + audit goals | [PHILOSOPHY.md](docs/design/PHILOSOPHY.md) |
| | Decision journal | [DECISIONS.md](docs/design/DECISIONS.md) |
| | Traceability map | [traceability.md](docs/design/traceability.md) (auto-generated) |
| **Operations** | How to use it | [docs/operations/](docs/operations/) |
| | Skills cheatsheet | [SKILLS-CHEATSHEET.md](docs/operations/SKILLS-CHEATSHEET.md) |
| | Commands & rules | [COMMANDS-AND-RULES.md](docs/operations/COMMANDS-AND-RULES.md) |
| | Getting started | [getting-started.md](docs/operations/getting-started.md) |
| | Skills reference | [skills-reference.md](docs/operations/skills-reference.md) (auto-generated) |
| | Inspection baseline | [INSPECTION-BASELINE.md](docs/operations/INSPECTION-BASELINE.md) |

## Upstream

Primary upstream: [gstack](https://github.com/garrytan/gstack). Skills in `skills/` are direct copies (P2: never edit, re-copy on upgrade). Custom skills in `.claude/skills/` are authored here.
