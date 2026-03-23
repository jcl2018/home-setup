# Profile: work-windows

## Environment
- OS: Windows
- Hosts: Codex only (no Claude Code)
- Network: restricted (GitHub HTTPS read-only, no upstream git clones)
- gstack: not installed (banned software policy)
- Browse daemon: not available

## Available Skills

**16 of 28 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (5):** careful, freeze, guard, home-retro, unfreeze
- **Adaptable (11):** codex, cso, design-consultation, document-release, investigate, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, setup-deploy

Adaptable skills work because their gstack preamble fails harmlessly — the AI agent skips it and proceeds to the core skill logic.

## Not Available

- **Needs-gstack (5):** autoplan, gstack-upgrade, land-and-deploy, review, ship
- **Needs-browse (7):** benchmark, browse, canary, design-review, qa, qa-only, setup-browser-cookies

These require gstack infrastructure or the browse daemon, which cannot be installed under the current software policy.

## How to Use

Read the catalog on GitHub. For each standalone or adaptable skill you want, find its SKILL.md in the upstream gstack repo or live install on another machine, and copy it to your local Codex skills directory. The skill logic works without gstack.
