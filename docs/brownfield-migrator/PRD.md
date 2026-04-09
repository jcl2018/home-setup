---
type: prd
feature: brownfield-migrator
title: "Brownfield Migrator — Product Requirements"
version: 1
status: Active
date: 2026-04-09
author: chjiang
---

## Problem Statement

Gstack projects accumulate design docs (DESIGN.md, PLAN.md, architecture notes) in formats that predate the doc triplet system. Converting these manually into PRD + ARCHITECTURE + TEST-SPEC is tedious and error-prone, with content scattered across source files and gaps left unfilled. The repo owner needs an automated migrator that extracts structured content from legacy docs and produces compliant triplets with explicit gap reports.

## Mental Model

The `/migrate` skill reads existing design docs, maps their content to triplet sections, generates PRD + ARCHITECTURE + TEST-SPEC files, and produces a JSON gap report listing sections that could not be filled from source material. The gap report enables a T1 auto-healing bridge: the align-feature-contract skill can read gaps and prompt the user to fill them. Batch mode processes multiple families in one invocation.

## User Stories

### P0 (Must-Have)

| # | Tag | What it asks | As a... | I want to... | So that... |
|---|-----|-------------|---------|-------------|------------|
| 1 | core | Can I convert a DESIGN.md into a triplet? | repo owner | run `/migrate` on a legacy design doc and get PRD + ARCH + TEST-SPEC | I don't have to manually restructure existing docs |
| 2 | core | Does migration produce a gap report? | repo owner | get a JSON report listing which triplet sections could not be filled | I know exactly what needs manual attention |
| 3 | usability | Can I migrate multiple families at once? | repo owner | run batch mode and have all legacy docs converted in one pass | bulk migration is efficient |

## Acceptance Criteria

### Story #1: Single doc migration [core]

```
GIVEN a legacy DESIGN.md exists for a feature family
WHEN  I run /migrate pointing to that file
THEN  PRD.md, ARCHITECTURE.md, and TEST-SPEC.md are created in docs/{family}/
  AND content from DESIGN.md is mapped to appropriate sections
  AND a gap-report.json is created listing unfilled sections
```

### Story #3: Batch mode [usability]

```
GIVEN multiple legacy design docs exist across families
WHEN  I run /migrate in batch mode
THEN  each family gets its triplet + gap report
  AND a summary reports total families processed and total gaps found
```

## Out of Scope

- Migrating non-markdown formats (PDF, Notion, Google Docs)
- Auto-filling gaps with AI-generated content (gaps are reported, not filled)
