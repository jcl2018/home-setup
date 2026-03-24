---
name: repo-bootstrap
description: |
  Onboard any repo for reliable Claude Code work. Maps the repo, creates or
  tightens CLAUDE.md via /project-contract, runs a real verification command,
  checks for relevant domain knowledge, and outputs a setup summary.
  Use when asked to "bootstrap this repo", "onboard this repo",
  "set up this repo for Claude Code", or "make this repo CC-ready".
---

# Repo Bootstrap

Onboard any repository for reliable Claude Code work. This skill produces a
working setup — not a plan, not a checklist, but a repo that Claude Code
can work in effectively on the next session.

## When to Use

- First time opening a repo with Claude Code
- Repo feels disorganized or CC keeps asking the same questions
- User asks to "bootstrap", "onboard", or "set up" a repo
- After cloning a new repo

## Workflow

### Step 1: Map the repo

Understand what you're working with before changing anything:

1. **Stack detection** — languages, frameworks, build system, package manager
2. **Entrypoints** — where does the code start? Main files, entry scripts, app roots
3. **Existing AI docs** — check for `CLAUDE.md`, `.claude/`, `docs/ai/`, `AGENTS.md`
4. **Test infrastructure** — test runner, test directory, how to run one test vs all
5. **Build/lint** — how to build, how to lint, CI configuration

```bash
# Quick repo scan
ls -la
cat README.md 2>/dev/null | head -50
ls src/ app/ lib/ 2>/dev/null
cat package.json pyproject.toml Makefile Cargo.toml go.mod 2>/dev/null | head -30
ls .github/workflows/ .gitlab-ci.yml Jenkinsfile 2>/dev/null
ls .claude/ 2>/dev/null
```

Output: "Here's what I found: {stack summary}"

### Step 2: Create or tighten CLAUDE.md

Invoke `/project-contract` to handle the CLAUDE.md:

- If no `CLAUDE.md` exists → create one from the template
- If `CLAUDE.md` exists → audit it against repo reality, suggest improvements
- Wait for user approval before writing

### Step 3: Run verification

Run at least one real command to prove the repo works:

1. **Preferred order:** test → build → lint → type-check
2. Run the first one that exists and succeeds
3. If nothing works, note it honestly — "No working verification command found"
4. Record what was run and what happened

```bash
# Try in order
npm test 2>/dev/null || python -m pytest 2>/dev/null || make test 2>/dev/null || cargo test 2>/dev/null || go test ./... 2>/dev/null || echo "NO_VERIFICATION"
```

### Step 4: Check domain knowledge

Check if `~/.claude/knowledge/` has relevant context for this repo:

```bash
ls ~/.claude/knowledge/INDEX.md 2>/dev/null && echo "KNOWLEDGE_EXISTS" || echo "NO_KNOWLEDGE"
```

If knowledge exists:
1. Read `~/.claude/knowledge/INDEX.md`
2. Check if any domain matches this repo's stack or problem space
3. If a match exists, note it: "Domain knowledge available: {domain}. Use `/domain-context` to load it."

If no knowledge exists, skip silently.

### Step 5: Output summary

Present a concise setup report:

```
## Bootstrap Summary

**Repo:** {name}
**Stack:** {languages, frameworks}
**CLAUDE.md:** {created / updated / already good}
**Verification:** {command run} → {pass / fail / none}
**Domain knowledge:** {available / none}

### What's ready
- {what works}

### What needs attention
- {what's missing or broken}

### Suggested next steps
- {1-2 concrete actions}
```

## Dependencies

- Calls `/project-contract` for CLAUDE.md creation/tightening
- Optionally references `~/.claude/knowledge/` (created by `/domain-context`)

## Rules

- **Run real commands.** Don't guess whether tests pass — run them.
- **Don't over-scaffold.** Create `CLAUDE.md` and that's it. No `.claude/rules/`,
  no docs directories, no extra files unless the user asks.
- **Be honest about gaps.** If the repo has no tests, say so. Don't invent coverage.
- **One session, one setup.** This skill should complete in a single invocation,
  not require follow-up sessions.
- **Don't touch source code.** This skill sets up CC infrastructure, not the repo itself.
