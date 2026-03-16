# Repo AGENTS Template

Use this as a starting point, then delete any section that does not earn its keep.

```markdown
# Project Contract

## Build And Test
- Install: `...`
- Dev: `...`
- Test: `...`
- Lint: `...`
- Typecheck: `...`

## Architecture Boundaries
- `src/http/` is for transport only.
- `src/domain/` holds business logic.
- Shared contracts live in `src/contracts/`.

## Safety Rails
## NEVER
- Change secrets, CI, lockfiles, billing, or production infra without approval.
- Remove guards or migrations without checking all call sites.

## ALWAYS
- Explain risky file changes before committing.
- Report exact verification commands and results.

## Verification
- Backend changes: `...`
- API changes: `...`
- UI changes: `...`

## Compacting
Preserve:
1. Architecture decisions.
2. Modified files and key changes.
3. Verification status.
4. Open risks, TODOs, and rollback notes.
```
