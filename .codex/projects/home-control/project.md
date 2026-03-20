# home-control

- Status: active
- Scope: Codex home reset isolated from `~/.claude`
- Active roots: `~/AGENTS.md`, `~/.codex/skills/`, `~/.codex/bin/`, `~/.codex/docs/`, `~/.codex/projects/`, `~/.codex/guardrails/`, `~/.codex/automations/`
- Default workflow: `office-hours -> plan-ceo-review -> plan-eng-review -> plan-design-review -> investigate or repo work -> review -> qa or qa-only -> ship -> document-release -> retro`
- Claude boundary: never edit `~/.claude` unless the user explicitly asks
- Verification: `codex-skill-check`, `codex-home-health`, `codex-project-log`, `codex-review-readiness`, `codex-guardrails`, and `codex-home-export` all ran during the reset
- Mirror: `~/Documents/projects/home-setup` contains the post-reset export snapshot
- Current framing: the setup is now a Codex-native gstack adaptation with shared design artifacts, safety/export guardrails, optional `design-consultation` and `design-review` satellites, and a richer readiness dashboard across planning, review, QA, and ship
- Planning flow: `office-hours`, `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, and `design-consultation` now work from the same durable design source of truth and use closer Claude-gstack handoff language
- Execution flow: `design-review`, `review`, `qa`, `ship`, `document-release`, `retro`, and the safety skills now center more of their workflow around readiness state and explicit stage outcomes while remaining Codex-native
