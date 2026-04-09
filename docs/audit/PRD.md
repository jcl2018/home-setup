---
type: prd
feature: audit
title: "Audit — Product Requirements"
version: 1
status: Active
date: 2026-04-09
author: chjiang
---

## Problem Statement

A self-governing configuration repo needs continuous verification that its principles are being followed, its files are correctly deployed, and its docs are current. Without automated auditing, drift between intent and reality accumulates silently. The repo owner needs deterministic health checks plus AI-powered content review that produce actionable snapshots.

## Mental Model

Two audit layers: `/home-inspect` runs deterministic 5-room health checks (file existence, sync, hygiene) against `audit-spec.json` goals AG1-AG9. `/governance-audit` adds AI content review for doc quality and principle alignment. `/project:audit` unifies both into a single command that saves timestamped snapshots to `docs/inspections/`.

## User Stories

### P0 (Must-Have)

| # | Tag | What it asks | As a... | I want to... | So that... |
|---|-----|-------------|---------|-------------|------------|
| 1 | core | Can I run a unified audit with one command? | repo owner | run `/project:audit` and get a combined health + governance report | I see all issues in one place |
| 2 | core | Does the 5-room health check cover AG1-AG9? | repo owner | have each audit check map to a specific audit goal | every check has a traceable purpose |
| 3 | observability | Are audit results saved as snapshots? | repo owner | have each audit run produce a timestamped file in docs/inspections/ | I can track trends over time |
| 4 | core | Does governance-audit review content quality? | repo owner | have AI review docs for accuracy, staleness, and principle violations | content problems surface alongside structural ones |

## Acceptance Criteria

### Story #1: Unified audit [core]

```
GIVEN audit-spec.json defines goals AG1-AG9 with mapped checks
WHEN  I run /project:audit
THEN  all 5 rooms are checked, governance review runs, and a snapshot is saved
  AND each check reports PASS, WARN, or FAIL
```

### Story #2: Goal traceability [core]

```
GIVEN audit-spec.json maps each check to one or more goals
WHEN  I run bash scripts/validate-audit-spec.sh
THEN  every goal AG1-AG9 has at least one check and exit code is 0
```

## Out of Scope

- Automated remediation (audit reports, does not fix)
- Cross-repo auditing (scoped to home-setup only)
