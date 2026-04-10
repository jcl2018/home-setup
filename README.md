# home-setup

Self-governing Claude Code configuration repo. Governance-as-code: principles trace to audit goals, goals trace to checks, checks auto-generate their own documentation. Commits auto-deploy to `~/.claude/`.

Reference implementation for the AI tooling community. See `skills-catalog.json` for the current skill count.

## Quick Start

```bash
bash scripts/deploy.sh          # deploy to ~/.claude/
bash scripts/validate-audit-spec.sh  # verify audit spec
bash scripts/gen-docs.sh         # regenerate auto-docs
```

Then run `/system-health` in a Claude Code session for a full health + governance check.

## Documentation

| Category | What | Where |
|----------|------|-------|
| **Feature docs** | PRD + Architecture + Test Spec per feature | `docs/{family}/` |
| **Generated** | Auto-built reference docs | [docs/generated/](docs/generated/) |
| | Traceability map | [traceability.md](docs/generated/traceability.md) (auto-generated) |
| | Skills reference | [skills-reference.md](docs/generated/skills-reference.md) (auto-generated) |
| **Inspections** | Point-in-time audit snapshots | [docs/inspections/](docs/inspections/) |
| **Principles** | Principles + audit goals | See CLAUDE.md |

## Upstream

Primary upstream: [gstack](https://github.com/garrytan/gstack). Skills in `skills/` are direct copies (P2: never edit, re-copy on upgrade). Custom skills in `.claude/skills/` are authored here.
