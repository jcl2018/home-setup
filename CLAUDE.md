# CLAUDE.md — home-setup

Single source of truth for Claude Code configuration across all machines. Ships skills, shared knowledge, and settings templates. 24 skills total (19 upstream gstack + 5 custom). Multi-upstream ready (currently gstack).

## Layout

```
home-setup/
├── skills-catalog.json          ← every skill with portability metadata
├── skills/                      ← actual SKILL.md files for 19 portable upstream skills
│   ├── office-hours/SKILL.md    ← YC-style brainstorming
│   ├── plan-eng-review/SKILL.md ← architecture review
│   ├── ship/SKILL.md            ← ship workflow
│   ├── bin/                     ← shell scripts (gstack-config, gstack-diff-scope, etc.)
│   └── ... (19 upstream total)
├── .claude/skills/              ← 5 custom skills
│   ├── skill-status/            ← catalog status report
│   ├── project-contract/        ← write/tighten CLAUDE.md for any repo
│   ├── repo-bootstrap/          ← onboard a repo for Claude Code
│   ├── domain-context/          ← load/capture domain knowledge
│   └── sync-audit/              ← repo consistency + install sync audit
├── knowledge/                   ← shared knowledge files (deployed to ~/.claude/knowledge/)
│   ├── code-change-comment-style.md
│   ├── commit-message-template.md
│   └── ... (7 files)
├── settings/                    ← settings templates
│   ├── baseline.json            ← shared permission baseline
│   └── overrides/               ← per-machine settings deltas
├── profiles/                    ← per-machine descriptions
│   ├── synopsys-windows.md      ← Synopsys work machine
│   ├── personal-mac.md          ← reference machine
│   └── setup-guide.md           ← new machine setup
├── PHILOSOPHY.md                ← why this repo exists
├── CLAUDE.md                    ← this file
└── README.md
```

## Rules

- **Keep skills/ current.** After any upstream upgrade, re-copy portable SKILL.md files and `skills/bin/` scripts, then update `skills-catalog.json` (bump the version in `upstreams`). `/skill-status` flags version mismatches.
- **skills/ are copies, not forks.** Don't edit upstream SKILL.md files in skills/. They should match the live upstream install exactly. Custom skills live in `.claude/skills/`.
- **knowledge/ is shared.** Files in `knowledge/` should be deployed to `~/.claude/knowledge/` on every machine. Machine-local knowledge (like AEDT) is declared in the machine's profile.
- **Profiles describe machines.** Each profile lists what skills are available and what machine-local content is expected. Update when constraints change.
- **Use /sync-audit to verify.** After changes, run `/sync-audit` to compare the repo against the installed state.

## Remote Machine Setup

On a machine that can't install gstack:
1. Clone this repo (or read on GitHub)
2. `mkdir -p ~/.gstack/projects ~/.gstack/analytics ~/.gstack/sessions`
3. Copy skills from `skills/` and `.claude/skills/` into `~/.claude/skills/`
4. Copy knowledge files from `knowledge/` into `~/.claude/knowledge/`
5. Copy `skills/bin/` to a location on your PATH (shell scripts some skills depend on)
6. Run `/sync-audit` to verify everything is in sync

## /sync-audit

The primary verification skill. Compares the repo (source of truth) against installed `~/.claude/` state. Reports skills, knowledge, settings, and bin scripts as IN SYNC, MISSING, DRIFTED, LOCAL-EXPECTED, or LOCAL-UNDECLARED. Outputs exact shell commands to fix issues.

## /skill-status

Reports on each skill in the catalog: what it does, where it comes from, what files it needs. Checks upstream version alignment.
