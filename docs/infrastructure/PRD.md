---
type: prd
feature: infrastructure
title: "Infrastructure — Product Requirements"
version: 1
status: Active
date: 2026-04-09
author: chjiang
---

## Problem Statement

Claude Code sessions load configuration from `~/.claude/`, but that directory has no version control, no audit trail, and no way to reproduce its state. When skills, knowledge files, or settings are edited directly in `~/.claude/`, changes are invisible and irreproducible. A repo owner needs a single source of truth that deploys deterministically to the runtime directory.

## Mental Model

The repo is the authority (P1). `~/.claude/` is a deployment target. A deploy script copies repo content to the runtime directory. A post-commit hook (P11) ensures every commit auto-deploys. Five principles (P1, P2, P3, P5, P11) govern what goes where.

## User Stories

### P0 (Must-Have)

| # | Tag | What it asks | As a... | I want to... | So that... |
|---|-----|-------------|---------|-------------|------------|
| 1 | core | Does deploy.sh copy all deployable files to ~/.claude/? | repo owner | run `bash scripts/deploy.sh` and have skills, knowledge, settings land in ~/.claude/ | my runtime config matches the repo |
| 2 | core | Do principles P1-P11 have enforceable directives? | repo owner | have each principle translate to a Claude directive and a path-scoped rule | principles are enforced by construction, not memory |
| 3 | resilience | Does the post-commit hook auto-deploy? | repo owner | have changes deploy automatically after every commit | committed-but-not-deployed is impossible (P11) |
| 4 | observability | Can I detect repo-vs-home drift? | repo owner | run an audit that diffs repo state against ~/.claude/ | I know immediately when drift exists |

## Acceptance Criteria

### Story #1: Deploy pipeline [core]

```
GIVEN the repo contains skills/, knowledge/, settings/, and .claude/skills/
WHEN  I run bash scripts/deploy.sh
THEN  every file is copied to its ~/.claude/ counterpart and exit code is 0
```

### Story #3: Auto-deploy [resilience]

```
GIVEN the post-commit hook is installed in .claude/hooks/
WHEN  I commit a change to any deployable file
THEN  deploy.sh runs automatically and ~/.claude/ reflects the commit
```

## Out of Scope

- Multi-machine sync (each machine runs its own deploy)
- Remote deployment or CI/CD pipelines
