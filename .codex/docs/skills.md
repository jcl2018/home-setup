# Codex Skill Catalog

The Codex home layer now follows a direct gstack-style stage model adapted for Codex.

## Workflow

`office-hours -> plan-ceo-review -> plan-eng-review -> plan-design-review -> investigate or repo work -> review -> qa or qa-only -> ship -> document-release -> retro`

## Active Skills

| Skill | Role | Main output |
| --- | --- | --- |
| `office-hours` | YC-style office hours with startup and builder modes | approved `designs/` artifact |
| `plan-ceo-review` | Founder-mode scope and ambition review | updated design artifact |
| `plan-eng-review` | Engineering-manager architecture and test review | updated design artifact |
| `plan-design-review` | UX and interaction-state review pass | updated design artifact |
| `design-consultation` | Create or reset the visual system before code | updated design artifact |
| `investigate` | Root-cause-first debugging with evidence capture | `reviews/` artifact |
| `design-review` | Rendered-state visual audit and optional fix loop | `reviews/` artifact plus readiness log |
| `review` | Findings-first pre-landing diff review with readiness status | `reviews/` artifact plus readiness log |
| `qa` | Tiered test-fix-verify loop | `qa/` artifact plus readiness log |
| `qa-only` | Test and report only | `qa/` artifact |
| `ship` | Release workflow with gates and final readiness | `ship/` artifact plus readiness log |
| `document-release` | Conservative post-ship doc sync | `ship/` artifact |
| `retro` | Team-aware engineering retrospective | `retro/` artifact |
| `careful` | Destructive-command warning mode with manual checks | `guardrails/current.toml` |
| `freeze` | Edit-boundary mode with manual path checks | `guardrails/current.toml` |
| `guard` | Careful + freeze together | `guardrails/current.toml` |
| `unfreeze` | Clear the active guardrail boundary | `guardrails/current.toml` |
| `home-health` | Audit the Codex home layout | console findings |
| `home-export` | Mirror the live Codex home | local git mirror update |

## Notes

- `~/.claude` is intentionally outside this workflow.
- Repo-specific instructions still belong in each repo's own `AGENTS.md`.
- The project store is the default durable state layer; the old `.local-work` and PRD setup is retired.
- `office-hours`, the plan-review skills, and `design-consultation` all work from the same design artifact in `designs/`.
- `design-review`, `review`, `qa`, and `ship` share a readiness ledger via `~/.codex/bin/codex-review-readiness`.
- Shared operating stance: boil the lake when the remaining work is bounded, prefer complete coverage over convenient shortcuts, and close workflow stages with `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, or `NEEDS_CONTEXT`.
- Some Claude-only gstack capabilities are adapted rather than mirrored directly: Codex prefers repo-native browser tooling over `/browse`, and uses the local project store plus readiness dashboard instead of Claude's `~/.gstack` runtime.
