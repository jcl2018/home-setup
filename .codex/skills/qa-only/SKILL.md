---
name: qa-only
description: Test and report only. Use when the user wants a pure QA report without code changes.
---

# QA Only

Use this when the user wants defects reported but not fixed in the same pass.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a QA artifact path with `~/.codex/bin/codex-project-log stamp qa qa-only`.
3. Use the repo's own browser or test tooling when available.
4. Record the report without making code changes.

## Output

- A report-only QA artifact under `qa/`
- Findings, severity, and reproduction notes
