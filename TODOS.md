# TODOS

## T1: Auto-healing follow-up

**What:** Design auto-healing: detect drift -> explain which principle was violated -> repair automatically.

**Why:** This is the 10x differentiator over the work repo (which only reports). Codex identified it as the emotional center of the project during the /office-hours design session (2026-04-02).

**Context:** Requires the full detection infrastructure (L0-L5) to be in place. The governance framework now has 42 checks across 9 goals with automated deploy, doc compilation, and path-scoped rules. The missing piece is closing the loop: when /project:audit finds drift, auto-fix deterministic failures (missing files, checksum drift, stale upstream) without human intervention.

**Options to explore:**
- (a) Fix deterministic failures only (missing files, checksum drift)
- (b) Propose fixes for AI-review findings via PR
- (c) Scheduled cron that auto-heals + commits

**Depends on:** L5 completion (done). Design via /office-hours session.

**Created:** 2026-04-03

---

## Advisor Review — 2026-04-09 (all accepted)

### T2: Batch-fix systemic template gaps (P1, Effort: L)
Add Success Metrics, Assumptions, Dependencies, Risk Assessment, R-xxx requirement IDs, missing AC blocks, P1/P2 story tiers, and API Changes sections across all 6 doc triplet families (infrastructure, upstream-skills, work-pipeline, audit, align-feature-contract, brownfield-migrator).
**Source:** Advisor F1-F6

### T3: Update audit/ docs for current system (P1, Effort: M)
Rewrite audit/ ARCHITECTURE.md and TEST-SPEC.md to reflect that home-inspect and governance-audit skills were replaced. Current docs describe a system that no longer exists.
**Source:** Advisor F7

### T4: Remove dead file references (P1, Effort: S)
Fix references to deleted `docs/design/PHILOSOPHY.md` in infrastructure/ and brownfield-migrator/ docs. Fix stale "governance-audit" reference in align-feature-contract/ Out of Scope. Fix brownfield-migrator TEST-SPEC E1 that uses deleted file as test input.
**Source:** Advisor F8, F9, F12

### T5: Set origin field on catalog entries (P2, Effort: S)
All skills in skills-catalog.json have `origin: "unset"`. Tag each as "upstream" or "custom".
**Source:** Advisor F13

### T6: Fix upstream-skills ARCH bin path (P2, Effort: S)
ARCHITECTURE.md says `skills/bin/*.sh` but bin scripts are extensionless. Change to `skills/bin/*`.
**Source:** Advisor F10

### T7: Align work-pipeline mental model (P2, Effort: S)
PRD says "four phases" but ARCH describes 6 skills (router + 4 phases + audit). Reconcile the discrepancy in the PRD Mental Model section.
**Source:** Advisor F11

### T8: Commit and deploy (P1, Effort: S)
Commit all current changes and deploy to trigger P11 post-commit hook. Nothing is committed yet — docs, inspection snapshots, and all new files are uncommitted.
**Source:** Advisor F14
