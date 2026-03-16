# Codex Home Setup Summary

## What this home folder is for

This folder is not an application repo. It is the home-level Codex control layer.

- `~/AGENTS.md` holds small, always-loaded global rules.
- `~/.codex/config.toml` keeps runtime config minimal.
- `~/.codex/skills/` holds specialized workflows that load only when needed.
- `~/.codex/knowledge/` holds private global knowledge notes and checklists that should be read only when they clearly help.

The design goal is progressive disclosure:

1. Keep global context small.
2. Load specialized workflow guidance through skills.
3. Load deeper private global knowledge through on-demand notes, not through `~/AGENTS.md`.
4. Let each actual repo define its own build, test, architecture, safety rules, and repo-specific deep-dive docs.

## Best practices

- Keep `~/AGENTS.md` small, stable, and cross-repo only.
- Put reusable but low-frequency workflows in skills.
- Keep repo-specific commands, architecture, and safety rules in the repo, not in home-level files.
- Make verification explicit before calling work done.
- Preserve handoff priorities so session compaction does not lose the important state.
- Add more structure only when the project complexity actually needs it.

## Skill naming convention

- `lv0-home-*` is for home-level setup and control-layer logic, including guidance anchored by `home_setup_summary.md`.
- `lv1-workflow-*` is for reusable workflows that can apply across repos.
- `lv2-<repo>-*` is for rare repo-specific reusable workflows when repo docs alone are not enough.
- Keep normal repo commands, architecture, and safety rules in the repo `AGENTS.md` or repo docs even if a matching `lv2` skill exists.
- Current examples: `lv0-home-codex-health`, `lv0-home-shared-context`, `lv0-home-global-knowledge-capture`, `lv1-workflow-project-contract`, `lv1-workflow-repo-bootstrap`, `lv1-workflow-repo-knowledge-capture`, and `lv1-workflow-session-handoff`.

## Good practice for starting work in a local repo

For day-to-day work, follow the lightweight startup routine in [work-start-checklist.md](__HOME__/.codex/knowledge/work-start-checklist.md).
The idea is to load only the smallest useful contract first, then pull in deeper detail on demand.

## When the home knowledge folder helps

The home knowledge folder is useful if the content is:

- stable across multiple repos
- reused often
- too detailed for `~/AGENTS.md`

Good global examples:

- a glossary of shared terms
- a system map across services or repos
- recurring cross-repo architecture patterns
- common gotchas that show up in multiple repos

For repo-specific deep dives, keep the notes in the repo instead, ideally under repo-local AI docs such as `docs/ai/knowledge/` unless the repo contract already defines another location.
Avoid using home knowledge as the canonical place for repo commands, safety rules, or architecture requirements. Those belong in the repo. Home notes should stay global, point back to source docs when possible, and yield to repo truth if they diverge.

## Automation guidance

Automation is optional here.

Helpful uses:

- a weekly Codex health check
- a periodic reminder to review or prune skills
- a recurring handoff or cleanup review for long-running work

Not the best fix for forgetting skills during normal work. A better first step is a tiny routing reference near your home setup, because Codex reads instructions at the moment of work while automations run on a schedule.
If you want recurring reinforcement, use automation for periodic review rather than for every single edit.

## Recommended next improvements

- Keep `~/AGENTS.md` short.
- Keep home knowledge in `~/.codex/knowledge/` concise and on-demand.
- Prefer a small skill index over heavy automation for memory support.

## References

- Primary inspiration: [tw93/claude-health](https://github.com/tw93/claude-health)
- This home setup is a Codex-oriented adaptation of the same core ideas: small root contract, scoped instructions, reusable skills, and explicit verification.
