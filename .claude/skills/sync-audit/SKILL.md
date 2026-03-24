---
name: sync-audit
description: Full audit — checks repo internal consistency, then compares against installed ~/.claude/ state. Reports differences with explanations and suggested fix commands.
---

# /sync-audit — Repo & Install Audit

When `/sync-audit` is invoked, run two phases:
1. **Repo consistency** — is the repo internally correct? (docs, catalog, scripts, profiles agree)
2. **Install sync** — does the installed `~/.claude/` match the repo?

## Design Principle

No automatic sync. This skill provides **visibility**, not automation. It shows what's different and why, then suggests exact commands to fix issues. The user decides what to copy.

---

## Part 1: Repo Consistency

### 1.1 Read the goal

Read `PHILOSOPHY.md` — specifically the Goal and Non-Goals sections. This is the standard everything else is measured against.

### 1.2 Doc consistency

Read every doc file (CLAUDE.md, README.md, PHILOSOPHY.md, profiles/*.md) and check:
- Do skill counts match across all files? (catalog says X, README says Y, profiles say Z)
- Do portability levels referenced in docs match what's in the catalog?
- Does CLAUDE.md layout section match the actual repo file structure?
- Does any doc reference deleted features (sync.sh, home_health.py, tests/, browse skills, `.agents/`, Codex)?
- Report each inconsistency found.

### 1.3 Catalog freshness

Read `skills-catalog.json` and check:
- For each upstream in `upstreams`, check if the live version matches:
  ```bash
  cat {install_path}/{version_file} 2>/dev/null || echo "not installed"
  ```
- If versions differ: "Catalog says {X}, live is {Y} — re-copy skills and bump version."
- Count skills in catalog vs SKILL.md files in `skills/` and `.claude/skills/` — do they match?
- Check if any SKILL.md files exist that aren't in the catalog (orphans).
- Check if any catalog entries point to SKILL.md files that don't exist (missing files).

### 1.4 Gap analysis

If an upstream is installed locally, compare what's available vs what's in the catalog:
```bash
ls ~/.claude/skills/gstack/*/SKILL.md 2>/dev/null | sed 's|.*/gstack/||;s|/SKILL.md||' | sort
```
Compare against catalog skill names. Report:
- Skills available upstream but not in catalog — are any of them portable? Should they be added?
- Skills in catalog that no longer exist upstream — stale entries?

### 1.5 Shell script check

For each file in `skills/bin/`:
- Is it referenced by at least one catalog skill's dependencies? If not, it's orphaned.
- Does every catalog skill that lists a `gstack-*` dependency have the corresponding file in `skills/bin/`? If not, it's missing.

### 1.6 Profile completeness

For each profile in `profiles/`:
- Does it list the correct number of available skills based on current catalog?
- Does it reference the correct portability breakdown?
- Does it have the structured format (Identity, Paths, Expected Local Content, Settings Override)?

### 1.7 Knowledge and settings check

- Does `knowledge/` contain the expected shared files?
- Does `settings/baseline.json` exist?
- Does each profile's `override_file` point to a file that exists in `settings/overrides/`?

---

## Part 2: Install Sync

### 2.1 Locate the repo

Find the home-setup repo root. Try these in order:
1. Current working directory (check for `skills-catalog.json` at the root).
2. The `repo_path` declared in the matching profile (see step 2.2).
3. Common locations: `~/home-setup`, `~/Documents/home-setup`.

If not found, stop: "Could not find the home-setup repo. Run /sync-audit from the repo directory or update your profile's `repo_path`."

Set `$REPO` to the repo root path for all subsequent steps.

### 2.2 Identify the machine profile

Read all `profiles/*.md` files from the repo. Match the current machine by checking:
- `machine_id` field against known identifiers
- `os` field against the current OS (`uname -s` on Unix, `$OS` or `systeminfo` on Windows)
- `hostname` field against the current hostname (`hostname`)

If exactly one profile matches, use it. If none or multiple match, ask the user which profile applies.

Parse from the matched profile:
- `skills_install` path (default: `~/.claude/skills`)
- `knowledge_install` path (default: `~/.claude/knowledge`)
- `settings_path` (default: `~/.claude/settings.json`)
- `override_file` (settings override path in the repo)
- `Expected Local Content` list (items that are expected to differ)

### 2.3 Compare skills

For each skill in `skills-catalog.json`:
- Determine the repo source path:
  - `gstack` source: `$REPO/skills/{name}/SKILL.md`
  - `custom` source: `$REPO/.claude/skills/{name}/SKILL.md`
- Check if the skill exists at `{skills_install}/{name}/SKILL.md`
- If missing: status = **MISSING**
- If present: compare file sizes. If sizes differ, status = **DRIFTED**. If same size, compare first 5 + last 5 lines as a quick content check. If those match, status = **IN SYNC**.

Also scan `{skills_install}/` for directories NOT in the catalog:
- Skip `bin/` (checked separately) and `gstack/` (upstream install, not managed by this repo)
- For any other unknown skill directory: status = **LOCAL-UNDECLARED**

### 2.4 Compare knowledge files

For each `.md` file in `$REPO/knowledge/`:
- Check if it exists at `{knowledge_install}/{filename}`
- If missing: status = **MISSING**
- If present: compare file sizes. If sizes differ: **DRIFTED**. Otherwise quick content check → **IN SYNC**.

Scan `{knowledge_install}/` for files and directories NOT in `$REPO/knowledge/`:
- Check each against the profile's "Expected Local Content" list
- If declared: status = **LOCAL-EXPECTED** (with the comment from the profile)
- If not declared: status = **LOCAL-UNDECLARED**

### 2.5 Compare bin scripts

For each file in `$REPO/skills/bin/`:
- Check if it exists at `{skills_install}/bin/{filename}`
- Compare as in step 2.3.

### 2.6 Compare settings

Read `$REPO/settings/baseline.json` and the profile's override file (e.g., `$REPO/settings/overrides/synopsys-windows.json`).

Compute the expected settings:
1. Start with `baseline.json`
2. Append `allow_append` entries to `permissions.allow`
3. Set `additionalDirectories` from the override

Read the actual `{settings_path}`.

Compare:
- Permissions in expected but not in actual → **MISSING** permission
- Permissions in actual but not in expected → **LOCAL** permission (may be intentional)
- `effortLevel` difference → report
- `additionalDirectories` differences → report

### 2.7 Check for stale artifacts

Check for known stale files:
- `~/AGENTS.md` — Codex-era global contract, should be deleted
- `~/.codex/` with more than just `auth.json` and `config.toml` — leftover Codex content

For each found: status = **STALE**

---

## Report Format

Output as markdown:

```markdown
## Sync Audit Report

**Machine:** {profile machine_id}
**Repo:** {$REPO}
**Date:** {current date}

### Part 1: Repo Consistency

#### Doc Consistency: {PASS / N issues}
{List each inconsistency found, or "All docs agree on skill counts, portability, and structure."}

#### Catalog Freshness: {IN SYNC / STALE}
{Version comparison results}

#### Gap Analysis: {PASS / N suggestions}
{New upstream skills found? Stale catalog entries?}

#### Shell Scripts: {PASS / N issues}
{Orphaned or missing scripts}

#### Profiles: {PASS / N issues}
{Format and count checks}

#### Knowledge & Settings: {PASS / N issues}
{Shared files present? Override files exist?}

### Part 2: Install Sync

#### Skills: {IN SYNC / N issues}

| Skill | Source | Status | Detail |
|-------|--------|--------|--------|
| /careful | gstack | IN SYNC | |
| /domain-context | custom | MISSING | Not installed |
| ... | ... | ... | ... |

#### Knowledge: {IN SYNC / N issues}

| File | Status | Detail |
|------|--------|--------|
| code-change-comment-style.md | IN SYNC | |
| aedt/ | LOCAL-EXPECTED | AEDT domain corpus (work-specific, 65MB) |
| ... | ... | ... |

#### Bin Scripts: {IN SYNC / N issues}

| Script | Status | Detail |
|--------|--------|--------|
| gstack-config | IN SYNC | |
| ... | ... | ... |

#### Settings: {IN SYNC / N issues}

{List each difference between expected and actual settings}

#### Stale Artifacts: {CLEAN / N found}

{List any stale files found with recommendations}

### Summary

- **Repo consistency:** {PASS / N issues}
- **IN SYNC:** N items
- **MISSING:** N items (need deployment)
- **DRIFTED:** N items (investigate)
- **LOCAL-EXPECTED:** N items (declared in profile, OK)
- **LOCAL-UNDECLARED:** N items (add to profile or repo)
- **STALE:** N items (recommend deletion)

### Suggested Actions

{For each issue, output the exact action or shell command to fix it:}

\`\`\`bash
# Missing skills:
cp -r "$REPO/.claude/skills/domain-context" ~/.claude/skills/

# Drifted knowledge:
cp "$REPO/knowledge/work-start-checklist.md" ~/.claude/knowledge/

# Stale artifacts:
rm ~/AGENTS.md
\`\`\`
```

If everything passes: "All clear — repo is internally consistent and in sync with this machine."

---

## Status Categories

| Status | Meaning | Action |
|---|---|---|
| IN SYNC | Repo and installed match | None |
| MISSING | In repo but not installed | Copy from repo |
| DRIFTED | Both exist but content differs | Re-copy from repo, or update repo if local change is intentional |
| LOCAL-EXPECTED | Not in repo, declared in profile | None — this is expected machine-local content |
| LOCAL-UNDECLARED | Not in repo, not in profile | Investigate: add to repo (if shared) or declare in profile (if machine-local) |
| STALE | Should no longer exist | Delete |
