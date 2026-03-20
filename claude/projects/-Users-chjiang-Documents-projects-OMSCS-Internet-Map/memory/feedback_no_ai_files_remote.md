---
name: No AI config files on remote
description: Never push CLAUDE.md, AGENTS.md, or other AI tool config files to shared remotes
type: feedback
---

Do not commit or push AI-related files (CLAUDE.md, AGENTS.md, KNOWLEDGE.md) to remote repositories.
**Why:** Charlie wants AI config to stay local-only — these are personal workflow files, not shared project artifacts.
**How to apply:** Always use `.git/info/exclude` or `--skip-worktree` for AI config files. Never stage them for commits. If editing a tracked CLAUDE.md, revert before committing.
