#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="${HOME_SETUP_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CLAUDE_HOME="${HOME_SETUP_CLAUDE_HOME:-$HOME/.claude}"
CODEX_HOME="${HOME_SETUP_CODEX_HOME:-$HOME/.codex}"
CODEX_AGENTS="${HOME_SETUP_CODEX_AGENTS:-$HOME/AGENTS.md}"

HOST="all"
SCOPE="all"
FORMAT="text"
STATUS_ITEMS_FILE=""

usage() {
    cat <<'EOF'
Usage: ./sync.sh {push|pull|status} [--host claude|codex|all] [--scope repo-owned|backup-only|all] [--format text|json]

Commands:
  push    Deploy repo-owned Claude/Codex config to this machine
  pull    Backup live Claude/Codex config into this repo
  status  Show drift between repo and live Claude/Codex homes

Options:
  --host    Limit work to one host (default: all)
  --scope   Limit work to repo-owned or backup-only surfaces (default: all)
  --format  status only: text or json (default: text)
EOF
    exit 1
}

require_value() {
    local flag="$1"
    local value="${2:-}"
    if [ -z "$value" ]; then
        echo "Missing value for $flag" >&2
        usage
    fi
}

parse_args() {
    COMMAND="${1:-}"
    case "$COMMAND" in
        push|pull|status) shift ;;
        *) usage ;;
    esac

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --host)
                require_value "$1" "${2:-}"
                HOST="$2"
                shift 2
                ;;
            --scope)
                require_value "$1" "${2:-}"
                SCOPE="$2"
                shift 2
                ;;
            --format)
                require_value "$1" "${2:-}"
                FORMAT="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                ;;
        esac
    done

    case "$HOST" in
        claude|codex|all) ;;
        *)
            echo "Invalid host: $HOST" >&2
            usage
            ;;
    esac

    case "$SCOPE" in
        repo-owned|backup-only|all) ;;
        *)
            echo "Invalid scope: $SCOPE" >&2
            usage
            ;;
    esac

    case "$FORMAT" in
        text|json) ;;
        *)
            echo "Invalid format: $FORMAT" >&2
            usage
            ;;
    esac

    if [ "$COMMAND" != "status" ] && [ "$FORMAT" != "text" ]; then
        echo "--format is only supported for status" >&2
        usage
    fi
}

host_selected() {
    local target="$1"
    [ "$HOST" = "all" ] || [ "$HOST" = "$target" ]
}

scope_selected() {
    local target="$1"
    [ "$SCOPE" = "all" ] || [ "$SCOPE" = "$target" ]
}

should_process() {
    local target_host="$1"
    local target_scope="$2"
    host_selected "$target_host" && scope_selected "$target_scope"
}

redact_secrets() {
    python3 -c "
import json, sys
d = json.load(sys.stdin)
def redact(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if any(s in k.lower() for s in ['key', 'token', 'secret', 'password']):
                if isinstance(v, str) and len(v) > 8:
                    obj[k] = v[:4] + '...<REDACTED>'
            else:
                redact(v)
    elif isinstance(obj, list):
        for v in obj:
            redact(v)
redact(d)
json.dump(d, sys.stdout, indent=2)
"
}

record_status_item() {
    local id="$1"
    local label="$2"
    local item_host="$3"
    local item_scope="$4"
    local kind="$5"
    local status="$6"
    local repo_path="$7"
    local live_path="$8"
    local recommended_action="$9"
    local repo_version="${10:-}"
    local live_version="${11:-}"
    local backup_age_days="${12:-}"

    if [ "$FORMAT" != "json" ]; then
        return 0
    fi

    local backup_age_json="null"
    if [ -n "$backup_age_days" ]; then
        backup_age_json="$backup_age_days"
    fi

    jq -nc \
        --arg id "$id" \
        --arg label "$label" \
        --arg host "$item_host" \
        --arg scope "$item_scope" \
        --arg kind "$kind" \
        --arg status "$status" \
        --arg repo_path "$repo_path" \
        --arg live_path "$live_path" \
        --arg recommended_action "$recommended_action" \
        --arg repo_version "$repo_version" \
        --arg live_version "$live_version" \
        --argjson backup_age_days "$backup_age_json" \
        '{
            id: $id,
            label: $label,
            host: $host,
            scope: $scope,
            kind: $kind,
            status: $status,
            recommended_action: $recommended_action,
            repo_path: $repo_path,
            live_path: $live_path,
            repo_version: (if $repo_version == "" then null else $repo_version end),
            live_version: (if $live_version == "" then null else $live_version end),
            backup_age_days: $backup_age_days
        }' >> "$STATUS_ITEMS_FILE"
}

print_status_item() {
    local label="$1"
    local status="$2"
    local detail="${3:-}"

    if [ "$FORMAT" = "json" ]; then
        return 0
    fi

    echo "$label: $status"
    if [ -n "$detail" ]; then
        echo "$detail"
    fi
}

compare_paths_status() {
    local item_scope="$1"
    local repo_exists="$2"
    local live_exists="$3"
    local equal="$4"

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "yes" ]; then
        if [ "$equal" = "yes" ]; then
            echo "in_sync"
        elif [ "$item_scope" = "repo-owned" ]; then
            echo "needs_push"
        else
            echo "needs_pull"
        fi
        return
    fi

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "no" ]; then
        echo "live_missing"
        return
    fi

    if [ "$repo_exists" = "no" ] && [ "$live_exists" = "yes" ]; then
        echo "repo_missing"
        return
    fi

    echo "missing"
}

recommended_action_for_status() {
    local item_scope="$1"
    local status="$2"

    case "$status" in
        needs_push) echo "push" ;;
        needs_pull) echo "pull" ;;
        live_missing)
            if [ "$item_scope" = "repo-owned" ]; then
                echo "push"
            else
                echo "none"
            fi
            ;;
        repo_missing)
            if [ "$item_scope" = "backup-only" ]; then
                echo "pull"
            else
                echo "none"
            fi
            ;;
        *) echo "none" ;;
    esac
}

status_text_file() {
    local id="$1"
    local label="$2"
    local item_host="$3"
    local item_scope="$4"
    local repo_file="$5"
    local live_file="$6"

    local repo_exists="no"
    local live_exists="no"
    local equal="no"

    [ -f "$repo_file" ] && repo_exists="yes"
    [ -f "$live_file" ] && live_exists="yes"

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "yes" ] && cmp -s "$repo_file" "$live_file"; then
        equal="yes"
    fi

    local status
    status=$(compare_paths_status "$item_scope" "$repo_exists" "$live_exists" "$equal")
    local action
    action=$(recommended_action_for_status "$item_scope" "$status")

    print_status_item "$label" "$status"
    record_status_item "$id" "$label" "$item_host" "$item_scope" "text" "$status" "$repo_file" "$live_file" "$action"
}

status_json_file() {
    local id="$1"
    local label="$2"
    local item_host="$3"
    local item_scope="$4"
    local repo_file="$5"
    local live_file="$6"

    local repo_exists="no"
    local live_exists="no"
    local equal="no"

    [ -f "$repo_file" ] && repo_exists="yes"
    [ -f "$live_file" ] && live_exists="yes"

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "yes" ]; then
        local diff_output
        diff_output=$(diff <(cat "$repo_file" | python3 -m json.tool 2>/dev/null || cat "$repo_file") \
                          <(cat "$live_file" | redact_secrets | python3 -m json.tool 2>/dev/null || cat "$live_file") 2>/dev/null || true)
        if [ -z "$diff_output" ]; then
            equal="yes"
        fi
    fi

    local status
    status=$(compare_paths_status "$item_scope" "$repo_exists" "$live_exists" "$equal")
    local action
    action=$(recommended_action_for_status "$item_scope" "$status")

    print_status_item "$label" "$status"
    record_status_item "$id" "$label" "$item_host" "$item_scope" "json" "$status" "$repo_file" "$live_file" "$action"
}

status_directory() {
    local id="$1"
    local label="$2"
    local item_host="$3"
    local item_scope="$4"
    local repo_dir="$5"
    local live_dir="$6"

    local repo_exists="no"
    local live_exists="no"
    local equal="no"

    [ -d "$repo_dir" ] && repo_exists="yes"
    [ -d "$live_dir" ] && live_exists="yes"

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "yes" ]; then
        local diff_output
        diff_output=$(diff -rq "$repo_dir" "$live_dir" 2>/dev/null || true)
        if [ -z "$diff_output" ]; then
            equal="yes"
        fi
    fi

    local status
    status=$(compare_paths_status "$item_scope" "$repo_exists" "$live_exists" "$equal")
    local action
    action=$(recommended_action_for_status "$item_scope" "$status")

    if [ "$FORMAT" = "text" ] && [ "$status" = "needs_push" ]; then
        local diff_summary
        diff_summary=$(diff -rq "$repo_dir" "$live_dir" 2>/dev/null | head -5 || true)
        print_status_item "$label" "$status" "$diff_summary"
    else
        print_status_item "$label" "$status"
    fi

    record_status_item "$id" "$label" "$item_host" "$item_scope" "directory" "$status" "$repo_dir" "$live_dir" "$action"
}

status_memory() {
    local id="$1"
    local label="$2"
    local item_host="$3"
    local item_scope="$4"
    local repo_dir="$5"
    local live_dir="$6"

    local repo_exists="no"
    local live_exists="no"
    local missing_files=0

    [ -d "$repo_dir" ] && repo_exists="yes"
    [ -d "$live_dir" ] && live_exists="yes"

    local status="missing"
    if [ "$live_exists" = "yes" ]; then
        while IFS= read -r -d '' memfile; do
            local rel
            rel="${memfile#$live_dir/}"
            if [ ! -f "$repo_dir/$rel" ]; then
                missing_files=$((missing_files + 1))
            fi
        done < <(find "$live_dir" -path "*/memory/*.md" -print0 2>/dev/null)

        if [ "$missing_files" -eq 0 ]; then
            if [ "$repo_exists" = "yes" ]; then
                status="in_sync"
            else
                status="repo_missing"
            fi
        else
            status="needs_pull"
        fi
    elif [ "$repo_exists" = "yes" ]; then
        status="live_missing"
    fi

    local action
    action=$(recommended_action_for_status "$item_scope" "$status")

    if [ "$FORMAT" = "text" ] && [ "$status" = "needs_pull" ]; then
        print_status_item "$label" "$status" "  [info] $missing_files new file(s) not backed up"
    else
        print_status_item "$label" "$status"
    fi

    record_status_item "$id" "$label" "$item_host" "$item_scope" "memory" "$status" "$repo_dir" "$live_dir" "$action"
}

status_gstack() {
    local item_host="$1"
    local repo_dir="$2"
    local live_dir="$3"
    local git_path="$4"

    local repo_version=""
    local live_version=""
    local repo_exists="no"
    local live_exists="no"
    local equal="no"
    local backup_age_days=""

    if [ -f "$repo_dir/VERSION" ]; then
        repo_exists="yes"
        repo_version=$(cat "$repo_dir/VERSION" 2>/dev/null | tr -d '[:space:]')
    fi
    if [ -f "$live_dir/VERSION" ]; then
        live_exists="yes"
        live_version=$(cat "$live_dir/VERSION" 2>/dev/null | tr -d '[:space:]')
    fi

    if [ "$repo_exists" = "yes" ] && [ "$live_exists" = "yes" ] && [ "$repo_version" = "$live_version" ]; then
        equal="yes"
    fi

    local status
    status=$(compare_paths_status "backup-only" "$repo_exists" "$live_exists" "$equal")
    local action
    action=$(recommended_action_for_status "backup-only" "$status")

    local last_pull
    last_pull=$(git -C "$SCRIPT_DIR" log -1 --format="%at" -- "$git_path/VERSION" 2>/dev/null || true)
    last_pull="${last_pull:-0}"
    if [[ "$last_pull" =~ ^[0-9]+$ ]] && [ "$last_pull" -gt 0 ]; then
        local now
        now=$(date +%s)
        backup_age_days=$(( (now - last_pull) / 86400 ))
    fi

    if [ "$FORMAT" = "text" ]; then
        if [ "$status" = "in_sync" ] && [ -n "$live_version" ]; then
            echo "gstack: v$live_version (in sync)"
        elif [ "$status" = "needs_pull" ] && [ -n "$repo_version" ] && [ -n "$live_version" ]; then
            echo "gstack: repo=v$repo_version, live=v$live_version (needs pull)"
        elif [ "$status" = "repo_missing" ] && [ -n "$live_version" ]; then
            echo "gstack: repo missing, live=v$live_version"
        elif [ "$status" = "live_missing" ] && [ -n "$repo_version" ]; then
            echo "gstack: repo=v$repo_version, live missing"
        else
            echo "gstack: $status"
        fi

        if [ -n "$backup_age_days" ] && [ "$backup_age_days" -gt 7 ]; then
            echo "  [warn] backup is ${backup_age_days} days old"
        fi
    fi

    record_status_item "gstack" "gstack" "$item_host" "backup-only" "snapshot" "$status" "$repo_dir" "$live_dir" "$action" "$repo_version" "$live_version" "$backup_age_days"
}

render_status_json() {
    jq -s \
        --arg host "$HOST" \
        --arg scope "$SCOPE" \
        --arg format "$FORMAT" \
        '{host: $host, scope: $scope, format: $format, items: .}' \
        "$STATUS_ITEMS_FILE"
}

print_header() {
    local title="$1"
    if [ "$FORMAT" = "text" ]; then
        echo "=== $title ==="
    fi
}

sync_claude_templates_to_live() {
    if [ -d "$SCRIPT_DIR/claude/templates" ]; then
        mkdir -p "$CLAUDE_HOME/templates"
        rsync -av --checksum --delete "$SCRIPT_DIR/claude/templates/" "$CLAUDE_HOME/templates/" 2>&1 | grep -v '^$' || true
        echo "  [sync] templates"
    else
        echo "  [skip] claude/templates missing in repo"
    fi
}

sync_claude_templates_to_repo() {
    if [ -d "$CLAUDE_HOME/templates" ]; then
        mkdir -p "$SCRIPT_DIR/claude/templates"
        rsync -av --checksum --delete "$CLAUDE_HOME/templates/" "$SCRIPT_DIR/claude/templates/" 2>&1 | grep -v '^$' || true
        echo "  [pull] templates"
    else
        echo "  [skip] templates missing"
    fi
}

sync_codex_repo_owned_to_live() {
    if [ -f "$SCRIPT_DIR/codex/config.toml" ]; then
        mkdir -p "$CODEX_HOME"
        cp "$SCRIPT_DIR/codex/config.toml" "$CODEX_HOME/config.toml"
        echo "  [sync] config.toml"
    else
        echo "  [skip] codex/config.toml missing in repo"
    fi

    if [ -f "$SCRIPT_DIR/codex/AGENTS.md" ]; then
        mkdir -p "$(dirname "$CODEX_AGENTS")"
        cp "$SCRIPT_DIR/codex/AGENTS.md" "$CODEX_AGENTS"
        echo "  [sync] AGENTS.md"
    else
        echo "  [skip] codex/AGENTS.md missing in repo"
    fi
}

sync_codex_repo_owned_to_repo() {
    mkdir -p "$SCRIPT_DIR/codex"

    if [ -f "$CODEX_HOME/config.toml" ]; then
        cp "$CODEX_HOME/config.toml" "$SCRIPT_DIR/codex/config.toml"
        echo "  [pull] config.toml"
    else
        echo "  [skip] config.toml missing"
    fi

    if [ -f "$CODEX_AGENTS" ]; then
        cp "$CODEX_AGENTS" "$SCRIPT_DIR/codex/AGENTS.md"
        echo "  [pull] AGENTS.md"
    else
        echo "  [skip] AGENTS.md missing"
    fi
}

sync_claude_backup_to_repo() {
    mkdir -p \
        "$SCRIPT_DIR/claude/skills/gstack" \
        "$SCRIPT_DIR/claude/projects"

    if [ -f "$CLAUDE_HOME/settings.json" ]; then
        cat "$CLAUDE_HOME/settings.json" | redact_secrets > "$SCRIPT_DIR/claude/settings.json"
        echo "  [pull] settings.json (redacted)"
    else
        echo "  [skip] settings.json missing"
    fi

    if [ -d "$CLAUDE_HOME/skills/gstack" ]; then
        rsync -av --checksum --delete \
            --exclude='.git' --exclude='node_modules' --exclude='dist' \
            --exclude='.deploy' --exclude='*.sqlite*' --exclude='__pycache__' \
            "$CLAUDE_HOME/skills/gstack/" "$SCRIPT_DIR/claude/skills/gstack/" 2>&1 | tail -3 || true
        echo "  [pull] gstack (v$(cat "$CLAUDE_HOME/skills/gstack/VERSION" 2>/dev/null || echo '?'))"
    else
        echo "  [skip] gstack missing"
    fi

    if [ -d "$CLAUDE_HOME/projects" ]; then
        rsync -av --checksum \
            --include='*/memory/**' --include='*/' --exclude='*' \
            "$CLAUDE_HOME/projects/" "$SCRIPT_DIR/claude/projects/" 2>&1 | tail -3 || true
        echo "  [pull] project memory"
    else
        echo "  [skip] project memory missing"
    fi
}

sync_codex_backup_to_repo() {
    mkdir -p "$SCRIPT_DIR/codex/skills/gstack"

    if [ -d "$CODEX_HOME/skills/gstack" ]; then
        rsync -av --checksum --delete \
            --exclude='.git' --exclude='node_modules' --exclude='dist' \
            --exclude='.deploy' --exclude='*.sqlite*' --exclude='__pycache__' \
            "$CODEX_HOME/skills/gstack/" "$SCRIPT_DIR/codex/skills/gstack/" 2>&1 | tail -3 || true
        echo "  [pull] gstack (v$(cat "$CODEX_HOME/skills/gstack/VERSION" 2>/dev/null || echo '?'))"
    else
        echo "  [skip] gstack missing"
    fi
}

do_push() {
    print_header "Pushing curated configs"

    if should_process "claude" "repo-owned"; then
        echo ""
        echo "Claude"
        if [ -d "$CLAUDE_HOME" ] || mkdir -p "$CLAUDE_HOME"; then
            sync_claude_templates_to_live
        else
            echo "  [skip] $CLAUDE_HOME not found"
        fi
    fi

    if should_process "codex" "repo-owned"; then
        echo ""
        echo "Codex"
        if [ -d "$CODEX_HOME" ] || mkdir -p "$CODEX_HOME"; then
            sync_codex_repo_owned_to_live
        else
            echo "  [skip] $CODEX_HOME not found"
        fi
    fi

    if [ "$FORMAT" = "text" ]; then
        echo ""
        echo "=== Push complete ==="
    fi
}

do_pull() {
    print_header "Pulling live configs into repo"

    if should_process "claude" "repo-owned"; then
        echo ""
        echo "Claude"
        sync_claude_templates_to_repo
    fi

    if should_process "claude" "backup-only"; then
        if ! should_process "claude" "repo-owned"; then
            echo ""
            echo "Claude"
        fi
        sync_claude_backup_to_repo
    fi

    if should_process "codex" "repo-owned"; then
        echo ""
        echo "Codex"
        sync_codex_repo_owned_to_repo
    fi

    if should_process "codex" "backup-only"; then
        if ! should_process "codex" "repo-owned"; then
            echo ""
            echo "Codex"
        fi
        sync_codex_backup_to_repo
    fi

    if [ "$FORMAT" = "text" ]; then
        echo ""
        echo "=== Pull complete ==="
    fi
}

status_claude() {
    if [ "$FORMAT" = "text" ]; then
        echo "Claude"
    fi

    if should_process "claude" "backup-only"; then
        status_json_file "settings.json" "settings.json" "claude" "backup-only" "$SCRIPT_DIR/claude/settings.json" "$CLAUDE_HOME/settings.json"
        if [ "$FORMAT" = "text" ]; then
            echo ""
        fi
        status_gstack "claude" "$SCRIPT_DIR/claude/skills/gstack" "$CLAUDE_HOME/skills/gstack" "claude/skills/gstack"
        if [ "$FORMAT" = "text" ]; then
            echo ""
        fi
        status_memory "project-memory" "memory" "claude" "backup-only" "$SCRIPT_DIR/claude/projects" "$CLAUDE_HOME/projects"
    fi

    if should_process "claude" "repo-owned"; then
        if [ "$FORMAT" = "text" ] && should_process "claude" "backup-only"; then
            echo ""
        fi
        status_directory "templates" "templates" "claude" "repo-owned" "$SCRIPT_DIR/claude/templates" "$CLAUDE_HOME/templates"
    fi

    if [ "$FORMAT" = "text" ]; then
        echo ""
    fi
}

status_codex() {
    if [ "$FORMAT" = "text" ]; then
        echo "Codex"
    fi

    if should_process "codex" "repo-owned"; then
        status_text_file "config.toml" "config.toml" "codex" "repo-owned" "$SCRIPT_DIR/codex/config.toml" "$CODEX_HOME/config.toml"
        status_text_file "AGENTS.md" "AGENTS.md" "codex" "repo-owned" "$SCRIPT_DIR/codex/AGENTS.md" "$CODEX_AGENTS"
        if [ "$FORMAT" = "text" ]; then
            echo ""
        fi
    fi

    if should_process "codex" "backup-only"; then
        status_gstack "codex" "$SCRIPT_DIR/codex/skills/gstack" "$CODEX_HOME/skills/gstack" "codex/skills/gstack"
    fi

    if [ "$FORMAT" = "text" ]; then
        echo ""
    fi
}

do_status() {
    if [ "$FORMAT" = "json" ]; then
        STATUS_ITEMS_FILE=$(mktemp)
        trap 'rm -f "$STATUS_ITEMS_FILE"' EXIT
    fi

    print_header "Sync Status"
    if [ "$FORMAT" = "text" ]; then
        echo ""
    fi

    if host_selected "claude"; then
        status_claude
    fi

    if host_selected "codex"; then
        status_codex
    fi

    if [ "$FORMAT" = "json" ]; then
        render_status_json
    fi
}

parse_args "$@"

case "$COMMAND" in
    push)   do_push ;;
    pull)   do_pull ;;
    status) do_status ;;
esac
