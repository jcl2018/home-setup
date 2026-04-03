# /project:audit — Unified Audit

Run both audit engines and produce a unified report:

1. Run `/home-inspect` (5-room mechanical health check)
2. Run `/governance-audit` (deterministic + AI content review)
3. Merge findings into a single checkpoint table
4. Compare against `docs/operations/INSPECTION-BASELINE.md` (if it exists)
5. Save a timestamped snapshot to `docs/inspections/audit-YYYY-MM-DD-HHMMSS.md`
6. Show trending: what was resolved, what's new, what's unchanged vs previous audit

## Output format

```
=== UNIFIED AUDIT ===
Date: YYYY-MM-DD HH:MM:SS
Commit: <short hash>

--- Health Engine (mechanical) ---
<home-inspect output>

--- Governance Engine (content) ---
<governance-audit output>

--- Summary ---
Health:     X pass, Y warn, Z fail
Governance: X pass, Y warn, Z fail
Total:      X pass, Y warn, Z fail

--- vs Previous Audit ---
Resolved: <list>
New:      <list>
Unchanged: <list>
```

After the audit, remind the user to commit the snapshot.
