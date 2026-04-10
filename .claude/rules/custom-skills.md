---
paths:
  - ".claude/skills/**"
---
# P3: Custom Skills (SUPERSEDED)

Custom skills have moved to the claude-skills-templates repo (P6: version-pinned content).
They are now at upstreams/claude-skills-templates/skills/ in this repo as a git submodule.

To edit a skill: edit in ~/Documents/projects/claude-skills-templates, commit, push,
then run `bash scripts/skills-pull.sh` in home-setup.

When adding a NEW skill to claude-skills-templates:
1. Add the skill in the source repo
2. Pull into home-setup via scripts/skills-pull.sh
3. Add entry in skills-catalog.json with "source": "claude-skills-templates"
4. Add contract in skill-contracts.json
5. Run bash scripts/deploy.sh
