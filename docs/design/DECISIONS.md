# Decision Journal

Themed entries tracing design decisions to the events that caused them.
Each entry links to the principle it informed in [PHILOSOPHY.md](PHILOSOPHY.md).

---

## Scope & Direction

### D1: Reversed Visibility-Over-Automation Stance

**Event:** The original PHILOSOPHY.md said "visibility over automation" and listed deploy automation, health checks, and drift detection as Non-Goals. The governance stack migration (2026-04-02) introduced P11 (deploy or it didn't happen) with a post-commit hook that auto-deploys.

**Lesson:** The simpler repo was right to prefer visibility. But a governance framework that verifies its own coherence needs deploy-by-construction to eliminate drift. The old stance was correct for a flat config repo. The governed repo needs automation.

**Principle:** -> [P11: Changes Deploy or They Didn't Happen](PHILOSOPHY.md#p11-changes-deploy-or-they-didnt-happen)

### D2: Scope Pivot From Multi-Machine to Personal-Mac-Primary

**Event:** The original repo promised "any machine, including a restricted work Windows box, can reconstruct a complete Claude Code setup." The governance migration (2026-04-02) changed scope to personal-mac-primary with a governance reference implementation for the AI tooling community.

**Lesson:** Multi-machine reconstruction was the right goal when the work machine couldn't install gstack. Now each machine has its own home-setup repo adapted for its constraints. The work machine has its own repo with Copilot parity, domain corpora, and corporate network adaptations. This repo is the governed reference implementation, not a portable installer.

**Principle:** -> [P1: Single Source of Truth](PHILOSOPHY.md#p1-single-source-of-truth) (scope narrowed to personal mac)

---

## Repo Architecture

### D3: Repo Not Fork

**Event:** Considered forking gstack skills to customize them. Realized forks create merge conflicts on every upstream upgrade.

**Lesson:** Direct copies with a clean overwrite on upgrade are simpler than maintaining a fork. This repo is a distribution mirror for skills, not a fork.

**Principle:** -> [P1](PHILOSOPHY.md#p1-single-source-of-truth), [P2](PHILOSOPHY.md#p2-upstream-skills-are-copies-not-forks)

### D4: Harness Internal Split Is Binary

**Event:** Had three categories of skills and conversations kept getting confused about which was which.

**Lesson:** A skill is either a harness (you type it directly) or internal (called by other skills). No third category.

**Principle:** -> [P3](PHILOSOPHY.md#p3-custom-skills-are-ours)

---

## Knowledge System

### D5: Knowledge Files Beat Skills for Always-On Standards

**Event:** Created `code-best-practices.md` as a knowledge file instead of a skill. It immediately applied to every repo without invoking anything.

**Lesson:** For standards that should always apply, always-on knowledge files win over invocation-based skills.

**Principle:** -> [P5](PHILOSOPHY.md#p5-always-on-over-invocation)

### D6: Knowledge Needs No Wiring

**Event:** Added knowledge files and expected to wire them into individual skills. Realized the `~/.claude/CLAUDE.md` preamble loads them globally.

**Lesson:** Knowledge files don't need explicit wiring. The preamble handles global loading.

**Principle:** -> [P5](PHILOSOPHY.md#p5-always-on-over-invocation)

---

## Maintenance & Verification

### D7: Deploy or It Didn't Happen

**Event:** Consolidated knowledge files, committed to the repo, and closed the session. Next session found `~/.claude/knowledge/` still had the old files. The new file was never copied over.

**Lesson:** Verification catches drift, but prevention is better. A deploy script that runs after changes ensures sync by construction.

**Principle:** -> [P11](PHILOSOPHY.md#p11-changes-deploy-or-they-didnt-happen)

### D8: Audit Goal Traceability

**Event:** The audit system had checks but no way to answer "why does this check exist?" or "which goal does it serve?"

**Lesson:** `audit-spec.json` maps every check to goals with a `why` field. A validator ensures coverage closure. A path-scoped rule reminds to update the spec when checks change.

**Principle:** Reinforces [P1](PHILOSOPHY.md#p1-single-source-of-truth)

---

## Documentation

### D9: No Hardcoded Counts

**Event:** PHILOSOPHY.md said "9 harness, 11 internal" while the actual count had changed. Audit caught it.

**Lesson:** Hardcoded counts drift the moment a skill is added. Reference `skills-catalog.json` as the source of truth.

**Principle:** Enforced via path-scoped rule `no-hardcoded-counts.md`

### D10: Docs Have Clear Lanes

**Event:** CLAUDE.md, PHILOSOPHY.md, and README.md had overlapping content.

**Lesson:** When two docs cover the same topic, one drifts. Assigning each doc a single job with a lanes table prevents content migration.

**Principle:** Enforced via lanes table in PHILOSOPHY.md and path-scoped rule `doc-lanes.md`

---

## Contextual Guardrails

### D11: Path-Scoped Rules, Project Commands, and Deny Lists

**Event:** Compared setup against "Anatomy of the .claude/ Folder" blog post. Found gaps: no path-scoped rules, no project commands, no deny list.

**Lesson:** Path-scoped rules in `.claude/rules/` activate contextually when Claude touches matching files, reinforcing principles at the moment they matter most. Project commands provide lightweight workflows without full skills.

**Principle:** Reinforces [P2](PHILOSOPHY.md#p2-upstream-skills-are-copies-not-forks), [P3](PHILOSOPHY.md#p3-custom-skills-are-ours), [P11](PHILOSOPHY.md#p11-changes-deploy-or-they-didnt-happen)

---

## Archived Principles

These were active principles that were either absorbed into other principles or enforced via rules/scripts instead.

- **P4** (skill taxonomy) -> absorbed into P3
- **P6** (no hardcoded counts) -> enforced via rule `no-hardcoded-counts.md`
- **P7** (doc lanes) -> enforced via rule `doc-lanes.md`
- **P8** (citation rule) -> enforced via `~/.claude/CLAUDE.md` preamble
- **P9** (N/A skills stay on disk) -> dropped (personal mac owns upstream, no N/A skills)
- **P10** (verification) -> absorbed into P11 (deploy prevents what verification detects)
- **P12** (harness-neutral work items) -> dropped (personal mac is Claude Code only, see D2)
