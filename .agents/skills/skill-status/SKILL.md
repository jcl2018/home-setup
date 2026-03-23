---
name: skill-status
description: Reports on the skill catalog — counts by portability, checks profile match, verifies upstream versions.
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

6. **Format the report.** Output a clean markdown report with sections for each of the above. Keep it concise — this is a status check, not an audit.
