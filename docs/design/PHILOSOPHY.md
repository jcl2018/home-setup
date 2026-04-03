# Philosophy

Five active design principles for this repo. Each has a rationale and a Claude directive.
Decision entries in [DECISIONS.md](DECISIONS.md) trace the events that shaped these principles.

---

## P1: Single Source of Truth

This repo owns what's shared. The installed `~/.claude/` directory is a deployment.

**Rationale:** One repo plus `/project:audit` eliminates configuration drift. The repo owns what's shared, the audit shows what's different, you decide what to fix.

**Claude directive:** When suggesting changes to skills, knowledge, or settings, always edit the repo files, never edit `~/.claude/` directly.

**Informed by:** [D3](DECISIONS.md#d3-repo-not-fork)

---

## P2: Upstream Skills Are Copies, Not Forks

Skills in `skills/` come from [gstack](https://github.com/garrytan/gstack). They are direct copies, do not edit them here.

**Rationale:** Forking upstream skills creates merge conflicts on every upgrade. Copying means upgrades are a clean overwrite: re-copy the SKILL.md files, bump the version in `skills-catalog.json`, run `/project:audit`.

**Claude directive:** Never modify files in `skills/`. If a skill needs customization, create a wrapper in `.claude/skills/` instead.

**Informed by:** [D3](DECISIONS.md#d3-repo-not-fork)

---

## P3: Custom Skills Are Ours

Skills in `.claude/skills/` are authored in this repo. They don't exist upstream.

**Rationale:** Custom skills fill gaps that upstream doesn't cover: machine-specific inspections, governance auditing. Each is listed in `skills-catalog.json` with `"source": "custom"`.

**Claude directive:** When creating a new skill, put it in `.claude/skills/`, add it to `skills-catalog.json` with `"source": "custom"`, and update the cheatsheet.

**Informed by:** [D4](DECISIONS.md#d4-harness-internal-split-is-binary)

---

## P5: Always-On Over Invocation

Knowledge files are better than skills for enforcing standards. They're always-on across all repos without invoking anything.

**Rationale:** A knowledge file loaded via `~/.claude/CLAUDE.md` applies to every session in every repo automatically. A skill only applies when someone remembers to invoke it. For standards that should always be followed, always-on wins.

**Claude directive:** When a standard should apply everywhere, put it in `knowledge/` and index it, don't create a skill for it.

**Informed by:** [D5](DECISIONS.md#d5-knowledge-files-beat-skills)

---

## P11: Changes Deploy or They Didn't Happen

A repo change that isn't deployed to `~/.claude/` is not done. Deploy runs automatically via a post-commit hook, and can be triggered manually with `bash scripts/deploy.sh`.

**Rationale:** P1 says the repo owns what's shared. But nothing forced changes to actually land in `~/.claude/`. A deploy script plus a post-commit hook ensures the repo and installed state stay in sync by construction, not by audit.

**Claude directive:** After editing any deployable file (knowledge/, skills/, settings/, .claude/skills/), run `bash scripts/deploy.sh` before or immediately after committing. If the user is about to end a session with uncommitted deploy-worthy changes, remind them.

**Informed by:** [D7](DECISIONS.md#d7-deploy-or-it-didnt-happen)

---

## Audit Goals

Nine goals (AG1-AG9) define why each audit check exists. Every check maps to at least one goal, enforced by `audit-spec.json` and `scripts/validate-audit-spec.sh`.

### AG1: Repo-Home Sync

The repo is the source of truth (P1). The installed `~/.claude/` directory is a deployment. If they disagree, something broke.

**Type:** check-level | **Informed by:** P1, P11

### AG2: Functional Correctness

A skill file that exists on disk but has a missing dependency or a rule with an invalid glob is broken in practice even if it looks fine on paper.

**Type:** check-level | **Informed by:** P3

### AG3: Principle Alignment

The system has 5 active design principles (P1, P2, P3, P5, P11). Skills, commands, rules, and docs should follow them.

**Type:** check-level | **Informed by:** P1, P2, P3

### AG4: Doc Currency

Docs should describe the current state, not a past state. Catches stale content: broken links, layout trees that don't match disk, factual claims that no longer hold.

**Type:** check-level | **Informed by:** P1

### AG5: Doc Quality

Docs should be well-written, stay in their lanes, follow writing standards, and accurately summarize their subject.

**Type:** check-level | **Informed by:** P5

### AG6: Usefulness & No Overlap

Every skill, rule, and command should serve a distinct purpose. Overlap means wasted maintenance and user confusion.

**Type:** check-level | **Informed by:** P3

### AG7: Proactive Improvement

Most audit checks answer "is this broken?" AG7 checks answer "could this be better?" Surfaces improvement opportunities: upstream upgrades available, stale TODOs, new patterns worth adopting.

**Type:** advisory | **Informed by:** --

### AG8: Inspection Reporting

The audit itself must be a good report. List what was checked, why each check exists, what the results were, and save a snapshot for trending.

**Type:** meta (exempt from "must have checks" validation) | **Informed by:** --

### AG9: Operational Hygiene

Home directories accumulate debris: stale session files, temp files, oversized logs, empty directories. None are "broken" but they waste disk and indicate incomplete cleanup.

**Type:** hygiene | **Informed by:** P1

### Goal Taxonomy

| Type | Validation rule | Goals |
|------|----------------|-------|
| check-level | Must have at least one check | AG1-AG6 |
| advisory | Must have at least one check | AG7 |
| meta | Exempt from check requirement | AG8 |
| hygiene | Must have at least one check | AG9 |

### Coverage

See `audit-spec.json` for the full check-to-goal mapping. Run `bash scripts/validate-audit-spec.sh` to verify coverage closure.

---

## Doc Lanes Reference

Each doc has one job. No redundancy between them.

| Doc | Tier | Job | Owns |
|-----|------|-----|------|
| **CLAUDE.md** (root) | -- | Contract for Claude | Layout, rules, machine config |
| **README.md** (root) | -- | Landing page | Orientation, links to both tiers |
| **docs/design/PHILOSOPHY.md** | Design | Principles + audit goals | Active principles, AG1-AG9, doc lanes |
| **docs/design/DECISIONS.md** | Design | Decision journal | Themed entries tracing events to lessons |
| **docs/design/traceability.md** | Design | Traceability map | AUTO-GENERATED: principle->goal->check |
| **docs/operations/SKILLS-CHEATSHEET.md** | Ops | Quick reference | Skill commands to type |
| **docs/operations/COMMANDS-AND-RULES.md** | Ops | Commands & rules | Project commands and path-scoped rules |
| **docs/operations/INSPECTION-BASELINE.md** | Ops | Known-good snapshot | Room descriptions, remediation, file inventory |
| **docs/operations/skills-reference.md** | Ops | Skill catalog table | AUTO-GENERATED: catalog-derived reference |
| **docs/operations/getting-started.md** | Ops | Onboarding guide | 5-minute setup for new users |

---

## Maintenance

After an upstream upgrade (consequence of P2):

1. Re-copy SKILL.md files into `skills/`
2. Re-copy shell scripts into `skills/bin/`
3. Bump the version in `skills-catalog.json`
4. Run `bash scripts/deploy.sh`
5. Run `/project:audit` to verify
6. Commit
