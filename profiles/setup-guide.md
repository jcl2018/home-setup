# New Machine Setup Guide

This is the "I just got a new laptop, now what?" document. Follow these steps to set up a new machine from this repo.

## Step 1: Read the Philosophy

Read [PHILOSOPHY.md](../PHILOSOPHY.md) to understand why this repo exists, how it thinks about agentic workflows, and what principles are non-negotiable. This context informs every decision below.

## Step 2: Find Your Profile

Look in the `profiles/` directory for your machine's profile:
- [personal-mac.md](personal-mac.md) — macOS, unrestricted network, Claude Code + Codex
- [work-windows.md](work-windows.md) — Windows, restricted network, Claude Code only

If no profile matches your machine, create a new one using the template below. Each machine gets its own profile.

### Profile Template

```markdown
# Profile: {machine name}

## Environment
- OS: {macOS / Windows / Linux}
- Hosts: {Claude Code, Codex, or both}
- Network: {unrestricted / restricted (describe limits)}

## Upstreams
- {upstream name}: {available (git/vendored) / unavailable (reason)}

## Custom Skills & Knowledge
- {list of custom skills, domain knowledge, or work-specific configs}

## Sync Strategy
- {full sync.sh / manual reference from GitHub / other}

## Shared with Reference Machine
- {what is the same as personal-mac}

## Differences from Reference Machine
- {what is different and why}

## Workarounds for Missing Upstreams
- {if an upstream is unavailable, what is the alternative?}
```

## Step 3: Clone or Bookmark the Repo

- **Unrestricted machines:** Clone the repo locally.
  ```bash
  git clone git@github.com:jcl2018/home-setup.git
  cd home-setup
  ```
- **Restricted machines:** Bookmark the repo on GitHub. You will read profiles and configuration from the web interface and apply them manually.

## Step 4: Set Up (Unrestricted Machines)

If your profile says you have unrestricted network access:

1. **Install upstreams** listed in your profile. For gstack:
   ```bash
   # Follow gstack's own installation instructions
   ```
2. **Push repo-owned configuration** to your live home:
   ```bash
   ./sync.sh push --host claude --scope repo-owned
   ./sync.sh push --host codex --scope repo-owned
   ```
3. **Pull live state** into the repo to capture initial backups:
   ```bash
   ./sync.sh pull --host claude --scope backup-only
   ./sync.sh pull --host codex --scope backup-only
   ```

## Step 5: Set Up (Restricted Machines)

If your profile says you have restricted network access:

1. Read your profile carefully for what to configure manually.
2. Note which upstreams are unavailable and what workarounds exist.
3. Set up Claude Code (or Codex) configuration by hand, referencing the repo-owned files in this repo as the source of truth.
4. Document any machine-specific skills or knowledge in your profile.

## Step 6: Verify

- **On unrestricted machines** with the repo cloned:
  ```bash
  python3 ./home_health.py --host claude
  python3 ./home_health.py --host codex
  ```
  The health report should show no unexpected drift, no stale candidates, and your profile should be detected in the Docs Health section.

- **On restricted machines:** Check manually against your profile. Ensure that the configuration you applied matches what the profile specifies, that unavailable upstreams are noted, and that workarounds are in place.

## Ongoing Maintenance

- Run `./sync.sh status` weekly to catch drift.
- Use `/home-retro` during regular development to surface health issues.
- Update your profile when your machine's constraints change.
- Read PHILOSOPHY.md before making structural changes to the repo.
