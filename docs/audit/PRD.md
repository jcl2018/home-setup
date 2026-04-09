---
type: prd
feature: audit
title: "Audit — Product Requirements"
version: 2
status: Active
date: 2026-04-09
author: chjiang
---

## Problem Statement

A self-governing configuration repo needs continuous verification that its principles are being followed, its files are correctly deployed, and its docs are current. Without automated auditing, drift between intent and reality accumulates silently. The repo owner needs deterministic health checks that produce actionable snapshots.

## Mental Model

The audit system has four verification layers unified by `/project:audit`: (1) skill contract validation ensures custom skills have valid contracts with full coverage, (2) doc triplet smoke tests (`/test-align-contract`) check structural integrity of all PRD + ARCHITECTURE + TEST-SPEC families, (3) doc triplet alignment (`/align-feature-contract`) enforces template compliance, cross-doc traceability, and reference verification per family, and (4) deploy drift detection compares repo source against `~/.claude/` deployment. Results are saved as timestamped snapshots to `docs/inspections/`.

## User Stories

### P0 (Must-Have)

| # | Tag | What it asks | As a... | I want to... | So that... |
|---|-----|-------------|---------|-------------|------------|
| 1 | core | Can I run a unified audit with one command? | repo owner | run `/project:audit` and get contract validation + smoke tests + alignment + drift check | I see all issues in one place |
| 2 | core | Does contract validation ensure skill coverage? | repo owner | have `validate-skill-contracts.sh` verify schema + coverage + orphans | every custom skill has a valid contract |
| 3 | core | Does the audit check doc triplet structure? | repo owner | have `/test-align-contract` run Tier 1 smoke tests on all families | structural issues are caught early |
| 4 | core | Does the audit enforce template alignment? | repo owner | have `/align-feature-contract` check L1/L2/L3 per family | template gaps, broken refs, and traceability issues surface |
| 5 | observability | Are audit results saved as snapshots? | repo owner | have each audit run produce a timestamped file in docs/inspections/ | I can track trends over time |
| 6 | core | Does the audit detect deploy drift? | repo owner | have `deploy.sh --dry-run` compare repo vs ~/.claude/ | uncommitted or undeployed changes are flagged |

### P1 (Important)

None for v1.

### P2 (Nice-to-Have)

None for v1.

## Acceptance Criteria

### Story #1: Unified audit [core]

```
GIVEN audit-spec.json defines goals AG1-AG9 and skill-contracts.json exists
WHEN  I run /project:audit
THEN  contract validation, smoke tests, alignment checks, and drift check all run
  AND each stage reports results
  AND a timestamped snapshot is saved to docs/inspections/
```

### Story #2: Contract validation [core]

```
GIVEN skill-contracts.json has entries for all custom skills
WHEN  I run bash scripts/validate-skill-contracts.sh
THEN  every contract passes schema check, all custom skills have contracts, no orphans
  AND exit code is 0
```

### Story #3: Doc triplet smoke tests [core]

```
GIVEN doc triplet families exist under docs/
WHEN  /test-align-contract runs Tier 1 checks
THEN  each family reports PASS or FAIL for structural integrity
```

### Story #4: Template alignment [core]

```
GIVEN a doc triplet family exists with PRD.md, ARCHITECTURE.md, TEST-SPEC.md
WHEN  /align-feature-contract runs L1/L2/L3 checks
THEN  missing template sections are flagged (L1)
  AND broken cross-doc references are flagged (L2)
  AND missing file references are flagged (L3)
```

### Story #5: Snapshot observability [observability]

```
GIVEN docs/inspections/ directory exists
WHEN  /project:audit completes
THEN  a new timestamped .md file appears with the full audit report
```

### Story #6: Deploy drift detection [core]

```
GIVEN deployable files exist in the repo
WHEN  deploy.sh --dry-run runs
THEN  it reports which files would be copied (drift) or confirms zero drift
```

## Success Metrics

| Metric | Target | How Measured |
|--------|--------|-------------|
| Audit coverage | 100% of AG goals have mapped checks | `bash scripts/validate-audit-spec.sh` exits 0 |
| Contract coverage | 100% custom skills have contracts | `bash scripts/validate-skill-contracts.sh` exits 0 |
| Deploy drift | Zero drift after every commit | Post-commit hook auto-deploys |

## Out of Scope

- Automated remediation (audit reports, does not fix)
- Cross-repo auditing (scoped to home-setup only)

## Assumptions

- `audit-spec.json` is maintained as goals evolve
- `/align-feature-contract` and `/test-align-contract` skills are deployed and functional
- `deploy.sh` supports `--dry-run` mode for drift detection
