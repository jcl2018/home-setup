# Umbrella Workspace Bootstrap

Use this path when the target root is a non-git workspace that coordinates multiple child git repos.

## Checklist

1. Confirm the parent root is acting as shared workspace context, not as a normal single repo.
2. Create or tighten a lightweight root `AGENTS.md`.
3. Create or refresh the root `.local-work/current.md`.
4. Declare the child repos explicitly in the root contract.
5. Traverse only the declared child repos.
6. For each child repo, reuse the existing `existing-repo` or `new-repo` flow.
7. Run the smallest real verification command in each touched child repo.

## Detect The Umbrella Shape

Use this path when all of these are true:

- The parent folder is not the main git repo for the work.
- The parent coordinates shared context or docs across multiple child repos.
- One or more child folders are real git repos that should keep their own contracts and verification commands.

Use local inspection only to decide that the target behaves like an umbrella workspace. Once you commit to this path, the explicit `Child Repos` list becomes the only source of truth for later traversal and audits.

## Root Contract Shape

The umbrella root may keep:

- A root `AGENTS.md` even though the parent folder is not itself a git repo.
- A root `.local-work/current.md` for umbrella-level work only.
- Shared docs or notes that help coordinate the child repos.

The root `AGENTS.md` should stay short and must include a `Child Repos` section:

- List child repo paths relative to the umbrella root.
- Keep the list explicit; do not describe discovery rules.
- Keep shared constraints and shared doc locations here only when they are genuinely cross-repo.
- Do not duplicate child build, test, lint, typecheck, or architecture commands here.

## Traverse Child Repos

After the `Child Repos` list exists:

- Traverse only the declared child paths.
- Ignore unlisted sibling folders.
- For each child path, confirm it stays inside the umbrella root and points to a real git repo.
- For each valid child repo, choose the normal path:
  - existing child repo -> [existing-repo.md](existing-repo.md)
  - empty or greenfield child repo -> [new-repo.md](new-repo.md)

## Structural Issues

Treat these as structural findings that should be fixed in the root contract before finishing:

- Missing `Child Repos` section.
- Duplicate child paths.
- Absolute paths or paths that escape the umbrella root.
- Listed paths that do not exist.
- Listed paths that are not actual git repos.

## Done Condition

Before finishing, provide:

- The umbrella root path and the declared child repo list.
- The files created or updated at the umbrella root.
- The exact verification command run in each touched child repo.
- Any listed child path that could not be validated and the smallest follow-up needed.
