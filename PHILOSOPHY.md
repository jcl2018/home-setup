# Philosophy

This is a living-snapshot document. It captures current thinking, not a changelog. Git history preserves the evolution.

## Why This Repo Exists

This repo is personal DevOps for AI workflows. It is the single source of truth for how Claude Code, Codex, and their supporting infrastructure are configured across every machine I use.

The problem it solves is simple: AI-assisted development involves a growing surface area of configuration files, skill definitions, templates, project memory, and upstream tool installations. Without a single canonical location, this state fragments across machines, drifts silently, and becomes impossible to reason about. When I set up a new machine, or revisit this setup after months away, I need one place that tells me exactly what exists, what is mine, what is upstream, and what the current state should be.

This is not a dotfiles repo. Dotfiles repos back up shell configs and editor settings. This repo tracks a fundamentally different kind of state: the contract between me and the AI tools I use daily. It tracks which upstream workflow repos are installed, which home customizations are mine to own, which surfaces are archived backups, and how all of these relate to each other across multiple machines and multiple AI hosts.

The repo also serves as the substrate for automated health checks. The `home_health.py` reconcile helper and the `/home-retro` skill read from `home-inventory.json` to detect drift, reconcile state, and report on upstream freshness. The inventory is the machine-readable contract; the docs and profiles are the human-readable layer on top.

## How I Think About Agentic Workflows

A good AI-assisted development setup has three properties: it is inspectable, it is recoverable, and it separates concerns cleanly.

Inspectable means I can always answer the question "what is my current state?" without guessing. The inventory file, sync status commands, and health checks exist to make the invisible visible. Every tracked surface has a repo path, a live path, a sync scope, and an owner. If something exists on disk but is not in the inventory, it shows up as a stale candidate.

Recoverable means I can rebuild my setup from the repo. If I lose a machine, I clone this repo, read the profile, run the sync script, and I am back. The repo-owned files get pushed out; the backup-only files get pulled in from wherever the live state was last captured. Recovery is not instant magic; it is a documented, repeatable process.

Separation of concerns means upstream tools stay upstream. My customizations stay mine. Backups stay read-only archives until I explicitly pull. The sync script enforces scope boundaries: `push` only touches repo-owned surfaces, `pull` only touches backup-only surfaces, and upstream snapshots are never overwritten by push. This prevents accidental contamination in both directions.

## Upstream Philosophy

I track upstream repos like gstack because they provide workflow infrastructure I depend on but do not own. The value of tracking them is twofold: I get a snapshot in the repo for reference and diff purposes, and I get freshness monitoring so I know when the upstream has released updates.

An upstream is worth tracking when it meets three criteria: I depend on it daily, it updates frequently enough that staleness matters, and it provides a version file or update-check mechanism I can monitor programmatically. If an upstream is static or rarely changes, a one-time reference in documentation is sufficient.

The decision between vendoring and referencing depends on the machine. On unrestricted machines, upstreams are installed via git and auto-upgraded. The repo snapshot is a backup, not the installation source. On restricted machines where git clones are banned, vendoring would theoretically let me carry the upstream in the repo and deploy it manually. But vendoring adds maintenance burden and version sync complexity, so for now, restricted machines simply do without certain upstreams and use alternative skills to fill the gap. Vendoring remains a future design problem, documented in the relevant machine profile.

## Machine Philosophy

Different machines need different setups because they have different constraints. My personal Mac is unrestricted: it has full network access, runs both Claude Code and Codex, installs upstream repos via git, and runs the full sync workflow. My work Windows machine is restricted: it can read GitHub over HTTPS but cannot clone upstream repos, runs only Claude Code, and has domain-specific skills and knowledge that do not belong in the personal setup.

The key insight is the reference-spec principle: this repo describes the reference machine (the personal Mac) directly. The inventory, the sync script, the health checks all assume the reference environment. Other machines are described by their profiles, which document what is shared with the reference machine and what is different. A non-reference machine reads its profile from GitHub and adapts locally. It does not need to clone the repo or run sync.sh. The profile is the spec; the human is the deployment mechanism.

This means profiles are not deployment scripts. They are reference documents. They answer: "If I am sitting at this machine, what should be installed, what is unavailable, what workarounds exist, and how do I verify my setup?" The value is the documented knowledge, not automation.

## What I Have Learned

Patterns that work:
- Separating repo-owned from backup-only surfaces in the inventory prevents accidental overwrites in both directions. This was the single most important design decision.
- The safe-push gate (branch check, dirty worktree check, baseline drift check, live target check, host mismatch check) catches every class of accidental push I have encountered.
- Upstream freshness monitoring via version files and update-check binaries gives me confidence that I am not running stale tools without knowing it.
- Project-local skills (like `/home-retro`) that wrap the health check into the AI workflow mean I do not have to remember to run health checks manually.
- Golden fixture tests for inventory and sync status catch regressions that unit tests miss.

Things tried and abandoned:
- Early versions tried to make sync.sh handle both directions in a single command. Splitting into explicit push/pull with explicit scope was clearer and safer.
- I considered putting machine-specific config directly in home-inventory.json as conditional sections. Separate profile documents are better because they capture context and reasoning, not just key-value pairs.

Surprises:
- The stale candidate detection (finding files in the repo or live home that are not accounted for in the inventory) turned out to be one of the most useful health checks. It catches forgotten experiments and leftover plugins.
- Symlink-aware stale detection matters: upstream tools like gstack create symlinks into their skill directories, and naive stale detection flags them incorrectly.

## Principles

These are non-negotiable rules for this repo:

1. **Never edit upstream snapshots directly.** The `*/skills/gstack/` directories are backup-only mirrors. Changes go upstream; snapshots are refreshed via pull.
2. **Upstream freshness matters.** If an upstream has an update, the health check should surface it. Stale tools are invisible risks.
3. **The inventory is the contract.** Every tracked surface must be in `home-inventory.json`. If it is not in the inventory, it does not exist as far as the tooling is concerned.
4. **Repo-owned means repo-owned.** Push deploys repo-owned files. Pull refreshes backups. These scopes never cross.
5. **Each machine gets its own profile.** Profiles are concrete and machine-specific, not abstract constraint categories.
6. **Read this document before making structural changes.** The philosophy informs the design. Structural changes that contradict the philosophy need to update the philosophy first.
7. **GitHub is the single source of truth.** Any machine, restricted or unrestricted, can read this repo on GitHub and know what the setup should look like.
8. **Automation supports, never replaces, understanding.** The sync script and health checks are tools. The profiles and philosophy are the knowledge. Both matter.
