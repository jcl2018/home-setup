---
name: freeze
description: Restrict edits to one directory. Use when the user wants an explicit edit boundary for a risky or focused session.
---

# Freeze

Run `~/.codex/bin/codex-guardrails freeze <absolute-or-relative-path>` to set an edit boundary in `~/.codex/guardrails/current.toml`.

Check a path manually with:

`~/.codex/bin/codex-guardrails check-path <file>`

In Codex this is advisory, not a literal edit hook. The assistant should check and honor it before edits.

Use this when edits should stay inside one directory tree.
