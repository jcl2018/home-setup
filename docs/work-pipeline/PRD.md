---
type: prd
feature: work-pipeline
title: "Work Pipeline — Product Requirements"
version: 1
status: Active
date: 2026-04-09
author: chjiang
---

## Problem Statement

Claude Code sessions are stateless: context about what you are working on, why, and what phase you are in is lost between sessions. Without a structured work lifecycle, implementation starts without requirements, reviews lack context, and shipping has no acceptance gate. The repo owner needs a phase-driven pipeline that tracks work items from idea through shipped.

## Mental Model

Four phases form the pipeline: Track (capture and scaffold) -> Implement (build or debug) -> Review (diff review with context) -> Ship (acceptance gate + PR). The `/work` router detects current phase from branch and manifest state. Each phase skill loads work item context automatically. Journal entries record decisions at each transition.

## User Stories

### P0 (Must-Have)

| # | Tag | What it asks | As a... | I want to... | So that... |
|---|-----|-------------|---------|-------------|------------|
| 1 | core | Can I scaffold a work item with doc triplets? | developer | run `/work-track` to create a tracked work item with PRD + ARCH + TEST-SPEC from templates | every work item starts with structured requirements |
| 2 | core | Does /work route to the correct phase? | developer | run `/work` and have it detect my current phase and suggest the right skill | I never have to remember which skill to invoke |
| 3 | core | Does /work-implement load work context? | developer | start implementing and have the skill auto-load my PRD, architecture, and journal | I have full context without manual file hunting |
| 4 | integration | Does /work-ship validate acceptance criteria? | developer | have shipping blocked until TEST-SPEC acceptance criteria are met | nothing ships without passing its own spec |
| 5 | observability | Does the journal track phase transitions? | developer | have each phase skill append a timestamped journal entry | I can trace the history of decisions on any work item |

## Acceptance Criteria

### Story #1: Scaffold [core]

```
GIVEN templates/ contains PRD-TEMPLATE.md, ARCHITECTURE-TEMPLATE.md, TEST-SPEC-TEMPLATE.md
WHEN  I run /work-track to create a new work item
THEN  a docs/{family}/ directory is created with PRD.md, ARCHITECTURE.md, TEST-SPEC.md
  AND frontmatter fields are populated from the work item metadata
```

### Story #2: Router [core]

```
GIVEN I am on a branch with a work manifest
WHEN  I run /work
THEN  it displays the current phase and suggests the appropriate phase skill
```

## Out of Scope

- Multi-user collaboration on the same work item
- Integration with external issue trackers (GitHub Issues, Linear)
