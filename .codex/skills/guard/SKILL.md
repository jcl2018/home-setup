---
name: guard
description: Turn on both warning mode and an edit boundary. Use for maximum safety when the user wants the session locked down.
---

# Guard

Run `~/.codex/bin/codex-guardrails guard <absolute-or-relative-path>` to set both careful mode and a freeze boundary in `~/.codex/guardrails/current.toml`.

Then use:

- `~/.codex/bin/codex-guardrails check-command "<command>"`
- `~/.codex/bin/codex-guardrails check-path <file>`

This is the closest Codex-native equivalent to the Claude hook-based safety layer.

Use this when the user wants both protections active at once.
