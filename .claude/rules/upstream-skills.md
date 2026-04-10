---
paths:
  - "skills/**"
---
# P2: Upstream Skills Are Copies, Not Forks

Do NOT edit files in skills/. These are direct copies from gstack upstream.
If you need to customize a skill, create a wrapper in .claude/skills/ instead.
After an upstream upgrade, re-copy SKILL.md files and shell scripts, bump the
version in skills-catalog.json, and run bash scripts/deploy.sh.

See CLAUDE.md Principles section for the full rationale.
