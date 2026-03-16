# Work Start Checklist

Use this as a light reminder when beginning substantial work.

## Goal

Stay aligned with the home setup logic without running a heavy audit every time.

## Start-of-work flow

1. Identify the current workspace or repo root.
2. Read the nearest `AGENTS.md`.
3. Read the active tracking doc for the scope:
   - home-control work: `~/.codex/.local-work/current.md`
   - repo work: `<repo>/.local-work/current.md`
4. Scan the repo shape: `README`, build files, tests, and top-level directories.
5. Decide whether a skill should be used.
6. Find the lightest real verification command before editing.
7. Give a short context snapshot before doing substantial work.

## Context sources to mention

When starting work, mention whichever of these are actually in play:

- home rule file: `~/AGENTS.md`
- repo rule file: nearest repo `AGENTS.md`
- active tracking doc: `~/.codex/.local-work/current.md` or `<repo>/.local-work/current.md`
- triggered skill: any skill used for the task
- knowledge note: any `~/.codex/knowledge/...` file or repo-local knowledge doc actually consulted
- supporting docs: specific docs or references consulted
- verification path: the command or check expected to validate the work

## Example context snapshot

Use a short format like:

- Context in play: `~/AGENTS.md`, `<repo>/AGENTS.md`, `<repo>/.local-work/current.md`, `$lv1-workflow-project-contract`, and `README.md`
- Verification plan: `<command>`

If no skill or saved knowledge is used, keep that explicit:

- Context in play: `~/AGENTS.md`, `<repo>/AGENTS.md`, `<repo>/.local-work/current.md`, `README.md`
- Verification plan: `pending inspection`

## Example call flow

For substantial repo work without saved knowledge:

1. Read `~/AGENTS.md` if the home layer is relevant.
2. Read the nearest repo `AGENTS.md`.
3. Read `<repo>/.local-work/current.md`.
4. Give the short context snapshot.
5. Decide whether a skill or saved knowledge note is actually needed.

For substantial repo work that should reuse saved global knowledge such as `bar`:

1. Read `~/AGENTS.md`.
2. Read the nearest repo `AGENTS.md`.
3. Read `<repo>/.local-work/current.md`.
4. Give the short context snapshot with the current verification plan.
5. Trigger `$lv0-home-shared-context`.
6. Read the smallest matching note under `~/.codex/knowledge/`.
7. Continue repo exploration, preferring repo truth if it disagrees with the cached global note.
8. Refresh `<repo>/.local-work/current.md` after material changes and before pausing or handoff.

For home-control work:

1. Read `~/AGENTS.md`.
2. Read `~/.codex/.local-work/current.md`.
3. Give the short context snapshot.
4. Read deeper home notes or skills only when the task actually needs them.

## When to do a deeper audit

Run a deeper `lv0-home-codex-health` style review when:

- `~/AGENTS.md` changes
- home skills are added, removed, or substantially rewritten
- the home setup structure changes
- sessions start feeling noisy, repetitive, or inconsistent

## What this is not

This is not a full audit for every code change. It is a lightweight reminder and context-disclosure habit.
