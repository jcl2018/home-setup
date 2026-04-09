---
type: architecture
feature: audit
title: "Audit — Architecture"
version: 1
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
---

## Overview

The audit system uses a two-layer architecture: a deterministic health engine (`/home-inspect`) that runs structural checks organized into 5 rooms, and an AI content engine (`/governance-audit`) that reviews doc quality and principle alignment. Both are unified by the `/project:audit` command, which orchestrates execution and saves snapshots.

## Architecture

```
/project:audit (command)
  |
  +---> /home-inspect (deterministic)      /governance-audit (AI)
  |       |                                   |
  |       +-- Room 1: Deploy sync (AG1)       +-- Doc accuracy review
  |       +-- Room 2: Functional (AG2-AG5)    +-- Principle alignment
  |       +-- Room 3: Hygiene (AG6, AG9)      +-- Content quality
  |       +-- Room 4: Knowledge (AG1, AG4-5)  |
  |       +-- Room 5: Advisory (AG7)          |
  |       |                                   |
  +-------+-----------------------------------+
          |
          v
    docs/inspections/{timestamp}.md (snapshot)
```

### Components Affected

| Component | Path | Change Type | Description |
|-----------|------|------------|-------------|
| Audit command | .claude/commands/audit.md | Core | Unified entry point for /project:audit |
| Home inspect | .claude/skills/home-inspect/SKILL.md | Core | 5-room deterministic health checks |
| Governance audit | .claude/skills/governance-audit/SKILL.md | Core | AI-powered content quality review |
| Audit spec | audit-spec.json | Reference | Goal definitions (AG1-AG9) and check-to-goal mappings |
| Validation | scripts/validate-audit-spec.sh | Core | Verifies every goal has at least one check |
| Snapshots | docs/inspections/*.md | Output | Timestamped audit result archives |

### Data Flow

1. `/project:audit` invokes `/home-inspect` first
2. Home inspect reads `audit-spec.json`, runs checks per room, reports PASS/WARN/FAIL
3. `/governance-audit` runs AI content review on docs and skills
4. Results are combined into a snapshot saved to `docs/inspections/`

## Design Decisions

| Decision | Chosen | Rejected Alternative | Why |
|----------|--------|---------------------|-----|
| Deterministic + AI two-pass | Separate engines for structural and content | Single AI-only audit | Deterministic pass catches regressions without AI cost; AI pass catches semantic issues |
| Check-to-goal mapping in JSON | audit-spec.json with explicit goal arrays | Implicit mapping in skill code | Enables automated coverage validation via validate-audit-spec.sh |
