---
type: test-spec
feature: audit
title: "Audit — Test Specification"
version: 1
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
architecture: ARCHITECTURE.md
---

## Test Matrix

| # | Tag | Test Case | AC | Precondition | Steps | Expected Result | Priority | Type |
|---|-----|-----------|-----|-------------|-------|-----------------|----------|------|
| 1 | core | Unified audit runs both engines | AC-1 | audit-spec.json and both skills exist | Run /project:audit | Output contains room results and governance findings | P0 | E2E |
| 2 | core | Coverage closure validation | AC-2 | audit-spec.json has goals and checks | Run `bash scripts/validate-audit-spec.sh` | Exit 0, every AG goal has at least one check | P0 | Unit |
| 3 | observability | Snapshot is saved after audit | AC-1 | docs/inspections/ exists | Run /project:audit | New timestamped .md file appears in docs/inspections/ | P0 | E2E |

## Test Tiers

### Tier 1: Smoke Tests (automated, no live execution)

| # | Tag | Check | What It Validates | Script/Command |
|---|-----|-------|-------------------|---------------|
| S1 | core | audit-spec.json is valid JSON | Spec file is parseable | `jq empty audit-spec.json` |
| S2 | core | Every goal has at least one check | Coverage closure | `bash scripts/validate-audit-spec.sh` |
| S3 | core | Both audit skills exist | Audit pipeline is wired | `test -f .claude/skills/home-inspect/SKILL.md && test -f .claude/skills/governance-audit/SKILL.md` |

### Tier 2: E2E Tests (real end-to-end execution)

| # | Tag | Scenario | Steps (as a real user would) | Expected Outcome | Rubric |
|---|-----|----------|----------------------------|-----------------|--------|
| E1 | core | Full audit on clean repo | Run /project:audit on main branch | All rooms report, snapshot saved, zero FAIL on clean state | Pass: no FAIL results, snapshot file exists |

## Coverage Gaps

| Gap | Why Not Tested | Risk Accepted |
|-----|---------------|---------------|
| Governance audit consistency across runs | AI review is non-deterministic | Different findings on same input; mitigated by deterministic pass catching structural issues |
| Snapshot format stability | No schema for snapshot files | Format changes could break trending tools if added later |
