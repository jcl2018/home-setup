# Skills Cheatsheet

Quick reference for all available skills. See `docs/operations/skills-reference.md` for full catalog with dependencies.

## Upstream Skills (gstack)

| Skill | What it does |
|-------|-------------|
| `/autoplan` | Auto-review pipeline (CEO + design + eng reviews) |
| `/benchmark` | Performance regression detection |
| `/canary` | Post-deploy canary monitoring |
| `/careful` | Safety guardrails for destructive commands |
| `/checkpoint` | Save and resume working state |
| `/codex` | Codex CLI wrapper (review, challenge, consult) |
| `/connect-chrome` | Launch Chrome controlled by gstack |
| `/cso` | Security audit (OWASP, STRIDE, supply chain) |
| `/design-consultation` | Design system creation |
| `/design-review` | Visual QA, find and fix design issues |
| `/document-release` | Update docs after shipping |
| `/freeze` | Restrict edits to one directory |
| `/gstack-upgrade` | Upgrade gstack to latest version |
| `/guard` | Full safety mode (careful + freeze) |
| `/health` | Code quality dashboard (0-10 score) |
| `/investigate` | Systematic debugging with root cause |
| `/land-and-deploy` | Merge PR, wait for CI, verify production |
| `/learn` | Manage project learnings |
| `/office-hours` | YC-style brainstorming and design docs |
| `/plan-ceo-review` | CEO/founder-mode plan review |
| `/plan-design-review` | Designer's eye plan review |
| `/plan-eng-review` | Eng manager-mode plan review |
| `/qa` | QA test and fix bugs |
| `/qa-only` | QA test, report only (no fixes) |
| `/retro` | Weekly engineering retrospective |
| `/review` | Pre-landing PR review |
| `/setup-browser-cookies` | Import cookies for authenticated QA |
| `/setup-deploy` | Configure deployment settings |
| `/ship` | Ship workflow (test, review, version, PR) |
| `/unfreeze` | Clear freeze boundary |

## Custom Skills (this repo)

| Skill | What it does |
|-------|-------------|
| `/home-inspect` | 5-room mechanical health check (deterministic) |
| `/governance-audit` | Content quality audit (deterministic + AI review) |
| `/project-contract` | Write or tighten a CLAUDE.md for any repo |
| `/repo-bootstrap` | Onboard a repo for Claude Code work |
| `/domain-context` | Load or capture domain knowledge |

## Project Commands

| Command | What it does |
|---------|-------------|
| `/project:audit` | Run both audit engines, save snapshot, show trending |
| `/project:deploy` | Deploy repo to `~/.claude/` |
