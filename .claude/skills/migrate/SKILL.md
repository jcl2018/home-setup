---
name: migrate
description: "Brownfield migrator: converts existing gstack design docs into PRD + ARCHITECTURE + TEST-SPEC triplets with structured JSON gap reports."
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
---

# /migrate — Brownfield Design Doc Migrator

Converts existing gstack /office-hours design docs into proper PRD + ARCHITECTURE + TEST-SPEC
triplets. Outputs structured JSON gap reports for future auto-healing (T1 bridge).

## Usage

- `/migrate {path-to-design-doc}` — migrate a single design doc
- `/migrate --all` — migrate all design docs for the current project
- `/migrate --list` — list available design docs without migrating

## Step 1: Discover design docs

```bash
eval "$(~/.claude/skills/gstack/bin/gstack-slug 2>/dev/null)" 2>/dev/null || true
SLUG=${SLUG:-unknown}
DESIGN_DIR="$HOME/.gstack/projects/$SLUG"
echo "SLUG: $SLUG"
echo "DESIGN_DIR: $DESIGN_DIR"
ls -t "$DESIGN_DIR"/*-design-*.md 2>/dev/null | head -30
```

If `--list` mode, display the docs with dates and titles (read first line of each) and stop.

## Step 2: Minimum viable input check

For each design doc, check if it has enough content to migrate:

Read the doc and look for these sections (with common variants):
- Problem Statement (variants: "The Problem", "Problem", "What We're Solving")
- Approaches Considered (variants: "Approaches", "Implementation Approaches", "Options")

**If BOTH are missing:** Skip the doc with notice:
```
SKIP: {filename} — too thin to migrate (no Problem Statement or Approaches section found)
```
Log to gap report and continue to next doc.

**If only Problem Statement exists:** Generate partial triplet (PRD only, ARCHITECTURE and TEST-SPEC get gap entries).

**If both exist:** Full migration.

## Step 3: Extract sections

Map design doc sections to triplet fields:

| Design Doc Section | → | Triplet Field |
|---|---|---|
| Problem Statement | → | PRD: Problem Statement |
| What Makes This Cool | → | PRD: Mental Model |
| Premises | → | PRD: Assumptions |
| Approaches Considered | → | ARCHITECTURE: Design Decisions |
| Recommended Approach | → | ARCHITECTURE: Overview |
| Implementation Plan | → | ARCHITECTURE: Components Affected + Data Flow |
| Success Criteria | → | TEST-SPEC: Test Matrix (infer test cases) |
| Open Questions / Resolved Questions | → | PRD: Out of Scope (unresolved) or Assumptions (resolved) |
| Constraints | → | ARCHITECTURE: Dependencies |
| Key Differences | → | ARCHITECTURE: Design Decisions (additional context) |

**Section name normalization:** Check for common variants of each section name before
declaring it missing.

## Step 4: Generate triplet

Read templates from `~/.claude/templates/`:
- PRD-TEMPLATE.md
- ARCHITECTURE-TEMPLATE.md
- TEST-SPEC-TEMPLATE.md

Fill templates with extracted content. For each section:
- If the design doc has content → fill the section
- If the design doc lacks content → leave the template placeholder AND add a gap entry

### PRD generation
- Problem Statement: directly from design doc
- Mental Model: from "What Makes This Cool" or inferred from Recommended Approach
- User Stories: infer from Success Criteria and Implementation Plan steps
  - Each success metric → one P0 user story
  - Each implementation step → one P0 or P1 user story
- Acceptance Criteria: from Success Criteria (convert to Given/When/Then)
- Assumptions: from Premises + Resolved Questions

### ARCHITECTURE generation
- Overview: from Recommended Approach
- Components Affected: from Implementation Plan file lists
- Design Decisions: from Approaches Considered (chosen vs rejected)
- Dependencies: from Constraints

### TEST-SPEC generation
- Test Matrix: infer from Success Criteria → one test case per metric
- Tier 1 smoke tests: structural checks (file existence, frontmatter)
- Tier 2 E2E tests: from acceptance criteria
- Coverage Gaps: sections that couldn't be auto-filled

## Step 5: Write output

Determine output directory:
- If the design doc's title suggests it belongs to an existing docs/ family → write to `docs/{family}/`
- Otherwise → write to `./work-items/{slug}/` (new work item)

Ask the user: "Write migrated triplet to {output_dir}?"

## Step 6: Gap report (JSON, for T1 auto-healing bridge)

For each migrated doc, generate a structured gap report:

```json
{
  "source": "{design doc filename}",
  "migrated_at": "{ISO datetime}",
  "output_dir": "{path}",
  "gaps": [
    {
      "doc": "PRD.md",
      "section": "User Stories",
      "severity": "warn",
      "reason": "Inferred from success criteria, not explicitly stated in design doc"
    },
    {
      "doc": "ARCHITECTURE.md", 
      "section": "Data Flow",
      "severity": "missing",
      "reason": "No implementation details in source design doc"
    }
  ],
  "coverage": {
    "prd_sections_filled": 5,
    "prd_sections_total": 7,
    "arch_sections_filled": 3,
    "arch_sections_total": 6,
    "spec_sections_filled": 2,
    "spec_sections_total": 4
  }
}
```

Write gap report to `{output_dir}/gaps.json`.

## Step 7: Batch mode (`--all`)

Process all design docs sequentially (one at a time to avoid context limits).
For each doc:
1. Run Step 2 (minimum viable check)
2. If viable, run Steps 3-6
3. Report progress: `[{n}/{total}] Migrating: {filename}...`

After all docs processed, produce summary:
```
Migration Summary
═════════════════
Total design docs found: {N}
Migrated (full):         {N}
Migrated (partial):      {N}
Skipped (too thin):      {N}

Gap reports written to: {list of gaps.json paths}
```

## Rules

- **Never modify the source design doc.** Migration is read-only on the input.
- **Always produce a gap report.** Even 100% coverage gets a gaps.json (with empty gaps array).
- **Ask before writing.** Always confirm the output directory with the user.
- **Normalize section names.** Don't fail on minor naming variants.
- **JSON gap reports are the T1 bridge.** The structured format enables future auto-healing.
