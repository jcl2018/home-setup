# CLAUDE.md — home-setup

Self-governing Claude Code configuration repo. Principles, audit goals, automated deploy, and doc compilation. Reference implementation for governance-as-code. See `skills-catalog.json` for the current skill count.

## Layout

```
home-setup/
├── skills-catalog.json          <- every skill with metadata
├── audit-spec.json              <- audit goals + check-to-goal mappings
├── scripts/
│   ├── deploy.sh                <- deploys repo -> ~/.claude/
│   ├── validate-audit-spec.sh   <- validates audit-spec.json coverage closure
│   └── gen-docs.sh              <- doc compiler: generates traceability + skills ref
├── skills/                      <- upstream SKILL.md files (from gstack)
│   ├── bin/                     <- shell scripts some skills depend on
│   └── {name}/SKILL.md          <- one per upstream skill (30 total)
├── .claude/
│   ├── skills/                  <- custom skills (authored here)
│   │   ├── home-inspect/        <- 5-room mechanical health check
│   │   ├── governance-audit/    <- deterministic + AI content review
│   │   ├── project-contract/    <- write/tighten CLAUDE.md for any repo
│   │   ├── repo-bootstrap/      <- onboard a repo for Claude Code
│   │   └── domain-context/      <- load/capture domain knowledge
│   ├── hooks/                   <- Claude Code hooks
│   │   └── post-commit-deploy.sh <- auto-deploys after git commit (P11)
│   ├── rules/                   <- path-scoped rules (activate per file context)
│   │   ├── upstream-skills.md   <- enforces P2 on skills/**
│   │   ├── custom-skills.md     <- enforces P3 on .claude/skills/**
│   │   ├── deployable-files.md  <- enforces P11 on knowledge/**, settings/**
│   │   └── ...                  <- 8 rules total
│   └── commands/                <- project slash commands
│       ├── deploy.md            <- /project:deploy
│       └── audit.md             <- /project:audit
├── knowledge/                   <- shared knowledge (deployed to ~/.claude/knowledge/)
│   ├── code-best-practices.md   <- commits, PRs, comments, ticket traceability
│   └── INDEX.md
├── settings/                    <- permission baselines and overrides
│   ├── baseline.json
│   └── overrides/
├── profiles/                    <- per-machine descriptions (historical)
├── docs/
│   ├── design/                  <- "Understand why this exists"
│   │   ├── PHILOSOPHY.md        <- 5 principles + 9 audit goals (AG1-AG9)
│   │   ├── DECISIONS.md         <- decision journal (D1-D11)
│   │   └── traceability.md      <- AUTO-GENERATED: principle->goal->check map
│   ├── operations/              <- "Operate and extend the system"
│   │   ├── SKILLS-CHEATSHEET.md <- quick skill command reference
│   │   ├── COMMANDS-AND-RULES.md <- project commands and path-scoped rules
│   │   ├── INSPECTION-BASELINE.md <- known-good state snapshot
│   │   ├── skills-reference.md  <- AUTO-GENERATED: catalog-derived skill table
│   │   └── getting-started.md   <- 5-minute onboarding guide
│   └── inspections/             <- audit snapshots (auto-saved by /project:audit)
├── CLAUDE.md                    <- this file
└── README.md
```

## Principles

Five active design principles (see `docs/design/PHILOSOPHY.md` for full details):

- **P1: Single Source of Truth.** This repo owns what's shared. `~/.claude/` is a deployment.
- **P2: Upstream Skills Are Copies.** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **P3: Custom Skills Are Ours.** `.claude/skills/` contains skills we authored. Add to catalog.
- **P5: Always-On Over Invocation.** Knowledge files beat skills for enforcing standards.
- **P11: Deploy or It Didn't Happen.** Committed-but-not-deployed is a bug. Post-commit hook auto-deploys.

## Rules

- **Deploy after changes.** After editing deployable files (knowledge/, skills/, settings/, .claude/skills/), run `bash scripts/deploy.sh`. A post-commit hook runs it automatically.
- **Verify with /project:audit.** After any change, run `/project:audit` for unified health + governance check with snapshots.
- **Upstream skills are copies, not forks (P2).** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **Custom skills live in .claude/skills/ (P3).** Add to catalog and update the cheatsheet.
- **Doc compiler.** After editing `audit-spec.json` or `skills-catalog.json`, run `bash scripts/gen-docs.sh` to regenerate traceability and skills reference docs.

## Machine

- **machine_id:** personal-mac
- **os:** macOS (Darwin)
- **hosts:** Claude Code (VSCode extension, CLI)
- **network:** unrestricted
- **settings_override:** settings/overrides/personal-mac.json

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming -> invoke office-hours
- Bugs, errors, "why is this broken", 500 errors -> invoke investigate
- Ship, deploy, push, create PR -> invoke ship
- QA, test the site, find bugs -> invoke qa
- Code review, check my diff -> invoke review
- Update docs after shipping -> invoke document-release
- Weekly retro -> invoke retro
- Design system, brand -> invoke design-consultation
- Visual audit, design polish -> invoke design-review
- Architecture review -> invoke plan-eng-review
- Save progress, checkpoint, resume -> invoke checkpoint
- Code quality, health check -> invoke health
