# Work Start Checklist

Use this as a light reminder when beginning substantial work.

## Goal

Stay aligned with the home setup logic without running a heavy audit every time.

## Start-of-work flow

1. Identify the current workspace or repo root.
2. Read the nearest `AGENTS.md`.
3. Scan the repo shape: `README`, build files, tests, and top-level directories.
4. Decide whether a skill should be used.
5. Find the lightest real verification command before editing.
6. Briefly state the active context sources before doing substantial work.

## Context sources to mention

When starting work, mention whichever of these are actually in play:

- home rule file: `~/AGENTS.md`
- repo rule file: nearest repo `AGENTS.md`
- triggered skill: any skill used for the task
- knowledge note: any `~/.codex/knowledge/...` file or repo-local knowledge doc actually consulted
- supporting docs: specific docs or references consulted
- verification path: the command or check expected to validate the work

## Example context snapshot

Use a short format like:

- Context in play: `~/AGENTS.md`, `<repo>/AGENTS.md`, `$lv1-workflow-project-contract`, and `README.md`
- Verification plan: `<command>`

## When to do a deeper audit

Run a deeper `lv0-home-codex-health` style review when:

- `~/AGENTS.md` changes
- home skills are added, removed, or substantially rewritten
- the home setup structure changes
- sessions start feeling noisy, repetitive, or inconsistent

## What this is not

This is not a full audit for every code change. It is a lightweight reminder and context-disclosure habit.
