---
name: skill-status
description: Reports on every skill individually — what it does, where it comes from, what files it needs — plus profile match and upstream versions.
---

# /skill-status — Skill Catalog Status Report

When `/skill-status` is invoked, produce a status report focused on **what skills exist and how they work**.

## Steps

1. **Read the catalog.** Read `skills-catalog.json` from the repo root. Parse the JSON.

2. **Summary line.** One-line overview: total skills, source breakdown, portability breakdown.

3. **Skill-by-skill detail.** For EVERY skill in the catalog, show a row in a table:

   | Skill | Source | Portability | Description | Extra Files |
   |-------|--------|-------------|-------------|-------------|
   | /office-hours | gstack | adaptable | YC-style brainstorming... | none |
   | /ship | gstack | adaptable | Ship workflow... | bin/gstack-config, bin/gstack-diff-scope, bin/gstack-review-log, bin/gstack-review-read, bin/gstack-slug |
   | /skill-status | custom | standalone | This skill... | none |

   For the "Extra Files" column: check the skill's `dependencies` array in the catalog. If it lists any `gstack-*` dependencies, map them to the corresponding files in `skills/bin/`. If the skill has no dependencies beyond the SKILL.md itself, show "none".

   **Source explanation:**
   - `gstack` → copied from the gstack upstream. SKILL.md lives in `skills/{name}/SKILL.md`. Must match the live gstack install.
   - `custom` → authored in this repo. SKILL.md lives in `.claude/skills/{name}/SKILL.md` and `.agents/skills/{name}/SKILL.md`.

4. **Shell script inventory.** List every file in `skills/bin/` with a one-line description of what it does:

   | Script | Purpose | Used by |
   |--------|---------|---------|
   | gstack-config | Read/write persistent gstack settings | autoplan, land-and-deploy, ship |
   | gstack-diff-scope | Analyze which files changed in a diff | review, ship, land-and-deploy |
   | ... | ... | ... |

   Determine "Used by" by checking which catalog skills list that script name in their dependencies.

5. **Profile match.** Identify the current machine's profile. Report which profile matches and how many skills are available.

6. **Upstream versions.** For each upstream in `upstreams`, compare catalog version vs live install version. Flag mismatches.

7. **Format the report.** Markdown with the tables above. The skill table is the main output — it should be the first thing the reader sees after the summary line.
