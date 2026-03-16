#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEMPLATES="$ROOT/templates"
TARGET_HOME="$HOME"
WITH_AUTOMATION=0
INSTALL_BREW=0

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [--brew] [--with-automation] [--target-home PATH]

Options:
  --brew             Install the Brewfile before copying templates.
  --with-automation  Install the exported Codex automation too.
  --target-home      Render and install into a different home path.
  -h, --help         Show this help.

This is an optional clean-machine bootstrap helper.
For an existing home folder, prefer ./scripts/audit-home.sh and docs/adopt-existing-machine.md first.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --brew)
      INSTALL_BREW=1
      shift
      ;;
    --with-automation)
      WITH_AUTOMATION=1
      shift
      ;;
    --target-home)
      if [ "$#" -lt 2 ]; then
        echo "Missing value for --target-home" >&2
        exit 1
      fi
      TARGET_HOME="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ "$INSTALL_BREW" -eq 1 ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required for --brew. Install it from https://brew.sh first." >&2
    exit 1
  fi

  brew bundle --file "$ROOT/Brewfile"
fi

STAGING_DIR=$(mktemp -d "${TMPDIR:-/tmp}/home-setup.XXXXXX")
cleanup() {
  rm -rf "$STAGING_DIR"
}
trap cleanup EXIT INT TERM

rsync -a "$TEMPLATES"/ "$STAGING_DIR"/

if [ "$WITH_AUTOMATION" -ne 1 ]; then
  rm -rf "$STAGING_DIR/.codex/automations"
fi

find "$STAGING_DIR" -type f | while IFS= read -r file; do
  TARGET_HOME_RENDER="$TARGET_HOME" perl -0pi -e 's/__HOME__/$ENV{TARGET_HOME_RENDER}/g' "$file"
done

mkdir -p "$TARGET_HOME" "$TARGET_HOME/.codex" "$TARGET_HOME/.config/home-setup"
rsync -a --backup --suffix=".home-setup.bak" "$STAGING_DIR"/ "$TARGET_HOME"/

if command -v git-lfs >/dev/null 2>&1; then
  git lfs install --skip-repo >/dev/null 2>&1 || true
fi

printf 'Installed home setup into %s\n' "$TARGET_HOME"
printf 'Machine-local secrets live in %s\n' "$TARGET_HOME/.config/home-setup/secrets.zsh"
echo "This bootstrap helper is secondary to the docs-first audit and compare flow."

if [ "$WITH_AUTOMATION" -ne 1 ]; then
  echo "Automations were skipped. Re-run with --with-automation if you want them."
fi
