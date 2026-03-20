---
name: careful
description: Turn on destructive-command warning mode. Use when the task touches risky commands, cleanup work, or a shared environment.
---

# Careful

Run `~/.codex/bin/codex-guardrails careful` to set `mode = "careful"` in `~/.codex/guardrails/current.toml`.

## What It Protects

The guardrail helper flags common destructive patterns such as:

- recursive deletes
- destructive SQL
- force pushes
- hard resets
- cluster deletes
- aggressive Docker cleanup

Check a command manually with:

`~/.codex/bin/codex-guardrails check-command "<command>"`

In Codex this is advisory, not a literal hook. The assistant should check and honor it before risky commands.

Use this when you want warning mode without an edit boundary.
