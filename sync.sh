#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="$HOME/.claude"
CODEX_HOME="$HOME/.codex"

usage() {
    echo "Usage: $0 {push|pull|status}"
    echo ""
    echo "  push    Deploy configs from this repo to ~/.claude/ (activate on this machine)"
    echo "  pull    Backup configs from ~/.claude/ to this repo"
    echo "  status  Show diff between repo and ~/.claude/"
    exit 1
}

redact_secrets() {
    # Redact API keys in settings.json
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
        for v in obj: redact(v)
redact(d)
json.dump(d, sys.stdout, indent=2)
"
}

do_push() {
    echo "=== Pushing configs to $CLAUDE_HOME ==="

    # Custom skills → symlink into ~/.claude/skills/
    if [ -d "$SCRIPT_DIR/claude/skills/custom" ]; then
        for skill_dir in "$SCRIPT_DIR/claude/skills/custom"/*/; do
            [ -d "$skill_dir" ] || continue
            skill_name=$(basename "$skill_dir")
            target="$CLAUDE_HOME/skills/$skill_name"
            if [ -L "$target" ]; then
                echo "  [skip] $skill_name (already linked)"
            elif [ -d "$target" ]; then
                echo "  [skip] $skill_name (directory exists, not overwriting)"
            else
                ln -s "$skill_dir" "$target"
                echo "  [link] $skill_name → $target"
            fi
        done
    fi

    # Community skills → symlink
    if [ -d "$SCRIPT_DIR/claude/skills/community" ]; then
        for skill_dir in "$SCRIPT_DIR/claude/skills/community"/*/; do
            [ -d "$skill_dir" ] || continue
            skill_name=$(basename "$skill_dir")
            target="$CLAUDE_HOME/skills/$skill_name"
            if [ -L "$target" ] || [ -d "$target" ]; then
                echo "  [skip] $skill_name (already exists)"
            else
                ln -s "$skill_dir" "$target"
                echo "  [link] $skill_name → $target"
            fi
        done
    fi

    # Templates → copy to ~/.claude/templates/
    if [ -d "$SCRIPT_DIR/claude/templates" ]; then
        mkdir -p "$CLAUDE_HOME/templates"
        rsync -av "$SCRIPT_DIR/claude/templates/" "$CLAUDE_HOME/templates/" 2>&1 | grep -v '^$'
        echo "  [sync] templates"
    fi

    echo ""
    echo "=== Push complete ==="
    echo "Custom skills are symlinked — changes in this repo are live immediately."
}

do_pull() {
    echo "=== Pulling configs from $CLAUDE_HOME ==="

    # Settings (redacted)
    if [ -f "$CLAUDE_HOME/settings.json" ]; then
        cat "$CLAUDE_HOME/settings.json" | redact_secrets > "$SCRIPT_DIR/claude/settings.json"
        echo "  [pull] settings.json (redacted)"
    fi

    # Gstack snapshot
    if [ -d "$CLAUDE_HOME/skills/gstack" ]; then
        rsync -av --delete \
            --exclude='.git' --exclude='node_modules' --exclude='dist' \
            --exclude='.deploy' --exclude='*.sqlite*' --exclude='__pycache__' \
            "$CLAUDE_HOME/skills/gstack/" "$SCRIPT_DIR/claude/skills/gstack/" 2>&1 | tail -3
        echo "  [pull] gstack (v$(cat "$CLAUDE_HOME/skills/gstack/VERSION" 2>/dev/null || echo '?'))"
    fi

    # Project memory (exclude session ephemera)
    if [ -d "$CLAUDE_HOME/projects" ]; then
        rsync -av \
            --include='*/memory/**' --include='*/' --exclude='*' \
            "$CLAUDE_HOME/projects/" "$SCRIPT_DIR/claude/projects/" 2>&1 | tail -3
        echo "  [pull] project memory"
    fi

    echo ""
    echo "=== Pull complete ==="
}

do_status() {
    echo "=== Sync Status ==="
    echo ""

    # Gstack version
    REPO_VER=$(cat "$SCRIPT_DIR/claude/skills/gstack/VERSION" 2>/dev/null || echo "not backed up")
    LIVE_VER=$(cat "$CLAUDE_HOME/skills/gstack/VERSION" 2>/dev/null || echo "not installed")
    if [ "$REPO_VER" = "$LIVE_VER" ]; then
        echo "gstack: v$LIVE_VER (in sync)"
    else
        echo "gstack: repo=v$REPO_VER, live=v$LIVE_VER (OUT OF SYNC)"
    fi

    # Custom skills
    echo ""
    echo "Custom skills in repo:"
    for skill_dir in "$SCRIPT_DIR/claude/skills/custom"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name=$(basename "$skill_dir")
        target="$CLAUDE_HOME/skills/$skill_name"
        if [ -L "$target" ]; then
            echo "  ✓ $skill_name (linked)"
        elif [ -d "$target" ]; then
            echo "  ! $skill_name (exists but not linked)"
        else
            echo "  ✗ $skill_name (not deployed — run push)"
        fi
    done

    # Community skills
    echo ""
    echo "Community skills in repo:"
    found=0
    for skill_dir in "$SCRIPT_DIR/claude/skills/community"/*/; do
        [ -d "$skill_dir" ] || continue
        found=1
        skill_name=$(basename "$skill_dir")
        target="$CLAUDE_HOME/skills/$skill_name"
        if [ -L "$target" ]; then
            echo "  ✓ $skill_name (linked)"
        else
            echo "  ✗ $skill_name (not deployed)"
        fi
    done
    [ "$found" -eq 0 ] && echo "  (none)"

    # Settings diff
    echo ""
    if [ -f "$SCRIPT_DIR/claude/settings.json" ] && [ -f "$CLAUDE_HOME/settings.json" ]; then
        DIFF=$(diff <(cat "$SCRIPT_DIR/claude/settings.json" | python3 -m json.tool 2>/dev/null || cat "$SCRIPT_DIR/claude/settings.json") \
                    <(cat "$CLAUDE_HOME/settings.json" | redact_secrets | python3 -m json.tool 2>/dev/null || cat "$CLAUDE_HOME/settings.json") 2>/dev/null || true)
        if [ -z "$DIFF" ]; then
            echo "settings.json: in sync"
        else
            echo "settings.json: DIFFERS (run pull to update repo)"
        fi
    fi

    # Templates
    echo ""
    TEMPLATE_COUNT=$(find "$SCRIPT_DIR/claude/templates" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo "Templates: $TEMPLATE_COUNT in repo"

    # Project memory
    echo ""
    MEMORY_COUNT=$(find "$SCRIPT_DIR/claude/projects" -name "*.md" -path "*/memory/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "Project memory entries: $MEMORY_COUNT backed up"
}

case "${1:-}" in
    push)   do_push ;;
    pull)   do_pull ;;
    status) do_status ;;
    *)      usage ;;
esac
