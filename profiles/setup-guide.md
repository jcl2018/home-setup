# Setup Guide

## Step 1: Clone the Repo

Clone this repo to a location on your machine. This is your single source of truth for Claude Code configuration.

## Step 2: Find Your Profile

Look in `profiles/` for your machine:
- [personal-mac.md](personal-mac.md) — macOS, unrestricted, Claude Code, all skills available
- [synopsys-windows.md](synopsys-windows.md) — Windows, restricted, Claude Code (VSCode), all skills available

If no profile matches, create one. Key fields: OS, hostname, hosts, network, gstack availability, expected local content.

## Step 3: Deploy Skills

Copy all skills from the repo to your Claude Code skills directory:

```bash
REPO="/path/to/home-setup"
cp -r "$REPO/skills/"* ~/.claude/skills/
cp -r "$REPO/.claude/skills/"* ~/.claude/skills/
```

Shell scripts that some skills depend on (autoplan, land-and-deploy, review, ship) are in `skills/bin/`. They get copied with the above command.

## Step 4: Deploy Knowledge

Copy shared knowledge files:

```bash
cp "$REPO/knowledge/"*.md ~/.claude/knowledge/
```

Machine-local knowledge (like AEDT domain corpus) stays in `~/.claude/knowledge/` — it's declared in your profile under "Expected Local Content."

## Step 5: Create Persistence Dirs

```bash
mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions
```

## Step 6: Verify

Run `/sync-audit` from this repo to compare the repo against your installed `~/.claude/`. It reports what's in sync, what's missing, and what's local-only (with explanations).

Run `/skill-status` to confirm the skill catalog matches your install.
