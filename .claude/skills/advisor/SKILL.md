---
name: advisor
description: "Non-critical outsider reviewer: L1 strategic (per-family triplet quality) + L2 operational (system hygiene). Suggestion lifecycle."
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /advisor — Strategic Quality Review

Two-layer reviewer that complements /audit (correctness) with improvement advice.
/audit checks "is it correct?" — /advisor checks "is it good?"

## Layer 1: Per-Family Strategic Review

Discover all doc triplet families:
```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
for dir in "$REPO_ROOT"/docs/*/; do
  [ -f "$dir/PRD.md" ] && [ -f "$dir/ARCHITECTURE.md" ] && [ -f "$dir/TEST-SPEC.md" ] && echo "TRIPLET: $dir"
done
```

For each family with a complete triplet, evaluate:

**Quality (1-5 per dimension):**
- Readability: Clear, concise, jargon-free
- Completeness: All sections filled, no placeholders remaining
- Consistency: Docs agree with each other
- Staleness: Last updated date vs recent commits in affected files
- Coverage: P0 stories have tests, components have owners

**Output per family:**
```
| Family | Read | Complete | Consistent | Stale? | Coverage | Overall |
|--------|------|----------|------------|--------|----------|---------|
| {name} | {1-5} | {1-5} | {1-5} | Y/N | {1-5} | {avg} |
```

## Layer 2: Operational Health

Check system-wide operational hygiene:
- **Upstream freshness:** Is gstack version current? Check `~/.claude/skills/gstack/VERSION`
- **Skill usage:** Are all active skills being invoked? (Check `~/.gstack/analytics/skill-usage.jsonl` if it exists)
- **Template coverage:** Do templates exist for all artifact types in artifact-manifests.json?
- **Contract coverage:** Do all active custom skills have entries in skill-contracts.json?
- **Foundation principles:** Are CLAUDE.md rules consistent with the governance philosophy?

**Output:**
```
| Check | Status | Detail |
|-------|--------|--------|
| Upstream version | OK/STALE | gstack {version} (latest: {latest}) |
| Template coverage | OK/GAP | {N}/{M} types covered |
| Contract coverage | OK/GAP | {N}/{M} active skills have contracts |
| Principle alignment | OK/DRIFT | {detail} |
```

## Suggestions

For each finding scored below 3/5 or flagged as GAP/STALE/DRIFT, generate a suggestion:
- One-line description of the improvement
- Effort estimate (S/M/L)
- Priority (P1/P2/P3)

Present suggestions via AskUserQuestion, one at a time:
"Suggestion: {description}. Effort: {S/M/L}. Accept, defer, or skip?"

**Suggestion lifecycle:**
- Accepted → add to TODOS.md
- Deferred → save to `~/.gstack/advisor/deferred.jsonl` for next review
- Skipped → no action

## Snapshot

Save the review to `docs/inspections/advisor-{date}.md` with the full report.

## Rules

- **Non-critical.** Findings are suggestions, not blockers.
- **No auto-fix.** Report only, user decides action.
- **Complements /audit.** Don't duplicate deterministic checks that /audit already does.
- **Weekly cadence recommended.** Run periodically to catch drift.
