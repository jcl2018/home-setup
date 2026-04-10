# CLAUDE.md — home-setup

Self-governing Claude Code configuration repo with full PRD-TDD pipeline. Manages skills, templates, doc triplets, and a work pipeline deployed to `~/.claude/`. See `skills-catalog.json` for the current skill count.

## Layout

```
home-setup/
├── skills-catalog.json          <- every skill with metadata
├── skill-contracts.json         <- behavioral contracts for daily-use skills
├── artifact-manifests.json      <- declarative artifact definitions per work item type
├── audit-spec.json              <- audit goals + check-to-goal mappings
├── scripts/
│   ├── deploy.sh                <- deploys repo -> ~/.claude/
│   ├── skills-pull.sh           <- one-command submodule update for claude-skills-templates
│   ├── health-checks.sh         <- deterministic checks for /health (layers 7, 9)
│   ├── validate-audit-spec.sh   <- validates audit-spec.json coverage closure
│   ├── validate-skill-contracts.sh <- validates skill-contracts.json schema + coverage
│   └── gen-docs.sh              <- doc compiler: generates traceability + skills ref
├── upstreams/
│   └── claude-skills-templates/ <- git submodule (P6: version-pinned content you own)
│       ├── skills/              <- custom skills (work pipeline + governance)
│       ├── spec/templates/      <- type-specific templates
│       └── templates/           <- legacy doc templates
├── skills/                      <- upstream SKILL.md files (P2: don't edit)
│   ├── bin/                     <- shell scripts some skills depend on
│   ├── {name}/SKILL.md          <- flat upstream skills (from gstack)
│   └── waza/                    <- second upstream (from tw93/Waza)
│       └── health/              <- Waza health audit (P2, read-only)
├── .claude/
│   ├── hooks/                   <- Claude Code hooks
│   │   └── post-commit-deploy.sh <- auto-deploys after git commit (P11)
│   ├── rules/                   <- path-scoped rules (activate per file context)
│   │   ├── upstream-skills.md   <- enforces P2 on skills/**
│   │   ├── upstreams.md         <- enforces P6 on upstreams/**
│   │   ├── custom-skills.md     <- P3 superseded, points to P6
│   │   ├── deployable-files.md  <- enforces P11 on settings/**
│   │   ├── work-items.md        <- rules for work item files
│   │   └── ...
│   └── commands/                <- project slash commands
│       └── deploy.md            <- /project:deploy
├── settings/                    <- permission baselines and overrides
├── docs/                        <- feature family doc triplets (PRD + ARCH + TEST-SPEC)
│   ├── align-feature-contract/
│   ├── infrastructure/
│   ├── system-health/
│   ├── test-align-contract/
│   ├── upstream-skills/
│   ├── work-pipeline/
│   ├── generated/               <- auto-generated reference docs (gen-docs.sh output)
│   └── inspections/             <- audit snapshots (auto-saved by /system-health)
├── CLAUDE.md                    <- this file
├── TODOS.md
├── README.md
└── .gitmodules                  <- submodule references
```

## Principles

- **P1: Single Source of Truth.** This repo owns what's shared. `~/.claude/` is a deployment.
- **P2: Upstream Skills Are Copies.** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **P3: Custom Skills Are Ours (SUPERSEDED).** Custom skills now live in claude-skills-templates repo, pinned via submodule at `upstreams/claude-skills-templates`. See P6.
- **P5: Always-On Over Invocation.** Rules and CLAUDE.md beat skills for enforcing standards.
- **P6: Version-Pinned Content.** `upstreams/` contains repos you own, pinned by submodule. Edit the source repo, then pull with `bash scripts/skills-pull.sh`. Unlike P2 (external upstreams), these are your own repos.
- **P11: Deploy or It Didn't Happen.** Committed-but-not-deployed is a bug. Post-commit hook auto-deploys.

## Rules

- **New machine setup:** `git clone --recurse-submodules <url>` then `bash scripts/deploy.sh`. Or if already cloned: `git submodule update --init && bash scripts/deploy.sh`.
- **Deploy after changes.** After editing deployable files (skills/, settings/, upstreams/), run `bash scripts/deploy.sh`. A post-commit hook runs it automatically.
- **Pull skill updates.** After editing skills in claude-skills-templates, run `bash scripts/skills-pull.sh` in home-setup to bump the submodule and auto-deploy.
- **Verify with /project:audit.** After any change, run `/project:audit` for unified health + governance check.
- **Upstream skills are copies, not forks (P2).** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **Custom skills live in claude-skills-templates (P6).** Edit in the source repo, pull with `bash scripts/skills-pull.sh`. Add to catalog + contracts when adding new skills.
- **Doc compiler.** After editing `audit-spec.json`, `skills-catalog.json`, or `skill-contracts.json`, run `bash scripts/gen-docs.sh`.
- **Contract validator.** After editing `skill-contracts.json`, run `bash scripts/validate-skill-contracts.sh`.
- **Templates are source of truth.** Current templates in `spec/templates/` are deployed to `~/.claude/spec/templates/`. Legacy templates in `templates/` still deploy to `~/.claude/templates/` for backward compat. After editing, run `bash scripts/deploy.sh`.
- **Work items are per-repo.** Work items live at `./work-items/` in each project repo, managed by the work-* skill family.

## Work Pipeline

Four-phase lifecycle for every work item: **Track -> Implement -> Review -> Ship**

- `/work` — Router: detects work item from branch, suggests the right phase skill
- `/work-track create` — Scaffold a new work item with manifest-driven artifacts
- `/work-implement` — Build (features) or debug (defects) with journal tracking
- `/work-review` — Code review with spec validation, delegates to gstack `/review`
- `/work-ship` — Ship with TEST-SPEC gates, delegates to gstack `/ship`
- `/work-track close` — Close a completed work item

Branch naming: `feature-*`, `feat-*`, `defect-*`, `fix-*`, `task-*`, `chore-*`, `story-*`, `review-*`

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
- System health, audit, governance -> invoke system-health
- Code quality, health check -> invoke health
- Work items, features, defects -> invoke work
- Doc quality review -> invoke system-health (with --layer docs)
