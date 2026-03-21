#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
CODEX_HOME="$HOME/.codex"
CODEX_AGENTS="$HOME/AGENTS.md"

usage() {
    echo "Usage: $0 {push|pull|status}"
    echo ""
    echo "  push    Deploy repo-owned Claude/Codex config to this machine"
    echo "  pull    Backup live Claude/Codex config into this repo"
    echo "  status  Show drift between repo and live Claude/Codex homes"
    exit 1
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

sync_text_file() {
    local label="$1"
    local repo_file="$2"
    local live_file="$3"

    if [ -f "$repo_file" ] && [ -f "$live_file" ]; then
        if cmp -s "$repo_file" "$live_file"; then
            echo "$label: in sync"
        else
            echo "$label: DIFFERS"
        fi
    elif [ -f "$repo_file" ]; then
        echo "$label: repo-only"
    elif [ -f "$live_file" ]; then
        echo "$label: live-only (run pull)"
    else
        echo "$label: missing"
    fi
}

show_gstack_status() {
    local label="$1"
    local repo_dir="$2"
    local live_dir="$3"
    local git_path="$4"

    local repo_ver
    local live_ver
    local last_pull
    local now
    local days_ago

    repo_ver=$(cat "$repo_dir/VERSION" 2>/dev/null || echo "not backed up")
    live_ver=$(cat "$live_dir/VERSION" 2>/dev/null || echo "not installed")

    if [ "$repo_ver" = "$live_ver" ]; then
        echo "$label: v$live_ver (in sync)"
    else
        echo "$label: repo=v$repo_ver, live=v$live_ver (OUT OF SYNC)"
    fi

    last_pull=$(git -C "$SCRIPT_DIR" log -1 --format="%at" -- "$git_path/VERSION" 2>/dev/null || true)
    last_pull="${last_pull:-0}"
    if [[ "$last_pull" =~ ^[0-9]+$ ]] && [ "$last_pull" -gt 0 ]; then
        now=$(date +%s)
        days_ago=$(( (now - last_pull) / 86400 ))
        if [ "$days_ago" -gt 7 ]; then
            echo "  [warn] backup is ${days_ago} days old"
        fi
    fi
}

do_push() {
    echo "=== Pushing curated configs ==="

    echo ""
    echo "Claude"
    if [ -d "$CLAUDE_HOME" ]; then
        if [ -d "$SCRIPT_DIR/claude/templates" ]; then
            mkdir -p "$CLAUDE_HOME/templates"
            rsync -av --delete "$SCRIPT_DIR/claude/templates/" "$CLAUDE_HOME/templates/" 2>&1 | grep -v '^$'
            echo "  [sync] templates (exact mirror)"
        else
            echo "  [skip] no repo templates"
        fi
        echo "  [skip] gstack snapshot is backup-only"
    else
        echo "  [skip] $CLAUDE_HOME not found"
    fi

    echo ""
    echo "Codex"
    if [ -d "$CODEX_HOME" ]; then
        if [ -f "$SCRIPT_DIR/codex/config.toml" ]; then
            cp "$SCRIPT_DIR/codex/config.toml" "$CODEX_HOME/config.toml"
            echo "  [sync] config.toml"
        else
            echo "  [skip] codex/config.toml missing in repo"
        fi

        if [ -f "$SCRIPT_DIR/codex/AGENTS.md" ]; then
            cp "$SCRIPT_DIR/codex/AGENTS.md" "$CODEX_AGENTS"
            echo "  [sync] AGENTS.md"
        else
            echo "  [skip] codex/AGENTS.md missing in repo"
        fi

        echo "  [skip] gstack snapshot is backup-only"
    else
        echo "  [skip] $CODEX_HOME not found"
    fi

    echo ""
    echo "=== Push complete ==="
}

do_pull() {
    echo "=== Pulling live configs into repo ==="

    mkdir -p \
        "$SCRIPT_DIR/claude/skills/gstack" \
        "$SCRIPT_DIR/claude/projects" \
        "$SCRIPT_DIR/codex/skills/gstack"

    echo ""
    echo "Claude"

    if [ -f "$CLAUDE_HOME/settings.json" ]; then
        cat "$CLAUDE_HOME/settings.json" | redact_secrets > "$SCRIPT_DIR/claude/settings.json"
        echo "  [pull] settings.json (redacted)"
    else
        echo "  [skip] settings.json missing"
    fi

    if [ -f "$CLAUDE_HOME/CLAUDE.md" ]; then
        cp "$CLAUDE_HOME/CLAUDE.md" "$SCRIPT_DIR/claude/CLAUDE.md"
        echo "  [pull] CLAUDE.md"
    else
        echo "  [skip] CLAUDE.md missing"
    fi

    if [ -d "$CLAUDE_HOME/skills/gstack" ]; then
        rsync -av --delete \
            --exclude='.git' --exclude='node_modules' --exclude='dist' \
            --exclude='.deploy' --exclude='*.sqlite*' --exclude='__pycache__' \
            "$CLAUDE_HOME/skills/gstack/" "$SCRIPT_DIR/claude/skills/gstack/" 2>&1 | tail -3
        echo "  [pull] gstack (v$(cat "$CLAUDE_HOME/skills/gstack/VERSION" 2>/dev/null || echo '?'))"
    else
        echo "  [skip] gstack missing"
    fi

    if [ -d "$CLAUDE_HOME/projects" ]; then
        rsync -av \
            --include='*/memory/**' --include='*/' --exclude='*' \
            "$CLAUDE_HOME/projects/" "$SCRIPT_DIR/claude/projects/" 2>&1 | tail -3
        echo "  [pull] project memory"
    else
        echo "  [skip] project memory missing"
    fi

    echo ""
    echo "Codex"

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

    if [ -d "$CODEX_HOME/skills/gstack" ]; then
        rsync -av --delete \
            --exclude='.git' --exclude='node_modules' --exclude='dist' \
            --exclude='.deploy' --exclude='*.sqlite*' --exclude='__pycache__' \
            "$CODEX_HOME/skills/gstack/" "$SCRIPT_DIR/codex/skills/gstack/" 2>&1 | tail -3
        echo "  [pull] gstack (v$(cat "$CODEX_HOME/skills/gstack/VERSION" 2>/dev/null || echo '?'))"
    else
        echo "  [skip] gstack missing"
    fi

    echo ""
    echo "=== Pull complete ==="
}

do_status() {
    echo "=== Sync Status ==="
    echo ""

    echo "Claude"
    if [ -f "$SCRIPT_DIR/claude/settings.json" ] && [ -f "$CLAUDE_HOME/settings.json" ]; then
        diff_output=$(diff <(cat "$SCRIPT_DIR/claude/settings.json" | python3 -m json.tool 2>/dev/null || cat "$SCRIPT_DIR/claude/settings.json") \
                          <(cat "$CLAUDE_HOME/settings.json" | redact_secrets | python3 -m json.tool 2>/dev/null || cat "$CLAUDE_HOME/settings.json") 2>/dev/null || true)
        if [ -z "$diff_output" ]; then
            echo "settings.json: in sync"
        else
            echo "settings.json: DIFFERS"
        fi
    else
        echo "settings.json: missing"
    fi

    sync_text_file "CLAUDE.md" "$SCRIPT_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

    echo ""
    show_gstack_status "gstack" "$SCRIPT_DIR/claude/skills/gstack" "$CLAUDE_HOME/skills/gstack" "claude/skills/gstack"

    echo ""
    if [ -d "$SCRIPT_DIR/claude/templates" ] && [ -d "$CLAUDE_HOME/templates" ]; then
        template_diff=$(diff -rq "$SCRIPT_DIR/claude/templates" "$CLAUDE_HOME/templates" 2>/dev/null || true)
        if [ -z "$template_diff" ]; then
            echo "templates: in sync"
        else
            echo "templates: DIFFERS"
            echo "$template_diff" | head -5
        fi
    elif [ -d "$SCRIPT_DIR/claude/templates" ]; then
        echo "templates: not deployed (run push)"
    else
        echo "templates: none in repo"
    fi

    echo ""
    if [ -d "$CLAUDE_HOME/projects" ]; then
        new_memory=0
        while IFS= read -r -d '' memfile; do
            rel="${memfile#$CLAUDE_HOME/projects/}"
            if [ ! -f "$SCRIPT_DIR/claude/projects/$rel" ]; then
                new_memory=$((new_memory + 1))
            fi
        done < <(find "$CLAUDE_HOME/projects" -path "*/memory/*.md" -print0 2>/dev/null)
        if [ "$new_memory" -eq 0 ]; then
            echo "memory: in sync"
        else
            echo "memory: $new_memory new file(s) not backed up"
        fi
    else
        echo "memory: no ~/.claude/projects/ found"
    fi

    if [ -f "$SCRIPT_DIR/.claude/skills/audit/SKILL.md" ]; then
        echo "audit skill: present"
    else
        echo "audit skill: missing"
    fi

    echo ""
    echo "Codex"
    sync_text_file "config.toml" "$SCRIPT_DIR/codex/config.toml" "$CODEX_HOME/config.toml"
    sync_text_file "AGENTS.md" "$SCRIPT_DIR/codex/AGENTS.md" "$CODEX_AGENTS"

    echo ""
    show_gstack_status "gstack" "$SCRIPT_DIR/codex/skills/gstack" "$CODEX_HOME/skills/gstack" "codex/skills/gstack"

    if [ -f "$SCRIPT_DIR/.agents/skills/audit/SKILL.md" ]; then
        echo "audit skill: present"
    else
        echo "audit skill: missing"
    fi
}

case "${1:-}" in
    push)   do_push ;;
    pull)   do_pull ;;
    status) do_status ;;
    *)      usage ;;
esac
