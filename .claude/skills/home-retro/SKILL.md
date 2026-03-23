---
name: home-retro
description: Repo-local Claude home retro. Runs the normal rich gstack /retro for this repo, then appends a detailed Claude-only home-health section with drift reconcile results.
---

# Claude Home Retro

When `/home-retro` is invoked from this repo in Claude:

1. First run the normal upstream gstack retro workflow for this repo from `~/.claude/skills/gstack/retro/SKILL.md`.
2. Keep the full original retro output: engineering summary, trends, hotspots, and whatever else the upstream retro would normally report for this repo.
3. After the normal retro, run `python3 ./home_health.py --host claude`.
4. Append a dedicated `Home Health (Claude)` section after the normal retro output.
5. In that home-health section, report only Claude-side tracked upstreams and Claude home customizations.
6. Do not scan or reconcile Codex-side state in this run.
7. Be detailed for each checked item:
   - what repo path was checked
   - what live path it was compared against
   - what status was found
   - what action was taken or skipped
8. Distinguish:
   - fixed automatically
   - blocked because repo-owned push was unsafe
   - reported only, like upstream freshness

Manual escape hatch:

- `./sync.sh status --host claude`
- `./sync.sh pull --host claude --scope backup-only`
- `./sync.sh push --host claude --scope repo-owned`
- `python3 ./home_health.py --host claude`
