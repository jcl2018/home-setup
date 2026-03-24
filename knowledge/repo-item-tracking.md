# Repo Item Tracking

- Scope: repo-level tracking convention for detailed defect, feature, investigation, and workflow work.
- When to use this note: when a real git repo needs resumable per-item tracking.
- Last checked: 2026-03-23

## Summary

- Keep `<repo>/.local-work/current.md` as the required stable entry point for repo work.
- Use `<repo>/.local-work/current.md` as a short active-items index, not the full detailed handoff note.
- Store detailed repo item notes under `<repo>/.local-work/items/<itemID>_<type>_<YYYY-MM-DD>_<keywords>.md`.
- Use lowercase snake_case for `<type>` and `<keywords>`.
- Derive keywords from repo context, AEDT routing, and descriptive branch names when they help.
- Ask the user for the first-slot token when repo work has no formal item ID yet.
- Example repo item doc: `D1419775_defect_2026-03-16_domain_port_fix.md`

## Boundaries

- Keep this note portable across repos and machines.
- Keep machine-specific repo examples or local workspace inventories out of this note.
