# Repo Item Tracking

- Scope: repo-level tracking convention for detailed defect, feature, investigation, and workflow work.
- When to use this note: when a real git repo needs resumable per-item tracking without changing the home or umbrella-root tracking model.

## Summary

- Keep `<repo>/.local-work/current.md` as the required stable entry point for repo work.
- Use `<repo>/.local-work/current.md` as a short active-items index, not the full detailed handoff note.
- Store detailed repo item notes under `<repo>/.local-work/items/<itemID>_<type>_<YYYY-MM-DD>_<keywords>.md`.
- Keep home-control work and umbrella-root work on `current.md` only.
- Use lowercase snake_case for `<type>` and `<keywords>`.
- Derive keywords from repo context, AEDT routing, and descriptive branch names when they help.
- Ask the user for the first-slot token when repo work has no formal item ID yet.
- Example repo item doc: `D1419775_defect_2026-03-16_domain_port_fix.md`

## Boundaries

- Keep this note portable across repos and machines.
- Keep machine-specific repo examples or local workspace inventories out of this note.
- If a local workspace wants concrete examples, store them in that workspace's own docs or tracking notes instead of home knowledge.

## Source files or docs

- `C:\Users\chjiang\AGENTS.md`
- `C:\Users\chjiang\.codex\knowledge\work-start-checklist.md`
- `C:\Users\chjiang\.codex\skills\lv1-workflow-session-handoff\SKILL.md`
- nearest repo `AGENTS.md`
- nearest repo `.local-work/current.md`

## Last checked

- 2026-03-19
