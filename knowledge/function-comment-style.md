# Function Comment Style

- Scope: function-level header or banner comments for codebases that already use them, with C++-first examples.
- When to use this note: when a repo or subsystem expects function banner comments and you need guidance on when to add them, what they should say, and how they should coexist with inline explanatory comments.

## Summary

- Treat function banner comments as a codebase convention, not a universal rule for every repo or language.
- Preserve existing repo or subsystem style where banners are already common, especially in C and C++ codebases.
- Prefer meaningful function comments that describe purpose, contract, side effects, or important context.
- Do not add mechanical banners that only restate the function name or obvious behavior.
- Use [code-change-comment-style.md](code-change-comment-style.md) for inline explanatory comments on non-obvious control flow, lifecycle, ownership, cache invalidation, or dispatch behavior.

## Canonical C++ Banner Template

```cpp
//------------------------------------------------------------
//  Function    : HfssAntennaImpl::GetEKMMetaNodeType
//  Description : Type displayed for the node in the metadata tree
//------------------------------------------------------------
```

## When To Use Function Banners

- The repo or subsystem already uses function header comments as a local style convention.
- The function is public, widely referenced, or sits at a clear API boundary.
- The function purpose is not obvious from the name alone.
- The function has meaningful side effects, lifecycle behavior, ownership expectations, or contract detail that belongs at the function boundary.

## When Not To Add Function Banners

- The repo does not already use function banner comments.
- The function is a trivial getter, setter, wrapper, or one-line helper with a self-explanatory name.
- The banner would only paraphrase the function name without adding useful context.
- The repo already uses another documentation mechanism for the same function boundary.

## Content Guidance

- `Function`: use the fully qualified function name when that matches the local style.
- `Description`: write one clear sentence about purpose or externally visible behavior.
- Add extra lines only when needed for contract, side effects, ownership, lifecycle, or important constraints.
- Keep work item history out of routine function banners unless the repo explicitly expects it there.
- Pair banner comments with inline explanatory comments only when the function body contains non-obvious logic that still needs control-point explanation.

## Repo-Specific Convention Compatibility

- Match the local banner format when a repo already has one.
- Preserve local placement rules, such as whether banners belong on declarations, definitions, or both.
- If the repo does not use banners, do not introduce them as a blanket cleanup.
- When a repo-specific contract disagrees with this note, the repo contract wins.

## Good Vs Bad Examples

- Good: banner states a metadata, lifecycle, or ownership purpose that is not obvious from the name alone.
- Good: banner explains the visible role of a public function even when the implementation is short.
- Bad: `Description : Gets the unique name` on a function already named `GetUniqueName`.
- Bad: stale banner text left behind after a rename or behavior change.
- Bad: copying the same defect ID or review note onto every function banner in a touched file.

## Maintenance Rules For Banner Comments

- Update the banner when the function name, responsibility, or observable behavior changes.
- Remove the banner if the function becomes trivial and the local codebase does not require it.
- Keep the banner consistent with the actual signature and placement used in that repo.
- Treat stale banner comments as correctness bugs in documentation, not harmless noise.

## Source Files Or Docs

- `C:\Users\chjiang\AGENTS.md`
- `C:\Users\chjiang\.codex\knowledge\INDEX.md`
- `C:\Users\chjiang\.codex\knowledge\code-change-comment-style.md`
- `C:\ansysdev\nextgen\products\hfss\HfssAntennaImpl.cpp`

## Last checked

- 2026-03-18
