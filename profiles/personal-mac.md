# Profile: personal-mac

## Identity
- machine_id: personal-mac
- os: macOS
- hosts: Claude Code
- network: unrestricted
- gstack: installed (git clone, auto-upgrade enabled)
- browse_daemon: available

## Paths
- repo_path: ~/home-setup
- skills_install: ~/.claude/skills
- settings_path: ~/.claude/settings.json

## Expected Local Content

Content in `~/.claude/` that is NOT in the repo and is expected to differ.

(None currently — this is the reference machine with no work-specific domains.)

## Settings Override
- override_file: settings/overrides/personal-mac.json

## Reference Machine

This is the reference machine. All skills in the catalog are available here, plus additional gstack-only skills that are not tracked in the catalog.

## Available Skills

**All 24 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (9):** careful, domain-context, freeze, guard, project-contract, repo-bootstrap, skill-status, sync-audit, unfreeze
- **Adaptable (15):** autoplan, codex, cso, design-consultation, document-release, investigate, land-and-deploy, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, review, setup-deploy, ship

## Additional gstack-only Skills

The following 8 skills are available via the live gstack install but are **not tracked** in the catalog (they require UI/browse infrastructure or are gstack-internal):

benchmark, browse, canary, design-review, gstack-upgrade, qa, qa-only, setup-browser-cookies

## Maintenance

After upstream upgrades (currently gstack), run `/skill-status` to check version alignment. If mismatched, re-copy portable SKILL.md files and `skills/bin/` scripts, bump the version in `skills-catalog.json` under `upstreams`, and commit.
