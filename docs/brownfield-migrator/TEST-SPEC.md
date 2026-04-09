---
type: test-spec
feature: brownfield-migrator
title: "Brownfield Migrator — Test Specification"
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
| 1 | core | Single doc produces triplet + gap report | AC-1 | Legacy DESIGN.md exists | Run /migrate on the file | PRD.md, ARCHITECTURE.md, TEST-SPEC.md, and gap-report.json created | P0 | E2E |
| 2 | core | Gap report lists unfilled sections | AC-1 | Source doc lacks test information | Run /migrate | gap-report.json includes TEST-SPEC sections as gaps | P0 | E2E |
| 3 | usability | Batch mode processes multiple families | AC-3 | Multiple legacy docs exist | Run /migrate in batch mode | Each family gets triplet + gap report; summary printed | P0 | E2E |

## Test Tiers

### Tier 1: Smoke Tests (automated, no live execution)

| # | Tag | Check | What It Validates | Script/Command |
|---|-----|-------|-------------------|---------------|
| S1 | core | Migrate skill exists | Migration capability is present | `test -f .claude/skills/migrate/SKILL.md` |
| S2 | core | Migrate skill is in catalog | Catalog tracks the skill | `jq -e '.skills[] \| select(.name=="migrate")' skills-catalog.json > /dev/null` |

### Tier 2: E2E Tests (real end-to-end execution)

| # | Tag | Scenario | Steps (as a real user would) | Expected Outcome | Rubric |
|---|-----|----------|----------------------------|-----------------|--------|
| E1 | core | Migrate a real legacy doc | Point /migrate at docs/design/PHILOSOPHY.md as source | Triplet created with principles mapped to PRD, structure mapped to ARCH | Pass: all 3 files created, gap-report.json present |
| E2 | integration | Gap report feeds align-contract | Run /migrate then /align-feature-contract on same family | Align-contract findings match gap-report gaps | Pass: no surprise gaps beyond what gap-report listed |

## Coverage Gaps

| Gap | Why Not Tested | Risk Accepted |
|-----|---------------|---------------|
| Docs with non-standard heading structures | Infinite variation in legacy formats | Unmappable content lands in gap report rather than silently dropped |
| T1 auto-healing bridge end-to-end | Requires both skills to coordinate on gap-report.json schema | Schema mismatch caught when bridge is first used |
