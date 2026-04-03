---
name: governance-audit
description: Content quality audit with deterministic pass + AI review pass. Never modifies files, only flags findings.
---

# /governance-audit — Governance Engine

Two-pass content quality review. Never modifies files. Only flags findings.

Reference: `audit-spec.json` maps each check ID to audit goals (AG1-AG9).

## Pass 1: Deterministic (zero false positives)

These checks are mechanical. If they fire, there's a real problem.

### G1.1: Link targets
Scan all markdown files in `docs/design/`, `docs/operations/`, `README.md`, `CLAUDE.md`.
For each `[text](path)` link, verify the target file exists (resolve relative paths from the linking file's directory).
Skip external URLs (http/https) and anchor-only links (#...).

### G1.2: Layout tree paths
Parse the layout tree in `CLAUDE.md` (inside the ``` block under `## Layout`).
Extract every file and directory path listed. Verify each exists on disk.
Report missing entries.

### G1.3: Rule frontmatter paths
For each `.claude/rules/*.md` file, parse the YAML frontmatter `paths:` array.
Verify each glob pattern matches at least one file in the repo.

### G1.4: Principle citations
For each `.claude/rules/*.md` file, verify the body references at least one principle (P1, P2, P3, P5, P11) or decision (D1-D11).

### G1.5: TODOS.md staleness
If `TODOS.md` exists, check each TODO item. WARN if any item has no progress for 30+ days.

## Pass 2: AI Review (non-deterministic)

Read every doc file (CLAUDE.md, README.md, docs/design/*.md, docs/operations/*.md, knowledge/*.md).
For each, answer 6 questions. Flag issues only if confident.

### G2.1: Still true?
Are factual claims in this doc still accurate? Compare claims against the actual repo state.
Example: "35 skills total" — count the catalog and verify.

### G2.2: Still aligned?
Do directives in this doc match the 5 active principles (P1, P2, P3, P5, P11)?
Flag any directive that contradicts a principle.

### G2.3: Still useful?
Is any content stale, redundant, or no longer valuable?
Flag content that adds no value or references deleted features.

### G2.4: Right place?
Is content in the correct doc per the lanes table in `docs/design/PHILOSOPHY.md`?
Example: principles described in README.md instead of PHILOSOPHY.md.

### G2.5: Consistent?
Is the same concept described the same way across all docs?
Flag contradictions between files.

### G2.6: No overlapping scope?
Do any two skills, rules, or commands cover the same functionality?
Flag redundancy.

## Output Format

```
=== GOVERNANCE AUDIT ===

--- Pass 1: Deterministic ---
[PASS|FAIL] G1.1 Link targets — {N} links checked, {M} broken
[PASS|FAIL] G1.2 Layout tree — {N} paths, {M} missing
...

--- Pass 2: AI Review ---
[PASS|WARN] G2.1 Still true? — {findings or "no issues"}
[PASS|WARN] G2.2 Still aligned? — {findings or "no issues"}
...

=== Summary ===
Pass 1: X/5 pass
Pass 2: X/6 pass
Total: X/11 pass, Y warn, Z fail
```

## Important

- Never modify files. Report only.
- Pass 1 findings are definitive (fix them). Pass 2 findings are advisory (investigate them).
- Governance-audit does NOT block deploy. It informs. The user decides what to fix.
