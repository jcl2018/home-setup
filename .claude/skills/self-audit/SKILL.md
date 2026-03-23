---
name: self-audit
description: Audits this repo for gaps, staleness, and consistency — then suggests actionable improvements.
---

# /self-audit — Repo Self-Improvement Audit

When `/self-audit` is invoked, audit this repo against its own stated goal and produce a report with actionable suggestions.

## Steps

1. **Read the goal.** Read `PHILOSOPHY.md` — specifically the Goal and Non-Goals sections. This is the standard everything else is measured against.

2. **Consistency check.** Read every doc file (CLAUDE.md, README.md, PHILOSOPHY.md, profiles/*.md) and check:
   - Do skill counts match across all files? (catalog says X, README says Y, profiles say Z)
   - Do portability levels referenced in docs match what's in the catalog?
   - Does CLAUDE.md layout section match the actual repo file structure?
   - Does any doc reference deleted features (sync.sh, home_health.py, tests/, browse skills)?
   - Report each inconsistency found.

3. **Catalog freshness.** Read `skills-catalog.json` and check:
   - For each upstream in `upstreams`, check if the live version matches:
     ```bash
     cat {install_path}/{version_file} 2>/dev/null || echo "not installed"
     ```
   - If versions differ: "Catalog says {X}, live is {Y} — re-copy skills and bump version."
   - Count skills in catalog vs SKILL.md files in `skills/` — do they match?
   - Check if any SKILL.md files exist in `skills/` that aren't in the catalog (orphans).
   - Check if any catalog entries point to SKILL.md files that don't exist (missing files).

4. **Gap analysis.** If an upstream is installed locally, compare what's available vs what's in the catalog:
   ```bash
   ls ~/.claude/skills/gstack/*/SKILL.md 2>/dev/null | sed 's|.*/gstack/||;s|/SKILL.md||' | sort
   ```
   Compare against catalog skill names. Report:
   - Skills available upstream but not in catalog — are any of them portable? Should they be added?
   - Skills in catalog that no longer exist upstream — stale entries?

5. **Shell script check.** For each file in `skills/bin/`:
   - Is it referenced by at least one catalog skill's dependencies? If not, it's orphaned.
   - Does every catalog skill that lists a `gstack-*` dependency have the corresponding file in `skills/bin/`? If not, it's missing.

6. **Profile completeness.** For each profile in `profiles/`:
   - Does it list the correct number of available skills based on current catalog?
   - Does it reference the correct portability breakdown?
   - Does the setup section (if any) reference `skills/bin/`?

7. **Suggestions.** Based on findings, generate actionable recommendations:
   - "Bump catalog version from X to Y and re-copy skills" (if stale)
   - "Add /new-skill to catalog — it's portable and available upstream" (if gap found)
   - "README says 19 skills but catalog has 20 — update README" (if count mismatch)
   - "skills/bin/gstack-foo is not referenced by any skill — consider removing" (if orphaned)
   - "Consider adding a profile for {OS} — you have machines that don't match existing profiles" (if gap)
   - Each suggestion should be one concrete action, not a vague recommendation.

8. **Format the report.** Output as markdown:
   ```
   ## Self-Audit Report

   ### Consistency: {PASS / N issues}
   ...

   ### Freshness: {IN SYNC / STALE}
   ...

   ### Gaps: {N suggestions}
   ...

   ### Shell Scripts: {PASS / N issues}
   ...

   ### Profiles: {PASS / N issues}
   ...

   ### Suggestions
   1. ...
   2. ...
   ```

   If everything passes: "All clear — repo is aligned with PHILOSOPHY.md goal. No action needed."
