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

## Advisor Review — 2026-04-09 (all completed)

### ~~T2: Batch-fix systemic template gaps~~ (done 2026-04-09)
Added Success Metrics, Assumptions, Dependencies, Risk Assessment, missing AC blocks, P1/P2 story tiers, and API Changes sections across all 6 families.

### ~~T3: Update audit/ docs for current system~~ (done 2026-04-09)
Rewrote audit/ PRD, ARCHITECTURE, and TEST-SPEC to reflect current 4-stage pipeline (contract validation + smoke tests + alignment + drift).

### ~~T4: Remove dead file references~~ (done 2026-04-09)
Fixed refs to deleted PHILOSOPHY.md, stale governance-audit name, and brownfield-migrator TEST-SPEC E1.

### ~~T5: Set origin field on catalog entries~~ (done 2026-04-09)
Already correct — field is `source` not `origin`. 30 upstream have "gstack", 10 custom have "custom".

### ~~T6: Fix upstream-skills ARCH bin path~~ (done 2026-04-09)
Changed `skills/bin/*.sh` to `skills/bin/*` (extensionless executables).

### ~~T7: Align work-pipeline mental model~~ (done 2026-04-09)
Updated PRD Mental Model to describe 6 skills (router + 4 phases + audit).

### ~~T8: Commit and deploy~~ (done 2026-04-09)
Committed and deployed. Post-commit hook confirmed zero drift.
