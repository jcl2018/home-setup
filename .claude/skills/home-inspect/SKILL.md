---
name: home-inspect
description: 5-room mechanical health check for home-setup repo. Deterministic, no AI judgment. Reports PASS/WARN/FAIL for each check.
---

# /home-inspect — Mechanical Health Engine

Run 5 rooms of deterministic health checks. No AI review (that's /governance-audit).
Report PASS, WARN, or FAIL for each check. Suggest exact fix commands.

Reference: `audit-spec.json` maps each check ID to audit goals (AG1-AG9).

## Room 1: Skill Sync (AG1)

Check 1.1: gstack version. Compare `skills-catalog.json` upstream version against `cat ~/.claude/skills/gstack/VERSION`.
Check 1.2: Skill sync. For each skill in the catalog, verify its SKILL.md exists in `~/.claude/skills/`.
Check 1.3: Knowledge sync. For each `.md` file in `knowledge/`, verify it exists in `~/.claude/knowledge/` and matches (diff).
Check 1.4: Bin scripts. For each script in `skills/bin/`, verify it exists in `~/.claude/skills/gstack/bin/`.
Check 1.5: Settings. Verify `~/.claude/settings.json` exists.
Check 1.6: Stale artifacts. Check for historical remnants: `.agents/`, `sync.sh`, `tests/`, `.codex/` in `~/.claude/`.
Check 1.7: Upstream latest. Compare catalog version against live gstack VERSION. If different, WARN with upgrade suggestion.

## Room 2: Catalog Health (AG2-AG5)

Check 2.1: SKILL.md count. For each skill in catalog, verify `skills/{name}/SKILL.md` or `.claude/skills/{name}/SKILL.md` exists on disk.
Check 2.2: CLI deps. Verify `git`, `gh`, `jq`, `codex` are on PATH.
Check 2.3: Rules frontmatter. For each `.claude/rules/*.md`, verify it has a `paths:` field in YAML frontmatter.
Check 2.4: Commands non-empty. For each `.claude/commands/*.md`, verify it has content (not empty).
Check 2.5: Per-skill table. List all skills in catalog with source and description. Compare against cheatsheet if it exists.
Check 2.6: Hardcoded counts. Grep docs for hardcoded skill count numbers. WARN if found.
Check 2.7: Doc lanes. Verify each doc's content matches its lane assignment per the lanes table in PHILOSOPHY.md.

## Room 3: Home Archaeology (AG6, AG9)

Check 3.1: Orphan skills. List installed skill dirs in `~/.claude/skills/` not in the catalog. Exclude `gstack` (the upstream root).
Check 3.2: Stale sessions. Count session files in `~/.gstack/sessions/` older than 24h.
Check 3.3: Temp files. Find `.tmp`, `.pending-*`, `.bak` files in `~/.claude/` and `~/.gstack/`.
Check 3.4: Oversized files. Find files >10MB in `~/.claude/` and `~/.gstack/`.
Check 3.5: Empty dirs. Find empty directories in `~/.claude/` and `~/.gstack/`.
Check 3.6: Historical artifacts. Check for remnants from past repo iterations.

## Room 4: Knowledge Freshness (AG1, AG4, AG5)

Check 4.1: INDEX.md. Verify `~/.claude/knowledge/INDEX.md` exists and is non-empty.
Check 4.2: Repo knowledge deployed. For each knowledge file in repo, verify it exists in `~/.claude/knowledge/` and matches.
Check 4.3: Empty files. Find zero-byte `.md` files in `~/.claude/knowledge/`.
Check 4.4: INDEX cross-refs. Parse INDEX.md references and verify each target file exists.

## Room 5: System Vitals (AG1, AG9)

Check 5.1: `~/.claude/` disk size. Report total size with `du -sh`.
Check 5.2: `~/.gstack/` disk size. Report total size with `du -sh`.
Check 5.3: Analytics volume. Count lines in `~/.gstack/analytics/*.jsonl`.
Check 5.4: Active sessions. Count files in `~/.gstack/sessions/`.
Check 5.5: Memory files. Count files in `~/.claude/projects/` memory directories.
Check 5.6: settings.json. Verify `~/.claude/settings.json` exists.
Check 5.7: Repo status. Run `git status --porcelain` and report if dirty.

## Output Format

For each check: `[PASS|WARN|FAIL] {id} {title} — {detail}`

At the end, summarize: `X pass, Y warn, Z fail out of N checks.`

For each FAIL or WARN, suggest the exact fix command.
