---
type: test-spec
feature: audit
title: "Audit — Test Specification"
version: 2
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
architecture: ARCHITECTURE.md
---

## Test Matrix

| # | Tag | Test Case | AC | Precondition | Steps | Expected Result | Priority | Type |
|---|-----|-----------|-----|-------------|-------|-----------------|----------|------|
| 1 | core | Unified audit runs all 4 stages | AC-1 | audit-spec.json, skill-contracts.json, and doc triplets exist | Run /project:audit | Output contains contract validation, smoke tests, alignment results, and drift check | P0 | E2E |
| 2 | core | Contract validation passes | AC-2 | skill-contracts.json has entries for all custom skills | Run `bash scripts/validate-skill-contracts.sh` | Exit 0, all schemas valid, full coverage, no orphans | P0 | Unit |
| 3 | core | Doc triplet smoke tests run | AC-3 | Doc triplet families exist under docs/ | Run /test-align-contract | Each family reports structural integrity results | P0 | E2E |
| 4 | core | Template alignment per family | AC-4 | A doc triplet family with PRD, ARCH, TEST-SPEC | Run /align-feature-contract on the family | L1/L2/L3 results reported with specific findings | P0 | E2E |
| 5 | observability | Snapshot saved after audit | AC-5 | docs/inspections/ exists | Run /project:audit | New timestamped .md file appears in docs/inspections/ | P0 | E2E |
| 6 | core | Deploy drift detection | AC-6 | Deployable files exist in repo | Run `bash scripts/deploy.sh --dry-run` | Reports drift or confirms zero drift | P0 | Unit |

## Test Tiers

### Tier 1: Smoke Tests (automated, no live execution)

| # | Tag | Check | What It Validates | Script/Command |
|---|-----|-------|-------------------|---------------|
| S1 | core | audit-spec.json is valid JSON | Spec file is parseable | `jq empty audit-spec.json` |
| S2 | core | Every goal has at least one check | Coverage closure | `bash scripts/validate-audit-spec.sh` |
| S3 | core | Contract validator script exists | Validation pipeline is wired | `test -f scripts/validate-skill-contracts.sh` |
| S4 | core | Audit command exists | Entry point is present | `test -f .claude/commands/audit.md` |
| S5 | core | Alignment skill exists | L1/L2/L3 enforcement is available | `test -f .claude/skills/align-feature-contract/SKILL.md` |
| S6 | core | Smoke test harness exists | Tier 1 testing is available | `test -f .claude/skills/test-align-contract/SKILL.md` |

### Tier 2: E2E Tests (real end-to-end execution)

| # | Tag | Scenario | Steps (as a real user would) | Expected Outcome | Rubric |
|---|-----|----------|----------------------------|-----------------|--------|
| E1 | core | Full audit on clean repo | Run /project:audit on main branch | All stages report, snapshot saved | Pass: snapshot file exists with all 4 stage results |
| E2 | core | Drift detection on synced repo | Run `bash scripts/deploy.sh --dry-run` after deploy | Zero drift reported | Pass: output says zero drift |

## Coverage Gaps

| Gap | Why Not Tested | Risk Accepted |
|-----|---------------|---------------|
| /advisor findings consistency | AI review is non-deterministic | Different findings on same input; mitigated by deterministic stages |
| Snapshot format stability | No schema for snapshot files | Format changes could break trending tools if added later |
