---
name: audit
description: Scan your AI workflow configs and suggest improvements. Checks gstack version, CLAUDE.md coverage, stale memory, hooks, permissions, and skill usage across all repos.
---

# AI Workflow Audit

Scan the user's AI tool configuration surface and produce a structured report with findings and suggestions.

## What to scan

### 1. Gstack version
```bash
LIVE_VER=$(cat ~/.claude/skills/gstack/VERSION 2>/dev/null || echo "not installed")
REMOTE_VER=$(~/.claude/skills/gstack/bin/gstack-update-check --force 2>/dev/null | grep UPGRADE_AVAILABLE | awk '{print $3}' || echo "")
```
- Is gstack installed? What version?
- Is an update available?

### 2. CLAUDE.md coverage
Scan all repos under ~/Documents/projects/:
```bash
for repo in ~/Documents/projects/*/; do
    [ -d "$repo/.git" ] || continue
    name=$(basename "$repo")
    has_claude=$([ -f "$repo/CLAUDE.md" ] && echo "yes" || echo "no")
    has_agents=$([ -f "$repo/AGENTS.md" ] && echo "yes" || echo "no")
    echo "$name: CLAUDE.md=$has_claude AGENTS.md=$has_agents"
done
```

### 3. Project memory
Check ~/.claude/projects/ for:
- Projects with memory entries vs empty
- Stale memory (files older than 30 days)
- Memory entries that reference deleted repos

### 4. Settings audit
Check ~/.claude/settings.json for:
- Any hooks configured?
- Permission mode (default vs dontAsk)
- Environment variables set
- MCP servers configured

### 5. Skill usage (if analytics available)
Check ~/.gstack/analytics/skill-usage.jsonl:
- Which skills are used most?
- Which skills have never been used?
- Average session duration

### 6. Custom skills health
Check home-setup/claude/skills/custom/:
- Are custom skills deployed (symlinked to ~/.claude/skills/)?
- Any community skills not yet tried?

## Output format

Present as a structured report:

```
=== AI Workflow Audit ===
Date: YYYY-MM-DD

## Gstack
- Version: vX.Y.Z [UP TO DATE / UPDATE AVAILABLE: vX.Y.Z]

## CLAUDE.md Coverage
| Repo | CLAUDE.md | AGENTS.md |
|------|-----------|-----------|
| ... | ✓/✗ | ✓/✗ |
Missing: N repos without CLAUDE.md

## Project Memory
- N projects with memory
- N stale entries (>30 days)

## Settings
- Permission mode: ...
- Hooks: N configured
- MCP servers: N configured

## Skill Usage (last 7 days)
- Most used: ...
- Never used: ...

## Suggestions
1. [actionable suggestion]
2. [actionable suggestion]
...
```

Use AskUserQuestion to present the report and ask if the user wants to fix any findings.
