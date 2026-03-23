---
name: home-retro
description: Repo-local Codex home retro. Runs the normal rich gstack /retro for this repo, then appends a detailed Codex-only home-health section with drift reconcile results.
---

# Codex Home Retro

When `/home-retro` is invoked from this repo in Codex:

1. First run the normal upstream gstack retro workflow for this repo from `~/.codex/skills/gstack/retro/SKILL.md`.
2. Keep the full original retro output: engineering summary, trends, hotspots, and whatever else the upstream retro would normally report for this repo.
3. After the normal retro, run `python3 ./home_health.py --host codex`.
4. Append a dedicated `Home Health (Codex)` section after the normal retro output.
5. In that home-health section, report only Codex-side tracked upstreams and Codex home customizations.
6. Do not scan or reconcile Claude-side state in this run.
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

- `./sync.sh status --host codex`
- `./sync.sh pull --host codex --scope backup-only`
- `./sync.sh push --host codex --scope repo-owned`
- `python3 ./home_health.py --host codex`
