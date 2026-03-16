# Repo AGENTS Template

Use this as a starting point, then delete any section that does not earn its keep.

```markdown
# Project Contract

Use this as a repo contract or umbrella-root contract.
For umbrella roots, delete repo-only sections such as `Build And Test` and `Architecture Boundaries` unless the parent itself runs code.

## Build And Test
- Delete this section for umbrella roots unless the parent itself runs code.
- Install: `...`
- Dev: `...`
- Test: `...`
- Lint: `...`
- Typecheck: `...`

## Architecture Boundaries
- Delete this section for umbrella roots unless the parent itself owns real shared code boundaries.
- `src/http/` is for transport only.
- `src/domain/` holds business logic.
- Shared contracts live in `src/contracts/`.

## Work Tracking
- Keep `.local-work/current.md` in the scope root and read it immediately after this `AGENTS.md`.
- Create it before substantive edits if it is missing.
- Refresh it after material changes to goal, plan, constraints, files touched, verification, blockers, or next steps.
- Refresh it again before pausing, handing off, compacting, or ending the session.

## Knowledge Root
- Repo-local durable knowledge lives under `docs/ai/knowledge/` unless this repo declares a different root.
- If this repo uses `lv2-<repo>-*` skills, keep matching PRDs under `<repo-knowledge-root>/setup-prd/`.

## Child Repos
- Use this section only for umbrella roots that coordinate multiple child git repos.
- List child repo paths relative to this file.
- Keep child build and test commands in each child repo's own `AGENTS.md`.

## Safety Rails
## NEVER
- Change secrets, CI, lockfiles, billing, or production infra without approval.
- Remove guards or migrations without checking all call sites.

## ALWAYS
- Explain risky file changes before committing.
- Report exact verification commands and results.

## Verification
- For umbrella roots, keep exact child-repo verification commands in each child repo's own `AGENTS.md`.
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
