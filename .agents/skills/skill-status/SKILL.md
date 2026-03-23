---
name: skill-status
description: Reports on the skill catalog, repo file map with dependency graph, profile match, and upstream versions.
---

# /skill-status — Skill Catalog Status Report

When `/skill-status` is invoked, produce a status report by reading the repo files and checking the live environment.

## Steps

1. **Read the catalog.** Read `skills-catalog.json` from the repo root. Parse the JSON.

2. **Report skill totals.**
   - Total number of skills in the catalog
   - Count per portability level: standalone, adaptable, needs-gstack, needs-browse (or any other levels present)
   - Count per source (group by the `source` field — e.g., gstack, custom, or any other upstream name)

3. **Identify the current machine's profile.** Read each file in `profiles/` (excluding `setup-guide.md`). Determine which profile matches the current machine based on OS and environment. Report the matching profile name and a one-line summary of its constraints.

4. **Report available skills for this profile.**
   - Read the profile to determine what's available (unrestricted, no-browse, no-gstack, etc.)
   - Filter the catalog accordingly
   - List the count of available vs total skills

5. **Check upstream version alignment.** For each upstream in `upstreams`:
   - Read the `install_path` for the current host (claude or codex)
   - Check if the upstream is installed:
     ```bash
     cat {install_path}/{version_file} 2>/dev/null || echo "not installed"
     ```
   - Compare the live version against the catalog version
   - Report whether they match. If they do not match, note that the catalog may need updating.

6. **Repo file map with dependencies.** List every file in the repo (excluding `.git/`, `.DS_Store`, `.local-work/`, `settings.local.json`). For each file, show:
   - Its role (one-line purpose)
   - What reads it (which other files or skills depend on it)
   - What it reads (which other files it references or depends on)

   Present as a table or dependency graph. The goal is a big-picture view of how everything connects. Example format:

   ```
   FILE MAP & DEPENDENCIES
   ========================
   skills-catalog.json
     role: central manifest of all 28 skills with portability metadata
     read by: /skill-status, profiles/, README.md (referenced)
     reads: nothing (source of truth)

   skills/office-hours/SKILL.md
     role: portable copy of gstack /office-hours skill
     read by: AI agent when user invokes /office-hours
     reads: nothing (self-contained instructions)
     note: copy from ~/.claude/skills/gstack/office-hours/SKILL.md — must match upstream

   .claude/skills/skill-status/SKILL.md
     role: custom skill — this skill you're reading now
     read by: AI agent when user invokes /skill-status
     reads: skills-catalog.json, profiles/*.md, live upstream VERSION files
   ```

   For upstream skills in `skills/`, group them rather than listing each one individually (e.g., "skills/{15 upstream skills}/SKILL.md" with a shared description). List each custom skill individually.

   For non-skill files (PHILOSOPHY.md, CLAUDE.md, README.md, profiles/), show what they reference and who references them.

7. **Format the report.** Output a clean markdown report with sections for each of the above. Keep it concise — this is a status check, not an audit.
