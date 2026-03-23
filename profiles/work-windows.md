# Profile: work-windows

## Environment
- OS: Windows
- Hosts: Codex only (no Claude Code)
- Network: restricted (GitHub HTTPS read-only, no upstream git clones)
- gstack: not installed (banned software policy)
- Browse daemon: not available

## Available Skills

**All 20 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (5):** careful, freeze, guard, skill-status, unfreeze
- **Adaptable (15):** autoplan, codex, cso, design-consultation, document-release, investigate, land-and-deploy, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, review, setup-deploy, ship

Adaptable skills work because their gstack preamble fails harmlessly — the AI agent skips it and proceeds to the core skill logic. Skills that depend on shell scripts (autoplan, land-and-deploy, review, ship) use bundled scripts from `skills/bin/`.

## Note

The catalog no longer tracks browse-dependent or gstack-internal skills (benchmark, browse, canary, design-review, gstack-upgrade, qa, qa-only, setup-browser-cookies). These exist in gstack but are not portable and are not shipped here.

## How to Use

Clone this repo (or read it on GitHub). For each skill you want, copy its SKILL.md from the `skills/` directory to your local Codex skills directory. Also copy `skills/bin/` to a location on your PATH. The skill logic works without gstack — no upstream repo access needed.
