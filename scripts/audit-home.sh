#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
MANIFEST="$ROOT/config/reference-paths.tsv"
TARGET_HOME="$HOME"

usage() {
  cat <<'EOF'
Usage: ./scripts/audit-home.sh [--target-home PATH]

Read-only audit of a Unix/mac home folder against the reference model in this repo.
EOF
}

manifest_entries() {
  scope="$1"
  awk -F '\t' -v wanted="$scope" '
    $0 !~ /^#/ && NF >= 4 && $1 == wanted {
      print $2 "\t" $3 "\t" $4
    }
  ' "$MANIFEST"
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

check_manifest_scope() {
  scope="$1"
  manifest_tmp=$(mktemp "${TMPDIR:-/tmp}/home-setup-audit-manifest.XXXXXX")
  manifest_entries "$scope" > "$manifest_tmp"

  while IFS="$(printf '\t')" read -r kind rel_path note; do
    [ -n "$kind" ] || continue

    case "$kind" in
      file)
        check_path "$rel_path" "$note"
        ;;
      dir)
        template_dir="$ROOT/templates/$rel_path"
        if [ ! -d "$template_dir" ]; then
          echo "Missing template directory: $template_dir" >&2
          rm -f "$manifest_tmp"
          exit 1
        fi

        tree_tmp=$(mktemp "${TMPDIR:-/tmp}/home-setup-audit-tree.XXXXXX")
        find "$template_dir" -type f | LC_ALL=C sort > "$tree_tmp"
        while IFS= read -r template_file; do
          rel_file=${template_file#"$ROOT/templates/"}
          check_path "$rel_file" "$note"
        done < "$tree_tmp"
        rm -f "$tree_tmp"
        ;;
      *)
        echo "Unsupported manifest kind: $kind" >&2
        rm -f "$manifest_tmp"
        exit 1
        ;;
    esac
  done < "$manifest_tmp"

  rm -f "$manifest_tmp"
}

echo "Home setup audit"
printf 'Target home: %s\n' "$TARGET_HOME"

echo
echo "Portable shared reference items"
check_manifest_scope shared

echo
echo "Optional automation"
check_manifest_scope automation

echo
echo "Unix/mac reference items"
check_manifest_scope unix

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
echo "Missing shared or Unix/mac reference items are adoption candidates."
echo "Missing local-only items are usually fine until that machine needs them."
