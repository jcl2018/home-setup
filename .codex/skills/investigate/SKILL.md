---
name: investigate
description: Systematic debugging with root-cause-first discipline. Use when something is broken, the cause is unclear, or a bug needs evidence before code changes.
---

# Investigate

Use this when the next step should be evidence, not guessing.

## Iron Law

No fixes without root cause investigation first.

## Phase 1: Root Cause Investigation

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Reserve an investigation artifact with `~/.codex/bin/codex-project-log stamp reviews investigate`.
3. Collect the symptom, error output, reproduction steps, and affected codepath.
4. Read recent changes in the affected area before forming a hypothesis.
5. Try to reproduce the issue deterministically. If reproduction is weak, gather more evidence before proposing a fix.

Use [references/investigation-template.md](references/investigation-template.md) as the artifact shape.

## Scope Lock

After a plausible root-cause area is known, consider a temporary edit boundary.

- Use `freeze` when the bug is isolated to one module or directory.
- Use `guard` when the bug is isolated and the session is risky.
- Check the boundary manually with `~/.codex/bin/codex-guardrails check-path <file>`.

## Phase 2: Pattern Analysis

Check whether the bug matches a known pattern:

- race condition
- nil or null propagation
- partial state corruption
- integration failure
- configuration drift
- stale cache or stale derived state

Also check whether the same files have recurring bug-fix history. Repeated fixes in the same area often mean the architecture, not just the implementation, is weak.

## Phase 3: Hypothesis Testing

Before writing a fix:

1. State a specific hypothesis.
2. Add temporary instrumentation or a focused repro to confirm it.
3. If the hypothesis fails, return to evidence gathering.
4. If three hypotheses fail, stop and escalate instead of guessing.

## Phase 4: Implementation

Only after the root cause is confirmed:

1. Implement the smallest fix that addresses the actual cause.
2. Add regression coverage when the repo has a suitable test surface.
3. Re-run the focused reproduction and the smallest relevant verification.
4. Capture residual uncertainty if the fix is still partly inferential.

## Output

- A root-cause note under `reviews/`
- Evidence, hypotheses, and the smallest credible fix
- A clear verification result
