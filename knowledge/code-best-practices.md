# Code Best Practices

- Scope: conventions for documenting code changes — commit messages, PR descriptions, inline comments, and function banners.
- When to use this note: when writing a commit, PR description, or code comment for a non-trivial change. Also when reviewing someone else's PR for documentation quality.
- Last checked: 2026-03-23

---

## 1. Work Item Traceability

All tracked work uses a consistent work item ID format across commits, PRs, and code comments.

- **Commit subject**: `S1432239: fix array instancing after save`
- **PR body**: start with `[S1432239]` on the first line
- **Code comment**: `// S1432239: Rebuild after invalidation because owner ShowDrawing may not fire again.`

Use the canonical work item ID. If the system has both a work item and a defect/task link, prefer the canonical ID and add others in a references section.

---

## 2. Commit Messages

### Template

```text
S1432239: fix array instancing after save
```

### With body (for non-obvious, risky, or multi-part changes)

```text
S1432239: fix array instancing after save

- Rebuild optimized instance renderers after invalidation.
- Keep repeated owner show paths from rebuilding valid per-view state.
- Preserve save/synchronize recovery when the owner drawing is already visible.
```

### Rules

- Start with work item ID, colon, imperative summary of the outcome.
- Keep subject short, behavior-focused. Prefer "fix", "update", "avoid", "add", "refactor".
- Add body only when it improves future traceability (the why, the risky path, grouped changes).
- Do not list file names in the subject.
- Do not use vague subjects like `S1432239: updates`.
- For simple single-purpose commits, subject alone is enough.

---

## 3. PR Descriptions

### Quick start

1. Start with `[S1432239]` on the first line.
2. Write `Summary` and `What Changed` in plain language.
3. If behavior or lifecycle changed, add `Affected Workflows`.
4. Reuse the same workflow names in `Test Matrix`.
5. Delete any section that does not add value.

### Lightweight template (small PRs)

```md
[S1432239]

## Summary

Brief outcome of the change.

## What Changed

- Main behavior or implementation change.
- Any non-obvious detail that matters for review.

## Affected Workflows

- Workflow name: why it changed, important call path or state if relevant.

## Test Matrix

| Scenario | How verified | Result |
| --- | --- | --- |
| Same workflow name | Exact repro step or command | Pass / Fail |
```

### Full template (complex PRs)

```md
[S1432239]

## Summary

Briefly state the outcome and the main behavior difference.

## Motivation / Context

Why this PR exists now, what problem it addresses.

## What Changed

- Group by behavior or subsystem, not by file.
- Call out non-obvious implementation choices only if they matter for review.

## Affected Workflows

- One bullet per workflow or scenario.
- Include: what triggers it, why affected, main functions/call path when relevant.
- Use the same names in Test Matrix.

## Reviewer Focus

- Point reviewers to risky logic, non-obvious control flow, or behavior changes.
- Call out areas where output looks similar but implementation changed.

## Test Matrix

| Scenario | How verified | Result |
| --- | --- | --- |
| Example path | Exact command or repro steps | Pass / Fail |

## User Impact

Include when user-visible behavior, workflows, or outputs change.

## Breaking Changes / Migration

Include when callers, configs, schemas, or workflows must change.
```

### PR description rules

- **Outcome-focused, behavior-focused, reviewer-friendly.** Not a file changelog.
- **4000 character limit** assumed unless told otherwise. Trim optional sections first.
- **Priority sections** (keep under size pressure): Work item, Summary, What Changed, Affected Workflows, Test Matrix.
- **Trimmable sections**: Motivation/Context, Reviewer Focus, User Impact, Breaking Changes, Screenshots/Logs.
- **Test Matrix**: only executable verification scenarios. No code review, inspection, or `git diff --check`. Each row names the design/setup, action, and expected outcome.

### PR anti-patterns

- Do not paste a file-by-file changelog as the main PR body.
- Do not repeat commit messages section by section.
- Do not leave placeholder text in optional sections.
- Do not claim testing without naming the scenario and verification method.
- Do not use the test matrix for "verified by reading code."

---

## 4. Code Comments — Inline

For non-trivial code changes involving lifecycle, ownership, cache invalidation, lazy setup, dispatch, or surprising control flow.

### When to comment

- Non-obvious entry paths (view callbacks, background hooks, lazy init)
- Lifecycle and ownership (strong vs weak refs, per-view state, mirrored setup/cleanup)
- Cache invalidation and rebuild semantics (flags, branches, helpers for valid vs must-rebuild)
- Branch and flag intent (early returns, rebuild guards, one-shot paths)
- Symmetric cleanup that mirrors creation/registration elsewhere

### When NOT to comment

- Obvious assignments, loops, or API calls clear from naming
- Every line in a block (put the comment at the control point instead)
- When a rename would make the code self-explanatory

### Templates

```cpp
// S1432239: Rebuild after invalidation because owner ShowDrawing may not fire again.
```

```cpp
// Reached here through:
// A::EntryPoint ->
// B::Dispatch ->
// C::Callback.
```

```cpp
// Use this path when local state is already known-invalid and we cannot rely on
// the normal entry point to rebuild it.
```

```cpp
// Mirror cleanup because this object owns the strong refs while the manager only
// keeps non-owning registrations.
```

### Comment anti-patterns

- Do not repeat the work item ID on every touched block — use it on the main non-trivial logic.
- Do not leave call-stack comments stale; update when the real entry path changes.
- Do not use comments as a substitute for better naming.

---

## 5. Code Comments — Function Banners

For codebases (especially C++) that already use function header comments as a convention.

### Template

```cpp
//------------------------------------------------------------
//  Function    : HfssAntennaImpl::GetEKMMetaNodeType
//  Description : Type displayed for the node in the metadata tree
//------------------------------------------------------------
```

### When to add banners

- The repo/subsystem already uses them as a local style convention.
- The function is public, widely referenced, or at a clear API boundary.
- The function purpose is not obvious from the name alone.
- There are meaningful side effects, lifecycle behavior, or contract details.

### When NOT to add banners

- The repo does not already use function banner comments.
- The function is a trivial getter/setter/wrapper with a self-explanatory name.
- The banner would only paraphrase the function name.

### Maintenance

- Update the banner when function name, responsibility, or behavior changes.
- Remove the banner if the function becomes trivial and the codebase does not require it.
- Treat stale banners as documentation bugs, not harmless noise.
- When a repo-specific convention disagrees with this note, the repo convention wins.

---

## General Principles

- **Behavior over files**: group changes by behavior or subsystem, not by file path.
- **Outcome over mechanics**: describe what changed and why, not what lines were touched.
- **Consistent traceability**: same work item ID format across commits, PRs, and code comments.
- **Trim to signal**: remove sections that only say "none" or repeat obvious facts.
- **Repo convention wins**: when a repo's CLAUDE.md or local style disagrees with this guide, follow the repo.
- **Prefer explicit named-boolean comparisons** in review (e.g., `clear == false` over `!clear`) when that is the local review preference.
