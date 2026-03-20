# Codex Setup Review

## What This Setup Actually Is

This is not yet a full gstack-equivalent operating system.

It is a clean, coherent Codex workflow shell:

- the stage names are clear
- the home roots are well-bounded
- the project store works
- readiness logging works
- guardrails work
- export and health checks work
- Claude is isolated

That is real progress. But the system is still much stronger at structure than at stage intelligence.

## Evidence

- `~/AGENTS.md` defines a single direct workflow with no legacy routing left active.
- `~/.codex/skills/` contains only the direct stage skills plus guardrail and maintenance skills.
- `~/.codex/projects/home-control/` exists and has working `designs/`, `reviews/`, `qa/`, and `ship/` artifacts.
- `~/.codex/bin/` has working helpers for slugging, project logging, readiness, guardrails, health, and export.
- `codex-skill-check` and `codex-home-health` both pass.

## The Biggest Gaps

### 1. Stage skills are thin

The system knows where each stage should write, but many stage skills are still only light wrappers.

Representative examples:

- `review` says to inspect scope drift and correctness risks, but it does not yet carry a rich review checklist or a repeatable diff protocol.
- `qa` says to use repo-native tooling, but it does not yet define concrete fallback behavior, bug triage thresholds, or artifact structure.
- `ship` logs release readiness, but it does not yet encode the hard decisions that make shipping reliable.

This means the setup is currently a workflow router more than a deep operating system.

### 2. Repo onboarding got weaker

The reset removed the old repo bootstrap and project-contract layer entirely.

That simplified the home surface, but it also means there is no active home-level skill helping Codex bring a repo into this new system. The setup is good at governing the home layer and weaker at spreading the workflow into fresh repos.

### 3. There is not much real usage yet

The project store currently shows mostly smoke-test artifacts for `home-control`.

That means the system is structurally verified, but not yet validated by repeated real project usage.

## Status Quo Versus Wedge

If the goal is "have a clean Codex home", you already have it.

If the goal is "have a Codex-native gstack replacement that changes how work gets done", you do not have that yet.

The narrowest wedge is not adding more stages. The wedge is deepening one path until it becomes obviously better than your old setup.

## Recommended Next Step

Deepen the execution path first:

`review -> qa -> ship`

Why this wedge:

- it is the shortest path to behavior change
- it produces visible artifacts and readiness state
- it forces the system to interact with real repos, diffs, and verification
- once this path is strong, the planning stages become more valuable because they feed a real downstream pipeline

## Concrete Follow-Up

Turn `review`, `qa`, and `ship` from stage wrappers into real playbooks:

- add explicit checklists and default decisions
- define required artifact sections
- define repo-detection and fallback behavior
- define what blocks readiness and what is informational
- add one or two real-project trial runs to replace smoke-test-only confidence
