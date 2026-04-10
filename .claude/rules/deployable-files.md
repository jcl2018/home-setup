---
paths:
  - "settings/**"
---
# P11: Deploy After Changes

Files in settings/ are deployed to ~/.claude/ by scripts/deploy.sh.
After editing these files, run bash scripts/deploy.sh (or commit, which triggers
the post-commit hook automatically).

A committed-but-not-deployed change is a bug.
