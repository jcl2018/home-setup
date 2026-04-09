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
│   ├── validate-audit-spec.sh   <- validates audit-spec.json coverage closure
│   ├── validate-skill-contracts.sh <- validates skill-contracts.json schema + coverage
│   └── gen-docs.sh              <- doc compiler: generates traceability + skills ref
├── templates/                   <- doc templates (deployed to ~/.claude/templates/)
│   ├── PRD-TEMPLATE.md
│   ├── ARCHITECTURE-TEMPLATE.md
│   ├── TEST-SPEC-TEMPLATE.md
│   ├── TRACKER-TEMPLATE.md
│   ├── RCA-TEMPLATE.md
│   └── GENERATION-GUIDE.md
├── skills/                      <- upstream SKILL.md files (from gstack)
│   ├── bin/                     <- shell scripts some skills depend on
│   └── {name}/SKILL.md          <- one per upstream skill
├── .claude/
│   ├── skills/                  <- custom skills (authored here)
│   │   ├── work/                <- work item router (branch auto-detect + menu)
│   │   ├── work-track/          <- evidence synthesis, CRUD, lifecycle, scaffolding
│   │   ├── work-implement/      <- build-forward or debug-backward implementation
│   │   ├── work-review/         <- code review wrapper -> /review
│   │   ├── work-ship/           <- ship wrapper -> /ship
│   │   ├── work-audit/          <- unified doc quality check
│   │   ├── advisor/             <- L1 strategic + L2 operational quality review
│   │   ├── test-align-contract/ <- test harness for /align-feature-contract
│   │   ├── migrate/             <- brownfield design doc -> triplet converter
│   │   └── align-feature-contract/ <- doc triplet contract enforcement
│   ├── hooks/                   <- Claude Code hooks
│   │   └── post-commit-deploy.sh <- auto-deploys after git commit (P11)
│   ├── rules/                   <- path-scoped rules (activate per file context)
│   │   ├── upstream-skills.md   <- enforces P2 on skills/**
│   │   ├── custom-skills.md     <- enforces P3 on .claude/skills/**
│   │   ├── deployable-files.md  <- enforces P11 on knowledge/**, settings/**
│   │   ├── templates.md         <- enforces template read-only
│   │   ├── work-items.md        <- rules for work item files
│   │   └── ...
│   └── commands/                <- project slash commands
│       ├── deploy.md            <- /project:deploy
│       └── audit.md             <- /project:audit
├── knowledge/                   <- shared knowledge (deployed to ~/.claude/knowledge/)
│   ├── code-best-practices.md
│   └── INDEX.md
├── settings/                    <- permission baselines and overrides
├── docs/                        <- feature family doc triplets (PRD + ARCH + TEST-SPEC)
│   ├── infrastructure/
│   ├── upstream-skills/
│   ├── work-pipeline/
│   ├── audit/
│   ├── align-feature-contract/
│   ├── brownfield-migrator/
│   └── inspections/             <- audit snapshots (auto-saved by /project:audit)
├── CLAUDE.md                    <- this file
├── TODOS.md
└── README.md
```

## Principles

- **P1: Single Source of Truth.** This repo owns what's shared. `~/.claude/` is a deployment.
- **P2: Upstream Skills Are Copies.** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **P3: Custom Skills Are Ours.** `.claude/skills/` contains skills we authored. Add to catalog.
- **P5: Always-On Over Invocation.** Knowledge files beat skills for enforcing standards.
- **P11: Deploy or It Didn't Happen.** Committed-but-not-deployed is a bug. Post-commit hook auto-deploys.

## Rules

- **Deploy after changes.** After editing deployable files (knowledge/, skills/, settings/, .claude/skills/, templates/), run `bash scripts/deploy.sh`. A post-commit hook runs it automatically.
- **Verify with /project:audit.** After any change, run `/project:audit` for unified health + governance check.
- **Upstream skills are copies, not forks (P2).** Don't edit files in `skills/`. Re-copy from upstream on upgrade.
- **Custom skills live in .claude/skills/ (P3).** Add to catalog, add contract, update cheatsheet.
- **Doc compiler.** After editing `audit-spec.json`, `skills-catalog.json`, or `skill-contracts.json`, run `bash scripts/gen-docs.sh`.
- **Contract validator.** After editing `skill-contracts.json`, run `bash scripts/validate-skill-contracts.sh`.
- **Templates are source of truth.** Templates in `templates/` are deployed to `~/.claude/templates/`. After editing, run `bash scripts/deploy.sh`.
- **Work items are per-repo.** Work items live at `./work-items/` in each project repo, managed by the work-* skill family.

## Work Pipeline

Four-phase lifecycle for every work item: **Track -> Implement -> Review -> Ship**

- `/work` — Router: detects work item from branch, suggests the right phase skill
- `/work-track create` — Scaffold a new work item with manifest-driven artifacts
- `/work-implement` — Build (features) or debug (defects) with journal tracking
- `/work-review` — Code review with spec validation, delegates to gstack `/review`
- `/work-ship` — Ship with TEST-SPEC gates, delegates to gstack `/ship`
- `/work-audit` — Quality gate: tracking validation + /align-feature-contract + inline checks
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
- Code quality, health check -> invoke health
- Work items, features, defects -> invoke work
- Migrate design docs to triplets -> invoke migrate
- Doc quality review -> invoke advisor
