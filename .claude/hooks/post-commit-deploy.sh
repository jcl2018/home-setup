#!/usr/bin/env bash
# post-commit-deploy.sh — Auto-deploys after every commit (P11)
# Non-fatal: errors print a warning but never block the commit.
# Idempotent: safe to run on every commit including --amend and rebase.

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

if [ -f "$REPO_ROOT/scripts/deploy.sh" ]; then
  bash "$REPO_ROOT/scripts/deploy.sh" 2>&1 | sed 's/^/[deploy] /' || {
    echo "[deploy] WARNING: deploy.sh failed. Run manually: bash scripts/deploy.sh" >&2
  }
fi
