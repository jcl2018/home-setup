---
name: project-contract
description: |
  Write or tighten a CLAUDE.md for any repo. Inspects the repo, identifies
  missing or bloated sections, generates a contract with build/test commands,
  architecture boundaries, and coding conventions, then validates every
  command actually runs.
  Use when asked to "set up CLAUDE.md", "write project instructions",
  "tighten the contract", or "onboard this repo".
---

# Project Contract

Write or tighten a `CLAUDE.md` for any repository so Claude Code has a reliable
local contract without bloating startup context.

## When to Use

- Setting up a new repo for Claude Code work
- An existing `CLAUDE.md` is missing, bloated, or stale
- Called by `/repo-bootstrap` as a sub-step
- User asks to "write CLAUDE.md" or "set up project instructions"

## Workflow

### Step 1: Inspect the repo

Map the repo shape before writing anything:

1. Find the main languages, build system, and package manager
2. Identify test commands, lint commands, and build commands
3. Read existing `CLAUDE.md` if present
4. Scan for architecture docs, README, CONTRIBUTING, existing conventions
5. Check for `.claude/rules/` — note any path-specific rules already in place
6. Identify the repo's key entrypoints and module boundaries

### Step 2: Decide what belongs in the contract

A good `CLAUDE.md` contains only what should always be in context:

**Must have:**
- Build, test, and lint commands (with exact invocations)
- Key architecture boundaries (what talks to what, what's off-limits)
- Coding conventions that differ from language defaults
- Safety rails (things to never do in this repo)

**Should have (if applicable):**
- How to run a single test vs the full suite
- Environment setup (env vars, prerequisites)
- Deployment notes (if relevant to day-to-day work)

**Should NOT have:**
- Generic advice Claude already knows (how to write Python, what REST means)
- Full API docs (put those in `.claude/rules/` with path filters)
- Long changelogs or history
- Anything that duplicates README content

Read [references/claude-md-template.md](references/claude-md-template.md) for the
standard template structure.

### Step 3: Split detail out instead of bloating

- Use `.claude/rules/` with path filters for module-specific conventions
- Put long reference material in `docs/` or `docs/ai/`
- Keep `CLAUDE.md` under 80 lines when possible — every line costs context

### Step 4: Remove duplication

- Don't restate things obvious from `package.json`, `Makefile`, or `pyproject.toml`
- Don't repeat what `.claude/rules/` already covers
- Keep the contract focused on what changes from repo to repo

### Step 5: Validate

1. Run every build/test/lint command listed in the contract
2. Verify file paths and module names referenced are real
3. If a command fails, fix the contract (not the repo) — the contract should
   describe reality, not aspirations

### Step 6: Present for approval

Show the full `CLAUDE.md` (or diff if updating an existing one) via AskUserQuestion:
- A) Approve and write
- B) Revise — specify what to change
- C) Cancel

## Rules

- Never write aspirational commands — only commands that actually run
- Prefer concrete examples over abstract rules
- If the repo has no tests, say so honestly — don't invent a test command
- Keep the contract short — long contracts get ignored by both humans and AI
- This skill writes `CLAUDE.md` only — it does not create `.claude/rules/` files
  (that's a separate concern the user can address after)
