---
type: architecture
feature: audit
title: "Audit — Architecture"
version: 2
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
---

## Overview

The audit system uses a four-stage pipeline unified by the `/project:audit` command: contract validation verifies skill-contracts.json schema and coverage, smoke tests (`/test-align-contract`) check structural integrity of doc triplets, alignment checks (`/align-feature-contract`) enforce template compliance and cross-doc traceability per family, and deploy drift detection (`deploy.sh --dry-run`) compares repo source against the `~/.claude/` deployment. Results are saved as timestamped snapshots.

## Architecture

```
/project:audit (command — .claude/commands/audit.md)
  |
  +---> 1. validate-skill-contracts.sh
  |       +-- Schema validation (all contracts well-formed)
  |       +-- Coverage check (all custom skills have contracts)
  |       +-- Orphan check (no contracts without skills)
  |
  +---> 2. /test-align-contract (Tier 1 smoke tests)
  |       +-- Discover all docs/{family}/ with complete triplets
  |       +-- Structural integrity per family
  |
  +---> 3. /align-feature-contract (per family)
  |       +-- L1: Template alignment (required sections)
  |       +-- L2: Cross-doc traceability (frontmatter refs, IDs)
  |       +-- L3: Reference verification (files exist on disk)
  |
  +---> 4. deploy.sh --dry-run
  |       +-- Compare repo files vs ~/.claude/ deployment
  |       +-- Report drift or confirm zero drift
  |
  +---> Save snapshot to docs/inspections/audit-{timestamp}.md
```

### Components Affected

| Component | Path | Change Type | Description |
|-----------|------|------------|-------------|
| Audit command | .claude/commands/audit.md | Core | Unified entry point for /project:audit |
| Contract validator | scripts/validate-skill-contracts.sh | Core | Schema + coverage + orphan checks for skill contracts |
| Smoke test harness | .claude/skills/test-align-contract/SKILL.md | Core | Tier 1 structural checks on all doc triplets |
| Alignment enforcer | .claude/skills/align-feature-contract/SKILL.md | Core | L1/L2/L3 template and traceability enforcement |
| Deploy script | scripts/deploy.sh | Core | Drift detection via --dry-run mode |
| Audit spec | audit-spec.json | Reference | Goal definitions (AG1-AG9) and check-to-goal mappings |
| Spec validator | scripts/validate-audit-spec.sh | Core | Verifies every goal has at least one check |
| Snapshots | docs/inspections/*.md | Output | Timestamped audit result archives |

### Data Flow

1. `/project:audit` runs `validate-skill-contracts.sh` to verify contract integrity
2. `/test-align-contract` discovers all doc triplet families and runs smoke tests
3. For each family, `/align-feature-contract` runs L1/L2/L3 alignment checks
4. `deploy.sh --dry-run` compares repo source against ~/.claude/ deployment
5. All results are combined into a timestamped snapshot saved to `docs/inspections/`

## API Changes

No API changes. The `/project:audit` command is the sole entry point.

## Dependencies

| Dependency | Type | Description |
|-----------|------|-------------|
| audit-spec.json | Internal | Goal definitions and check-to-goal mappings |
| skill-contracts.json | Internal | Behavioral contracts for custom skills |
| /align-feature-contract | Skill | Template alignment and traceability enforcement |
| /test-align-contract | Skill | Tier 1 structural smoke tests |
| jq | External | JSON parsing for validation scripts |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| New skills added without contracts | Medium | Low | `validate-skill-contracts.sh` catches missing contracts |
| Template changes invalidating all families | Low | High | Template changes require re-running audit to verify |
| audit-spec.json goals drifting from actual checks | Low | Medium | `validate-audit-spec.sh` enforces coverage closure |

## Design Decisions

| Decision | Chosen | Rejected Alternative | Why |
|----------|--------|---------------------|-----|
| Four-stage pipeline | Contract + smoke + alignment + drift | Single monolithic audit script | Each stage is independently useful and testable |
| Check-to-goal mapping in JSON | audit-spec.json with explicit goal arrays | Implicit mapping in skill code | Enables automated coverage validation via validate-audit-spec.sh |
