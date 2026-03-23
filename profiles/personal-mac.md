# Profile: personal-mac

## Environment
- OS: macOS
- Hosts: Claude Code, Codex
- Network: unrestricted
- gstack: installed (git clone, auto-upgrade enabled)
- Browse daemon: available

## Reference Machine

This is the reference machine. All skills in the catalog are available here, plus additional gstack-only skills that are not tracked in the catalog.

## Available Skills

**All 21 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (6):** careful, freeze, guard, self-audit, skill-status, unfreeze
- **Adaptable (15):** autoplan, codex, cso, design-consultation, document-release, investigate, land-and-deploy, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, review, setup-deploy, ship

## Additional gstack-only Skills

The following 8 skills are available via the live gstack install but are **not tracked** in the catalog (they require UI/browse infrastructure or are gstack-internal):

benchmark, browse, canary, design-review, gstack-upgrade, qa, qa-only, setup-browser-cookies

## Maintenance

After upstream upgrades (currently gstack), run `/skill-status` to check version alignment. If mismatched, re-copy portable SKILL.md files and `skills/bin/` scripts, bump the version in `skills-catalog.json` under `upstreams`, and commit.
