---
type: architecture
feature: brownfield-migrator
title: "Brownfield Migrator — Architecture"
version: 1
status: Active
date: 2026-04-09
author: chjiang
prd: PRD.md
---

## Overview

The brownfield migrator (`/migrate`) converts legacy gstack design documents into doc triplet format. It parses source docs to extract content, maps sections to triplet templates, generates the three output files, and produces a structured JSON gap report. The gap report integrates with `/align-feature-contract` via a T1 auto-healing bridge that identifies what still needs human input.

## Architecture

```
Legacy docs                    /migrate skill                  Output
+------------------+           +----------------------+        +-------------------+
| DESIGN.md        |           |                      |        | docs/{family}/    |
| PLAN.md          |--parse--->| Section mapper:      |--gen-->| PRD.md            |
| architecture     |           |   source heading ->  |        | ARCHITECTURE.md   |
| notes            |           |   triplet section    |        | TEST-SPEC.md      |
+------------------+           |                      |        +-------------------+
                               | Gap detector:        |        |                   |
                               |   required sections  |--json->| gap-report.json   |
                               |   - filled sections  |        +-------------------+
                               |   = gaps             |
                               +----------------------+
                                        |
                               /align-feature-contract
                               reads gap-report.json (T1 bridge)
```

### Components Affected

| Component | Path | Change Type | Description |
|-----------|------|------------|-------------|
| Migrate skill | .claude/skills/migrate/SKILL.md | Core | Content extraction, section mapping, triplet generation |
| Gap report | docs/{family}/gap-report.json | Output | JSON listing unfilled sections per doc type |
| Templates | templates/{PRD,ARCHITECTURE,TEST-SPEC}-TEMPLATE.md | Reference | Define required sections for gap detection |
| Align contract | .claude/skills/align-feature-contract/SKILL.md | Integration | T1 bridge reads gap reports |

### Data Flow

1. User invokes `/migrate` with path to legacy doc or batch mode flag
2. Skill reads source doc, splits on `## ` headings, classifies content
3. Section mapper assigns content to PRD, ARCHITECTURE, or TEST-SPEC sections
4. Template required sections minus filled sections yields gap set
5. Three triplet files and gap-report.json are written to docs/{family}/
6. In batch mode, steps 2-5 repeat per family, then summary is printed

## Design Decisions

| Decision | Chosen | Rejected Alternative | Why |
|----------|--------|---------------------|-----|
| JSON gap report | Structured JSON with section-level granularity | Inline TODO comments in generated files | Machine-readable; enables T1 bridge with align-feature-contract |
| Section mapping over AI rewrite | Map existing content to new structure | AI rewrites content into new format | Preserves original author voice; avoids hallucinated content |
