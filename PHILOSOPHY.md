# Philosophy

## Purpose

This repo is a skill catalog. It exists so that any machine — unrestricted or locked down — can browse the catalog on GitHub and know exactly which AI workflow skills are available, what they do, and what they require. The catalog is the product. Everything else is supporting context.

## Catalog, Not Backup

Previous iterations of this repo tried to be a backup system: snapshotting upstream tools, syncing config files, running health checks. That approach created 1200+ files of drift-prone infrastructure around a goal that turned out to be wrong. The real value is simpler: a manifest of skills with enough metadata to reconstruct any setup from scratch. Git history preserves everything that was deleted. Nothing is lost; the goal just changed.

## Reference, Not Snapshot

Upstream skills (gstack) are referenced in the catalog by name, description, and portability rating. Their source files live in the upstream repo and in the live home install — not here. This eliminates the drift problem entirely. When gstack upgrades, the catalog gets a version bump and a re-audit. No file sync, no stale snapshots, no reconciliation scripts.

## Custom Skills Live Here

The only skill source files in this repo are custom skills — things that do not exist upstream. The `/skill-status` skill is the primary example: it reads the catalog and reports status. Custom skills are project-local (in `.claude/skills/` and `.agents/skills/`) and are the repo's direct contribution to the workflow surface.

## Any Machine Can Reconstruct

A person sitting at a restricted Windows machine with no git access can read this repo on GitHub, find their profile, read the catalog, and know exactly which skills to set up and which are unavailable. A person on an unrestricted Mac can do the same, plus install gstack and get everything. The profiles document what each machine looks like. The catalog documents what each skill requires. Together, they answer: "What can I use here?"

## Maintenance

After every gstack upgrade, re-audit the skills and update `skills-catalog.json` (including `gstack_version`). The `/skill-status` skill flags when the live gstack version does not match the catalog. That is the only ongoing maintenance this repo requires.
