---
name: audit
description: Scan your Claude and Codex workflow configs and suggest improvements. Checks both homes, gstack status, repo contracts, stale memory, settings, and skill usage across all repos.
---

# AI Workflow Audit

Scan the user's Claude and Codex workflow surface and produce a structured report with findings and suggestions.

## What to scan

### 1. Gstack status on both hosts
```bash
CLAUDE_LIVE_VER=$(cat ~/.claude/skills/gstack/VERSION 2>/dev/null || echo "not installed")
CLAUDE_REMOTE_VER=$(~/.claude/skills/gstack/bin/gstack-update-check --force 2>/dev/null | grep UPGRADE_AVAILABLE | awk '{print $3}' || echo "")
CODEX_LIVE_VER=$(cat ~/.codex/skills/gstack/VERSION 2>/dev/null || echo "not installed")
CODEX_REMOTE_VER=$(~/.codex/skills/gstack/bin/gstack-update-check --force 2>/dev/null | grep UPGRADE_AVAILABLE | awk '{print $3}' || echo "")
```
- Is gstack installed for Claude and Codex?
- What versions are live?
- Is an update available on either host?

### 2. Repo contract coverage
Scan all repos under `~/Documents/projects/`:
```bash
for repo in ~/Documents/projects/*/; do
    [ -d "$repo/.git" ] || continue
    name=$(basename "$repo")
    has_claude=$([ -f "$repo/CLAUDE.md" ] && echo "yes" || echo "no")
    has_agents=$([ -f "$repo/AGENTS.md" ] && echo "yes" || echo "no")
    echo "$name: CLAUDE.md=$has_claude AGENTS.md=$has_agents"
done
```
- `market-watch`-style Codex-only repos are allowed, but call them out explicitly.

### 3. Claude project memory
Check `~/.claude/projects/` for:
- Projects with memory entries vs empty
- Stale memory (files older than 30 days)
- Memory entries that reference deleted repos

### 4. Claude settings audit
Check `~/.claude/settings.json` for:
- Any hooks configured?
- Permission mode (default vs dontAsk)
- Environment variables set
- MCP servers configured

### 5. Codex config audit
Check `~/.codex/config.toml` and `~/AGENTS.md` for:
- Model and reasoning settings
- `multi_agent` or related feature toggles
- Any project trust entries that look stale or machine-specific
- Whether `AGENTS.md` matches the repo-backed `codex/AGENTS.md` intent

### 6. Skill usage (if analytics available)
Check `~/.gstack/analytics/skill-usage.jsonl`:
- Which skills are used most?
- Which skills have never been used?
- Average session duration

### 7. Project-local and custom skill health
Check:
- `.claude/skills/audit/SKILL.md`
- `.agents/skills/audit/SKILL.md`
- repo-backed Codex custom skill sources under `home-setup/codex/skills/custom/`
- matching live symlinks under `~/.codex/skills/`
- any dangling symlinks or missing sources

## Output format

Present as a structured report:

```
=== AI Workflow Audit ===
Date: YYYY-MM-DD

## Claude
- Gstack: vX.Y.Z [UP TO DATE / UPDATE AVAILABLE: vX.Y.Z]
- Settings: ...
- Memory: ...

## Codex
- Gstack: vX.Y.Z [UP TO DATE / UPDATE AVAILABLE: vX.Y.Z]
- Config: ...
- AGENTS.md: ...

## Repo Contracts
| Repo | CLAUDE.md | AGENTS.md |
|------|-----------|-----------|
| ... | ✓/✗ | ✓/✗ |
Missing: N repos without CLAUDE.md

## Skill Usage (last 7 days)
- Most used: ...
- Never used: ...

## Skill Sources
- Claude audit: ok/missing
- Codex audit: ok/missing
- Custom Codex skills: ok/dangling

## Suggestions
1. [actionable suggestion]
2. [actionable suggestion]
...
```

Present the report and ask if the user wants to fix any findings.
