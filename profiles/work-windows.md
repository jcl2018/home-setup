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

## Setup (copy-paste)

```bash
# 1. Clone
git clone https://github.com/jcl2018/home-setup.git

# 2. Create persistence dirs (cross-session memory for design docs, analytics)
mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions

# 3. Copy all skills to Codex skills directory
cp -r home-setup/skills/* ~/.codex/skills/

# 4. Copy custom skill
cp -r home-setup/.agents/skills/skill-status ~/.codex/skills/

# 5. Put shell scripts on PATH (add to your shell profile to persist)
export PATH="$HOME/.codex/skills/bin:$PATH"

# 6. Verify — type /skill-status in Codex to confirm everything loaded
```

All 20 skills work after this. No gstack, no bun, no upstream repo access needed.
