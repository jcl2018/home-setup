# Inspection Baseline

Known-good state snapshot. Updated per audit cycle. `/project:audit` compares actual state against this baseline.

## Status

**Last updated:** 2026-04-03 (Layer 3 migration)
**Overall:** INITIAL (first audit not yet run)

## Room Descriptions

| Room | Engine | Focus | Expected state |
|------|--------|-------|----------------|
| 1 | health | Skill Sync | All catalog skills deployed, version matches |
| 2 | health | Catalog Health | All SKILL.md present, CLI deps available |
| 3 | health | Home Archaeology | 0 orphans, 0 stale sessions, 0 temp files |
| 4 | health | Knowledge Freshness | INDEX.md present, all knowledge deployed |
| 5 | health | System Vitals | settings.json present, repo clean |
| pass1 | governance | Deterministic | 0 broken links, layout tree matches disk |
| pass2 | governance | AI Review | No stale claims, no lane violations |

## Next Steps

Run `/project:audit` to establish the first baseline with real data.
