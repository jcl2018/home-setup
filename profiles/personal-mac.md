# Profile: personal-mac

## Environment
- OS: macOS
- Hosts: Claude Code, Codex
- Network: unrestricted
- gstack: installed (git clone, auto-upgrade enabled)
- Browse daemon: available

## Reference Machine

This is the reference machine. All skills in the catalog are available here.

## Available Skills

**All 28 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (5):** careful, freeze, guard, skill-status, unfreeze
- **Adaptable (11):** codex, cso, design-consultation, document-release, investigate, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, setup-deploy
- **Needs-gstack (5):** autoplan, gstack-upgrade, land-and-deploy, review, ship
- **Needs-browse (7):** benchmark, browse, canary, design-review, qa, qa-only, setup-browser-cookies

## Maintenance

After gstack upgrades, run `/skill-status` to check whether `gstack_version` in the catalog still matches the live install. If not, re-copy the 15 gstack SKILL.md files into `skills/`, bump the version in `skills-catalog.json`, and commit.
