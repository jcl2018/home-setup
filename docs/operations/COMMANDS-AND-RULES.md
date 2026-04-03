# Commands and Rules

## Project Commands

Located in `.claude/commands/`. Invoked as `/project:name`.

| Command | File | Purpose |
|---------|------|---------|
| `/project:audit` | `.claude/commands/audit.md` | Run both audit engines, save snapshot, show trending |
| `/project:deploy` | `.claude/commands/deploy.md` | Deploy repo to `~/.claude/` |

## Path-Scoped Rules

Located in `.claude/rules/`. Activate automatically when Claude touches files matching the `paths:` glob.

| Rule | Scope | Enforces | Purpose |
|------|-------|----------|---------|
| `upstream-skills.md` | `skills/**` | P2 | Don't edit upstream skills, re-copy on upgrade |
| `custom-skills.md` | `.claude/skills/**` | P3 | Add to catalog and cheatsheet when creating |
| `deployable-files.md` | `knowledge/**`, `settings/**` | P11 | Run deploy.sh after changes |
| `philosophy-sync.md` | `docs/design/*.md` | P1 | Update cross-refs, regenerate traceability |
| `audit-spec-sync.md` | `audit-spec.json` | D8 | Run validator, regenerate docs |
| `no-hardcoded-counts.md` | `docs/**`, `*.md` | D9 | Reference catalog, don't hardcode counts |
| `doc-lanes.md` | `docs/**`, `*.md` | D10 | Check lanes table before adding content |
| `catalog-update.md` | `skills-catalog.json` | P1 | Regenerate docs, update cheatsheet |
