---
name: work-audit
description: "Unified doc quality check for work items: tracking validation + /align-feature-contract + inline quality checks."
allowed-tools:
  - Bash
  - Read
  - Edit
  - Glob
  - Grep
  - Skill
  - AskUserQuestion
---

# /work-audit — Work Item Quality Gate

Standalone quality gate that can run at any point in the lifecycle. Runs three layers
of checks and writes findings to the work item's journal.

## Usage

`/work-audit {slug}` — audit a specific work item
`/work-audit` — audit the work item on the current branch

## Step 1: Resolve work item

Same branch/slug resolution as /work router. Read the tracker.

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
WORK_DIR="$REPO_ROOT/work-items"
echo "WORK_DIR: $WORK_DIR"
```

## Step 2: Tracking validation

Check the tracker for structural correctness:
- Frontmatter has all required fields (name, type, id, status, created)
- Lifecycle section has 4 phases with checkboxes
- Log section has at least one entry
- Acceptance Criteria section exists and has items

Report as a table:
```
| Check | Status | Detail |
|-------|--------|--------|
| Frontmatter complete | PASS/FAIL | {missing fields} |
| Lifecycle structure | PASS/FAIL | {issues} |
| Log non-empty | PASS/FAIL | |
| AC defined | PASS/FAIL | {count} |
```

## Step 3: Doc triplet alignment

If the work item has a doc triplet (PRD.md + ARCHITECTURE.md + TEST-SPEC.md):

Invoke `/align-feature-contract` on the triplet directory using the Skill tool:
```
Skill: align-feature-contract
Args: {path to work item directory}
```

Capture the alignment results (template checks, cross-doc traceability, reference verification).

If no triplet exists (task or defect without docs), skip with note: "No doc triplet found. Skipping alignment check."

## Step 4: Inline quality checks

Run 5 quality checks on available documents:

**C3a: Readability** — Are sections well-written, concise, and clear?
- Check for overly long paragraphs (>10 sentences)
- Check for undefined acronyms
- Score: 1-5

**C3b: Consistency** — Do documents agree with each other?
- PRD user stories match ARCHITECTURE components
- TEST-SPEC test cases reference valid AC numbers
- Score: 1-5

**C4: Template usage quality** — Are template sections properly filled?
- Check for placeholder text remaining ({placeholder} patterns)
- Check for empty required sections
- Score: 1-5

**C6: Cross-references** — Do doc references resolve?
- `prd: PRD.md` in ARCHITECTURE frontmatter → file exists?
- `architecture: ARCHITECTURE.md` in TEST-SPEC frontmatter → file exists?
- Score: 1-5

**C7: Traceability** — Can you trace from requirement to test?
- Every P0 user story has at least one test case
- Every test case references a valid AC
- Score: 1-5

## Step 5: Write findings to journal

Append a journal entry with the unified findings table:

```
### {date} — audit
Quality audit results:

| Layer | Check | Status | Detail |
|-------|-------|--------|--------|
| Tracking | Frontmatter | {PASS/FAIL} | {detail} |
| Tracking | Lifecycle | {PASS/FAIL} | {detail} |
| Alignment | Template L1 | {PASS/FAIL/SKIP} | {detail} |
| Alignment | Traceability L2 | {PASS/FAIL/SKIP} | {detail} |
| Quality | Readability (C3a) | {score}/5 | {detail} |
| Quality | Consistency (C3b) | {score}/5 | {detail} |
| Quality | Template usage (C4) | {score}/5 | {detail} |
| Quality | Cross-refs (C6) | {score}/5 | {detail} |
| Quality | Traceability (C7) | {score}/5 | {detail} |

Overall: {PASS/WARN/FAIL}
```

## Step 6: Handoff

Write handoff block:
```
<!-- HANDOFF: phase=audit status=complete result={PASS/WARN/FAIL} -->
```

## Rules

- **Read-only by default.** Report findings, don't auto-fix.
- **Always write findings to journal.** Even if everything passes, record the audit.
- **Delegate alignment to /align-feature-contract.** Don't duplicate its logic.
