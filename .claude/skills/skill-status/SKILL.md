---
name: skill-status
description: Reports on the skill catalog — counts by portability, checks profile match, verifies gstack version.
---

# /skill-status — Skill Catalog Status Report

When `/skill-status` is invoked, produce a status report by reading the repo files and checking the live environment.

## Steps

1. **Read the catalog.** Read `skills-catalog.json` from the repo root. Parse the JSON.

2. **Report skill totals.**
   - Total number of skills in the catalog
   - Count per portability level: standalone, adaptable, needs-gstack, needs-browse
   - Count per source: gstack vs custom

3. **Identify the current machine's profile.** Read each file in `profiles/` (excluding `setup-guide.md`). Determine which profile matches the current machine based on OS and environment. Report the matching profile name and a one-line summary of its constraints.

4. **Report available skills for this profile.**
   - If the profile has gstack + browse: all skills are available
   - If the profile has gstack but no browse: exclude needs-browse skills
   - If the profile has no gstack: only standalone and adaptable skills are available
   - List the count of available vs total skills

5. **Check gstack version alignment.** If gstack is installed locally:
   ```bash
   cat ~/.claude/skills/gstack/VERSION 2>/dev/null || echo "not installed"
   ```
   Compare the live version against `gstack_version` in the catalog. Report whether they match. If they do not match, note that the catalog needs updating.

6. **Format the report.** Output a clean markdown report with sections for each of the above. Keep it concise — this is a status check, not an audit.
