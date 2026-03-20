---
name: document-release
description: Sync release-facing docs after a change ships. Use when README, changelog, architecture notes, or release docs need to match what was just landed.
---

# Document Release

Use this after shipping when user-facing docs need to match the release.

## Rules

- Be conservative. Only update docs clearly contradicted by the shipped diff.
- Never clobber changelog history.
- Prefer polishing or extending the current entry over rewriting it from scratch.
- Every durable doc should be reachable from the repo's README or equivalent entrypoint.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a ship artifact path with `~/.codex/bin/codex-project-log stamp ship document-release`.
3. Read the shipped diff and the docs users actually see first.
4. Update README, architecture notes, contributing notes, repo instructions, or release notes when the diff made them stale.
5. Review discoverability so important docs are linked from the right landing pages.

Use [references/doc-release-template.md](references/doc-release-template.md) as the artifact shape.

## Output

- A release-doc artifact under `ship/`
- Updated release-facing docs in the repo
