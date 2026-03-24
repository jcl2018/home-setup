# Work Start Checklist

Use this as a light reminder when beginning substantial work.

## Goal

Stay aligned with the project setup without running a heavy audit every time.

## Start-of-work flow

1. Identify the current workspace or repo root.
2. Read the repo's `CLAUDE.md`.
3. Read the active tracking doc:
   - repo work: `<repo>/.local-work/current.md`, then the selected item doc under `<repo>/.local-work/items/` when work is tracked per item
4. Scan the repo shape: `README`, build files, tests, and top-level directories.
5. Decide whether a skill should be used.
6. Find the lightest real verification command before editing.
7. Give a short context snapshot before doing substantial work.

## Context sources to mention

When starting work, mention whichever of these are in play:

- repo contract: nearest `CLAUDE.md`
- active tracking doc: `<repo>/.local-work/current.md`
- selected repo item doc: `<repo>/.local-work/items/<itemID>_<type>_<YYYY-MM-DD>_<keywords>.md`
- triggered skill: any skill used for the task
- knowledge note: any `~/.claude/knowledge/...` file actually consulted
- supporting docs: specific docs or references consulted
- verification path: the command or check expected to validate the work

## Example context snapshot

- Context in play: `<repo>/CLAUDE.md`, `<repo>/.local-work/current.md`, `<repo>/.local-work/items/D1419775_defect_2026-03-16_domain_port_fix.md`, `README.md`
- Verification plan: `<command>`

## When to do a deeper audit

Run `/sync-audit` when:
- home setup changes
- skills are added, removed, or substantially rewritten
- sessions start feeling noisy, repetitive, or inconsistent

## What this is not

This is not a full audit for every code change. It is a lightweight reminder and context-disclosure habit.
