# Lv0 Home Codex Settings Export PRD

## Purpose

Define what a static home mirror must include, exclude, and regenerate when exporting the Codex home control layer.

## Desired State

- Export includes `~/AGENTS.md`, `~/.codex/.local-work/current.md`, `~/.codex/config.toml`, custom home skills except `.system`, home knowledge, and automation `automation.toml` files.
- Export includes the PRD tree through `~/.codex/knowledge/` rather than any special summary file.
- Export excludes secrets, auth, caches, sessions, sqlite state, runtime logs, and other volatile artifacts.
- Export normalizes machine-specific text values for portability by rewriting the source home root to `~` inside exported text files.
- Export omits top-level OS-specific tables such as `[windows]`, `[macos]`, and `[linux]` from the mirrored `.codex/config.toml`.
- Export refreshes the manifest and the mirror `README.md` on each run.
- Managed mirror roots are authoritative inside the mirror repo, and stale managed files are pruned on refresh.

## Audit Checklist

- No retired standalone summary files are listed as first-class managed inputs.
- The generated README describes the PRD-backed knowledge tree accurately and does not mention install or restore workflows.
- Export leaves unrelated files outside managed roots untouched.
- Export still works when run against a non-default home root for testing.

## Success Criteria

- A fresh export produces a complete static mirror of the current home control layer.
- A fresh export no longer hard-codes one machine's absolute home path throughout the mirrored docs and automations.
- The mirror contains the home workflow docs and PRDs without requiring manual scavenging from the live home directory.

## Out of Scope

- Exporting secrets or volatile runtime state.
- Bundling restore or install helpers inside the mirror repo.
- Pushing the mirror repo unless the user explicitly asks.

## Related Sources

- `~/.codex/skills/lv0-home-codex-settings-export/SKILL.md`
- `~/.codex/skills/lv0-home-codex-settings-export/scripts/export_codex_home.py`

## Last Checked

- 2026-03-16
