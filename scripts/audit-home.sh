#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET_HOME="$HOME"

usage() {
  cat <<'EOF'
Usage: ./scripts/audit-home.sh [--target-home PATH]

Read-only audit of a home folder against the reference model in this repo.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
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

if [ ! -d "$TARGET_HOME" ]; then
  echo "Target home does not exist: $TARGET_HOME" >&2
  exit 1
fi

present_count=0
missing_count=0

bump_count() {
  case "$1" in
    present) present_count=$((present_count + 1)) ;;
    missing) missing_count=$((missing_count + 1)) ;;
  esac
}

print_status() {
  status="$1"
  rel_path="$2"
  note="$3"
  bump_count "$status"
  printf '[%s]  %-58s %s\n' "$status" "$rel_path" "$note"
}

check_path() {
  rel_path="$1"
  note="$2"
  full_path="$TARGET_HOME/$rel_path"
  if [ -e "$full_path" ]; then
    print_status present "$rel_path" "$note"
  else
    print_status missing "$rel_path" "$note"
  fi
}

check_glob() {
  rel_glob="$1"
  note="$2"
  set -- "$TARGET_HOME"/$rel_glob
  if [ -e "$1" ]; then
    print_status present "$rel_glob" "$note"
  else
    print_status missing "$rel_glob" "$note"
  fi
}

echo "Home setup audit"
printf 'Target home: %s\n' "$TARGET_HOME"

echo
echo "Repo-managed reference items"
check_path "AGENTS.md" "global home contract"
check_path ".gitconfig" "minimal shared git defaults"
check_path ".zprofile" "Homebrew shellenv and local secrets hook"
check_path ".codex/config.toml" "Codex runtime defaults"
check_path ".codex/home_setup_summary.md" "home setup summary"
check_path ".codex/knowledge/work-start-checklist.md" "lightweight work-start checklist"
check_path ".codex/knowledge/global/INDEX.md" "global knowledge index"
check_path ".codex/knowledge/global/common-gotchas.md" "global gotchas template"
check_path ".codex/knowledge/global/glossary.md" "global glossary template"
check_path ".codex/knowledge/global/shared-services.md" "shared services template"
check_path ".codex/knowledge/global/system-map.md" "system map template"

for skill_dir in "$ROOT"/templates/.codex/skills/*; do
  skill_name=$(basename "$skill_dir")
  check_path ".codex/skills/$skill_name/SKILL.md" "custom shared skill"
done

check_path ".codex/automations/weekly-codex-health/automation.toml" "optional weekly Codex health automation"

echo
echo "Environment-provided and not managed by this repo"
check_path ".codex/skills/.system/openai-docs/SKILL.md" "visible bundled skill when provided by Codex"
check_path ".codex/skills/.system/skill-creator/SKILL.md" "visible bundled skill when provided by Codex"
check_path ".codex/skills/.system/skill-installer/SKILL.md" "visible bundled skill when provided by Codex"

echo
echo "Local-only and intentionally not managed by this repo"
check_path ".config/home-setup/secrets.zsh" "machine-local secrets and env overrides"
check_path ".codex/auth.json" "local Codex sign-in state"
check_glob ".codex/logs_*.sqlite*" "local Codex log database"
check_glob ".codex/state_*.sqlite*" "local Codex state database"
check_path ".codex/models_cache.json" "local Codex model cache"
check_path ".codex/sessions" "local Codex session history"
check_path ".codex/shell_snapshots" "local Codex shell snapshots"

echo
printf 'Summary: %s present, %s missing\n' "$present_count" "$missing_count"
echo "Missing repo-managed items are adoption candidates."
echo "Missing local-only items are usually fine until that machine needs them."
