# Profile: synopsys-windows

## Identity
- machine_id: synopsys-windows
- os: Windows 11 Enterprise (10.0.26100)
- hostname: chjiang's Synopsys work machine
- hosts: Claude Code (VSCode extension)
- network: restricted (Synopsys corp network)
- gstack: not installed
- browse_daemon: not available

## Paths
- repo_path: "C:\Users\chjiang\OneDrive - Synopsys, Inc\Documents\agent-backup\home-setup"
- skills_install: ~/.claude/skills
- knowledge_install: ~/.claude/knowledge
- settings_path: ~/.claude/settings.json

## Expected Local Content

Content in `~/.claude/` that is NOT in the repo and is expected to differ.
The `/sync-audit` skill uses this list to suppress false-positive warnings.

- knowledge/aedt/          # AEDT domain corpus (65MB, work-specific, proprietary)

## Settings Override
- override_file: settings/overrides/synopsys-windows.json

## Available Skills

**All 24 skills** in `skills-catalog.json` are available on this machine:

- **Standalone (9):** careful, domain-context, freeze, guard, project-contract, repo-bootstrap, skill-status, sync-audit, unfreeze
- **Adaptable (15):** autoplan, codex, cso, design-consultation, document-release, investigate, land-and-deploy, office-hours, plan-ceo-review, plan-design-review, plan-eng-review, retro, review, setup-deploy, ship

Adaptable skills work because their gstack preamble fails harmlessly. Skills that depend on shell scripts use bundled scripts from `skills/bin/`.

## Setup (re-install from repo)

```bash
# 1. Copy all skills to Claude Code skills directory
REPO="c:/Users/chjiang/OneDrive - Synopsys, Inc/Documents/agent-backup/home-setup"
cp -r "$REPO/skills/"* ~/.claude/skills/
cp -r "$REPO/.claude/skills/"* ~/.claude/skills/

# 2. Copy shared knowledge files
cp "$REPO/knowledge/"*.md ~/.claude/knowledge/

# 3. Create gstack persistence dirs (used by some skills for analytics)
mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions

# 4. Verify — run /sync-audit to confirm everything is in sync
```

## Notes
- gstack analytics preamble (`mkdir -p ~/.gstack/...`) in skill files fails harmlessly
- `/codex` skill requires the `codex` CLI — skips gracefully if not installed
- bin scripts in `skills/bin/` are available at `~/.claude/skills/bin/`
