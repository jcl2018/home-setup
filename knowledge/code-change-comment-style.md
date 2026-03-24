# Code Change Comment Style

- Scope: explanatory code comments for non-trivial code changes that introduce or clarify non-obvious behavior.
- When to use this note: when a change touches lifecycle, ownership, cache invalidation, lazy setup, dispatch, callback routing, or other surprising control flow that a future reader would not reconstruct quickly from syntax alone.

## Summary

- Add comments at control points, not on every line.
- Explain intent, trigger path, ownership, or invalidation semantics, not syntax.
- Prefer short breadcrumbs that help a future reader answer "why is this here?" or "how do we get here?" without opening many files.
- Use this note for inline explanatory comments on non-obvious behavior inside a function body.
- Use [function-comment-style.md](function-comment-style.md) when a codebase expects function header or banner comments at function boundaries.
- When a formal work item exists, include it in the comment text itself using a compact `S1432239: <message>` style near the main non-trivial comment block so review and follow-up context stays attached to the code.
- Use this style only for non-trivial behavior; skip obvious or self-explanatory edits.

## Recommended patterns

- Call-stack breadcrumbs
  - Use for non-obvious entry paths such as view callbacks, background hooks, or lazy initialization.
  - Name the real call path when it is stable enough to help future tracing.
- Lifecycle and ownership notes
  - Use when strong vs weak ownership, per-view state, or mirrored setup/cleanup logic is easy to miss.
- Cache invalidation and rebuild semantics
  - Use when a flag, branch, or helper exists to distinguish valid cached state from "must rebuild" state.
- Branch and flag intent
  - Use when an early return, rebuild guard, or one-shot path would otherwise look arbitrary.
- Symmetric cleanup
  - Use when cleanup intentionally mirrors creation, registration, or invalidation behavior elsewhere.

## Lightweight templates

Use compact patterns like these and adapt them to the local code:

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
// This flag bridges first-time setup and rebuild-after-invalidation paths.
```

```cpp
// Mirror cleanup because this object owns the strong refs while the manager only
// keeps non-owning registrations.
```

## Anti-patterns

- Do not comment obvious assignments, loops, or API calls whose purpose is already clear from naming and nearby code.
- Do not repeat the same explanation at every line inside one block; put the comment at the control point.
- Do not copy the work item ID onto every touched block; use it on the main non-trivial logic or lifecycle comment cluster where the work item context matters.
- Do not present repo-specific details as universal rules in a shared note.
- Do not leave call-stack comments stale; if the real entry path changes materially, update or remove the comment.
- Do not use comments as a substitute for better naming when a rename would make the code self-explanatory.

## Genericized examples

- Work item anchor
  - "S1432239: Rebuild after invalidation because owner ShowDrawing may not fire again."
- Lazy setup path
  - "Reached here through owner visibility... first show builds, later calls return early unless local state has been invalidated."
- Rebuild path
  - "Use this path when state is already known-invalid and the normal show/setup callback may not fire again."
- Ownership cleanup
  - "Mirror cleanup because this layer owns strong refs while the upstream registry keeps only non-owning references."

## Source files or docs

- `C:\Users\chjiang\AGENTS.md`
- `C:\Users\chjiang\.codex\knowledge\INDEX.md`
- `C:\ansysdev\nextgen\products\hfss\HfssAntennaImpl.h`
- `C:\ansysdev\nextgen\products\hfss\HfssAntennaImpl.cpp`

## Last checked

- 2026-03-18
