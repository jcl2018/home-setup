#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

REQUIRED_DOCS="
docs/design-logic.md
docs/setup-catalog.md
docs/adopt-existing-machine.md
docs/duplicate-to-windows.md
docs/local-repo-workflow.md
docs/local-repo-prd.md
"

REQUIRED_FILES="
config/reference-paths.tsv
scripts/install.ps1
scripts/audit-home.ps1
"

CUSTOM_SKILLS="
lv0-home-codex-health
lv0-home-global-knowledge-capture
lv0-home-shared-context
lv1-workflow-project-contract
lv1-workflow-repo-bootstrap
lv1-workflow-repo-knowledge-capture
lv1-workflow-session-handoff
"

SYSTEM_SKILLS="
openai-docs
skill-creator
skill-installer
"

KNOWLEDGE_NOTES="
.codex/knowledge/work-start-checklist.md
.codex/knowledge/global/INDEX.md
.codex/knowledge/global/common-gotchas.md
.codex/knowledge/global/glossary.md
.codex/knowledge/global/shared-services.md
.codex/knowledge/global/system-map.md
"

echo "Checking for source-machine paths..."
if rg --hidden -n '/Users/chjiang' AGENTS.md README.md Brewfile config docs scripts/install.sh scripts/audit-home.sh scripts/install.ps1 scripts/audit-home.ps1 templates; then
  echo "Found source-machine paths in the export." >&2
  exit 1
fi

echo "Checking for excluded machine-local files..."
if find templates \
  \( -name 'auth.json' \
  -o -name 'models_cache.json' \
  -o -name 'logs_*.sqlite*' \
  -o -name 'state_*.sqlite*' \
  -o -path '*/sessions/*' \
  -o -path '*/shell_snapshots/*' \) | grep -q .; then
  echo "Found excluded machine-local files in templates." >&2
  exit 1
fi

echo "Checking for direct secret exports in templates/.zprofile..."
if rg -n 'export [A-Z0-9_]+=' templates/.zprofile; then
  echo "templates/.zprofile should not contain checked-in secrets." >&2
  exit 1
fi

echo "Checking required docs..."
for doc in $REQUIRED_DOCS; do
  test -f "$doc"
done

echo "Checking required support files..."
for path in $REQUIRED_FILES; do
  test -f "$path"
done

echo "Checking README links..."
for link in docs/design-logic.md docs/setup-catalog.md docs/adopt-existing-machine.md docs/duplicate-to-windows.md docs/local-repo-workflow.md docs/local-repo-prd.md scripts/audit-home.sh scripts/install.sh scripts/audit-home.ps1 scripts/install.ps1 scripts/check-export.sh; do
  if ! rg -q "$link" README.md; then
    echo "README.md is missing a link or reference to $link" >&2
    exit 1
  fi
done

echo "Checking reference inventory..."
if ! rg -q 'config/reference-paths.tsv' docs/design-logic.md; then
  echo "docs/design-logic.md should mention config/reference-paths.tsv" >&2
  exit 1
fi

if ! rg -q 'config/reference-paths.tsv' docs/setup-catalog.md; then
  echo "docs/setup-catalog.md should mention config/reference-paths.tsv" >&2
  exit 1
fi

MANIFEST_TMP=$(mktemp "${TMPDIR:-/tmp}/home-setup-manifest-check.XXXXXX")
awk -F '\t' '
  $0 !~ /^#/ && NF >= 4 {
    print $1 "\t" $2 "\t" $3
  }
' config/reference-paths.tsv > "$MANIFEST_TMP"

while IFS="$(printf '\t')" read -r scope kind rel_path; do
  [ -n "$scope" ] || continue

  case "$scope" in
    shared|unix|automation) ;;
    *)
      echo "Unsupported manifest scope: $scope" >&2
      rm -f "$MANIFEST_TMP"
      exit 1
      ;;
  esac

  case "$kind" in
    file)
      test -f "templates/$rel_path"
      ;;
    dir)
      test -d "templates/$rel_path"
      ;;
    *)
      echo "Unsupported manifest kind: $kind" >&2
      rm -f "$MANIFEST_TMP"
      exit 1
      ;;
  esac
done < "$MANIFEST_TMP"
rm -f "$MANIFEST_TMP"

echo "Checking catalog coverage..."
for skill in $CUSTOM_SKILLS; do
  test -f "templates/.codex/skills/$skill/SKILL.md"
  if ! rg -q "$skill" docs/setup-catalog.md; then
    echo "docs/setup-catalog.md is missing $skill" >&2
    exit 1
  fi
done

for skill in $SYSTEM_SKILLS; do
  if ! rg -q "$skill" docs/setup-catalog.md; then
    echo "docs/setup-catalog.md is missing $skill" >&2
    exit 1
  fi
done

for note in $KNOWLEDGE_NOTES; do
  test -f "templates/$note"
  if ! rg -q "$note" docs/setup-catalog.md; then
    echo "docs/setup-catalog.md is missing $note" >&2
    exit 1
  fi
done

test -f "templates/.codex/automations/weekly-codex-health/automation.toml"
if ! rg -q "weekly-codex-health" docs/setup-catalog.md; then
  echo "docs/setup-catalog.md is missing weekly-codex-health" >&2
  exit 1
fi

TMP_HOME=$(mktemp -d "${TMPDIR:-/tmp}/home-setup-check.XXXXXX")
TMP_RENDER=$(mktemp -d "${TMPDIR:-/tmp}/home-setup-render.XXXXXX")
TMP_WIN_EMPTY=""
TMP_WIN_NO_AUTO=""
TMP_WIN_WITH_AUTO=""
cleanup() {
  rm -rf "$TMP_HOME" "$TMP_RENDER" "${TMP_WIN_EMPTY:-}" "${TMP_WIN_NO_AUTO:-}" "${TMP_WIN_WITH_AUTO:-}"
}
trap cleanup EXIT INT TERM

echo "Running audit against the current home..."
CURRENT_AUDIT=$(./scripts/audit-home.sh)
printf '%s\n' "$CURRENT_AUDIT" | rg -q '\[present\]  AGENTS.md'
printf '%s\n' "$CURRENT_AUDIT" | rg -q '\[present\]  \.codex/config.toml'
printf '%s\n' "$CURRENT_AUDIT" | rg -q '\[present\]  \.codex/skills/lv0-home-codex-health/SKILL.md'
printf '%s\n' "$CURRENT_AUDIT" | rg -q '\[present\]  \.codex/automations/weekly-codex-health/automation.toml'

echo "Running audit against a sparse temp home..."
SPARSE_AUDIT=$(./scripts/audit-home.sh --target-home "$TMP_HOME")
printf '%s\n' "$SPARSE_AUDIT" | rg -q '\[missing\]  AGENTS.md'
printf '%s\n' "$SPARSE_AUDIT" | rg -q '\[missing\]  \.codex/skills/lv0-home-codex-health/SKILL.md'
printf '%s\n' "$SPARSE_AUDIT" | rg -q '\[missing\]  \.config/home-setup/secrets.zsh'

echo "Rendering into a temp home with the optional bootstrap..."
"$ROOT/scripts/install.sh" --target-home "$TMP_RENDER" --with-automation >/dev/null

if rg --hidden -n '__HOME__' "$TMP_RENDER"; then
  echo "Found unresolved __HOME__ placeholders after render." >&2
  exit 1
fi

test -f "$TMP_RENDER/AGENTS.md"
test -f "$TMP_RENDER/.gitconfig"
test -f "$TMP_RENDER/.zprofile"
test -f "$TMP_RENDER/.codex/config.toml"
test -f "$TMP_RENDER/.codex/skills/lv0-home-codex-health/SKILL.md"
test -f "$TMP_RENDER/.codex/automations/weekly-codex-health/automation.toml"
test -f "$TMP_RENDER/.config/home-setup/secrets.zsh.example"

if command -v pwsh >/dev/null 2>&1; then
  TMP_WIN_EMPTY=$(mktemp -d "${TMPDIR:-/tmp}/home-setup-win-empty.XXXXXX")
  TMP_WIN_NO_AUTO=$(mktemp -d "${TMPDIR:-/tmp}/home-setup-win-no-auto.XXXXXX")
  TMP_WIN_WITH_AUTO=$(mktemp -d "${TMPDIR:-/tmp}/home-setup-win-with-auto.XXXXXX")

  echo "Running PowerShell audit against an empty temp home..."
  WIN_EMPTY_AUDIT=$(pwsh -NoLogo -NoProfile -File "$ROOT/scripts/audit-home.ps1" -TargetHome "$TMP_WIN_EMPTY")
  printf '%s\n' "$WIN_EMPTY_AUDIT" | rg -q '\[missing\]  AGENTS.md'
  printf '%s\n' "$WIN_EMPTY_AUDIT" | rg -q '\[missing\]  \.codex/automations/weekly-codex-health/automation.toml'

  echo "Rendering the Windows shared layer without automation..."
  pwsh -NoLogo -NoProfile -File "$ROOT/scripts/install.ps1" -TargetHome "$TMP_WIN_NO_AUTO" >/dev/null
  if rg --hidden -n '__HOME__' "$TMP_WIN_NO_AUTO"; then
    echo "Found unresolved __HOME__ placeholders after Windows render." >&2
    exit 1
  fi

  test -f "$TMP_WIN_NO_AUTO/AGENTS.md"
  test -f "$TMP_WIN_NO_AUTO/.codex/config.toml"
  test -f "$TMP_WIN_NO_AUTO/.codex/skills/lv0-home-codex-health/SKILL.md"
  test -f "$TMP_WIN_NO_AUTO/.codex/knowledge/work-start-checklist.md"
  test ! -e "$TMP_WIN_NO_AUTO/.codex/automations/weekly-codex-health/automation.toml"
  test ! -e "$TMP_WIN_NO_AUTO/.gitconfig"
  test ! -e "$TMP_WIN_NO_AUTO/.zprofile"
  test ! -e "$TMP_WIN_NO_AUTO/.config/home-setup/secrets.zsh.example"

  WIN_NO_AUTO_AUDIT=$(pwsh -NoLogo -NoProfile -File "$ROOT/scripts/audit-home.ps1" -TargetHome "$TMP_WIN_NO_AUTO")
  printf '%s\n' "$WIN_NO_AUTO_AUDIT" | rg -q '\[present\]  AGENTS.md'
  printf '%s\n' "$WIN_NO_AUTO_AUDIT" | rg -q '\[missing\]  \.codex/automations/weekly-codex-health/automation.toml'

  echo "Rendering the Windows shared layer with automation..."
  pwsh -NoLogo -NoProfile -File "$ROOT/scripts/install.ps1" -TargetHome "$TMP_WIN_WITH_AUTO" -WithAutomation >/dev/null
  if rg --hidden -n '__HOME__' "$TMP_WIN_WITH_AUTO"; then
    echo "Found unresolved __HOME__ placeholders after Windows automation render." >&2
    exit 1
  fi

  test -f "$TMP_WIN_WITH_AUTO/.codex/automations/weekly-codex-health/automation.toml"
  test ! -e "$TMP_WIN_WITH_AUTO/.gitconfig"
  test ! -e "$TMP_WIN_WITH_AUTO/.zprofile"
  test ! -e "$TMP_WIN_WITH_AUTO/.config/home-setup/secrets.zsh.example"

  WIN_WITH_AUTO_AUDIT=$(pwsh -NoLogo -NoProfile -File "$ROOT/scripts/audit-home.ps1" -TargetHome "$TMP_WIN_WITH_AUTO")
  printf '%s\n' "$WIN_WITH_AUTO_AUDIT" | rg -q '\[present\]  AGENTS.md'
  printf '%s\n' "$WIN_WITH_AUTO_AUDIT" | rg -q '\[present\]  \.codex/automations/weekly-codex-health/automation.toml'
else
  echo "PowerShell smoke tests skipped: pwsh not available."
fi

echo "Export check passed."
