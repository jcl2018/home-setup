# Profile: personal-mac

## Environment
- OS: macOS
- Hosts: Claude Code, Codex
- Network: unrestricted

## Upstreams
- gstack: available (git install, auto-upgrade enabled)

## Custom Skills & Knowledge
- /home-retro: project-local skill wrapping home_health.py for both Claude and Codex
- Templates: python-project.md, terraform-project.md (repo-owned, pushed to ~/.claude/templates/)
- /audit: project-local skill for scanning dual-host workflow surface

## Sync Strategy
- Full sync.sh push/pull/status
- Push deploys repo-owned surfaces (templates, config.toml, AGENTS.md)
- Pull refreshes backup-only surfaces (gstack snapshots, settings.json, project memory)
- Status compares repo vs live state in JSON or text format

## Reference Machine
This IS the reference machine. The inventory file (home-inventory.json) describes this machine's setup directly. All other profiles document their differences relative to this one.
