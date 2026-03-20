---
name: unfreeze
description: Clear the active guardrail boundary. Use when the user wants to remove freeze or guard mode.
---

# Unfreeze

Run `~/.codex/bin/codex-guardrails unfreeze` to clear the current guardrail state back to `mode = "off"`.

After clearing, both command and path checks should allow normal work again unless another safety mode is enabled.
