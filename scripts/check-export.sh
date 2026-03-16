#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

REQUIRED_DOCS="
docs/design-logic.md
docs/setup-catalog.md
docs/adopt-existing-machine.md
docs/local-repo-workflow.md
docs/local-repo-prd.md
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
if rg --hidden -n '/Users/chjiang' AGENTS.md README.md Brewfile docs scripts/install.sh scripts/audit-home.sh templates; then
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

echo "Checking README links..."
for link in docs/design-logic.md docs/setup-catalog.md docs/adopt-existing-machine.md docs/local-repo-workflow.md docs/local-repo-prd.md scripts/audit-home.sh scripts/install.sh scripts/check-export.sh; do
  if ! rg -q "$link" README.md; then
    echo "README.md is missing a link or reference to $link" >&2
    exit 1
  fi
done

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
cleanup() {
  rm -rf "$TMP_HOME" "$TMP_RENDER"
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

echo "Export check passed."
