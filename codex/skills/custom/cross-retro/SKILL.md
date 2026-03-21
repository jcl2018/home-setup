---
name: cross-retro
description: Weekly cross-repo retrospective plus Codex home health. Reviews repo activity, skill-usage patterns, and Codex configuration health, then writes a report into the Codex project store.
---

# Cross-Repo Retro + Codex Health

Run a 7-day retrospective across repos under `~/Documents/projects`, then append a Codex home-health pass so the report covers both engineering output and workflow quality.

## What to analyze

### 1. Repo activity
- Scan git history across active repos in `~/Documents/projects/`.
- Summarize commits, insertions/deletions, active days, and top hotspots.
- Call out the highest-output repo, biggest ship, and any obvious churn inflation from backup or mirror files.

### 2. Sessions and timing
- Group commits into sessions by time proximity.
- Report deep vs medium vs micro sessions.
- Flag multi-repo sessions and notable context-switching windows.

### 3. Skill usage
- If `~/.gstack/analytics/skill-usage.jsonl` exists, summarize the last 7 days.
- Report top skills, repo attribution quality, and repos with code activity but zero logged skill usage.

### 4. Codex health
- Check `~/.codex/skills/gstack/VERSION` and whether an upgrade is pending.
- If available, run `~/.codex/bin/codex-home-health` and `~/.codex/bin/codex-skill-check`.
- Summarize `~/.codex/config.toml`, `~/AGENTS.md`, guardrails state, and project-store coverage under `~/.codex/projects/`.
- Verify repo-backed custom skill sources under `home-setup/codex/skills/custom/` and note dangling live symlinks under `~/.codex/skills/`.

## Output

Produce a markdown report with these sections:

```markdown
# Cross-Repo Retro + Codex Health
Date: YYYY-MM-DD | Window: 7d

## Tweetable
...

## Summary Table
...

## Per-Repo Breakdown
...

## Time & Sessions
...

## Shipping Velocity
...

## Skill Usage
...

## Codex Config Health
...

## Your Week
...

## Suggestions
1. ...
2. ...

## Trends vs Last
...
```

Save the report under `~/.codex/projects/home-control/retro/` with a timestamped filename. If a prior run exists, compare against it briefly. End by asking whether the user wants to act on any of the suggestions.
