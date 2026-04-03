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
