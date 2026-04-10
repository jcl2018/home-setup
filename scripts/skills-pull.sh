#!/usr/bin/env bash
set -euo pipefail
# skills-pull.sh — One-command submodule update to prevent drift (P6)
# Pulls latest from claude-skills-templates, commits the pointer bump.
# Post-commit hook will auto-deploy.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

git submodule update --remote upstreams/claude-skills-templates

if git diff --quiet HEAD upstreams/claude-skills-templates; then
  echo "Already up to date."
  exit 0
fi

git add upstreams/claude-skills-templates
git commit -m "chore: bump claude-skills-templates submodule"
echo "Submodule bumped. Post-commit hook will auto-deploy."
