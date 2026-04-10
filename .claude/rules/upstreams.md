---
paths:
  - "upstreams/**"
---
# P6: Version-Pinned Content

Files in upstreams/ are version-pinned content from repos you own.
Unlike P2 (upstream copies you don't author), these repos are yours.
Edit the source repo directly, then pull updates via `bash scripts/skills-pull.sh`.
Do NOT edit files here in home-setup — commit changes in the source repo first.

Current pinned repos:
- upstreams/claude-skills-templates — custom skills + templates
