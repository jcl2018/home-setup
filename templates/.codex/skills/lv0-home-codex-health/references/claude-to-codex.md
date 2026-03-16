# Claude To Codex Translation

This reference adapts the six-layer Claude guidance from `tw93/claude-health` and the accompanying article/PDF into Codex-friendly defaults.

## Core principles

1. Keep the always-loaded contract small.
2. Put reusable workflows in skills, not in the root contract.
3. Keep skill descriptions short and explicit about when to use them.
4. Use progressive disclosure:
   - skill metadata is always visible
   - `SKILL.md` loads on trigger
   - references and scripts load only when needed
5. Make verification explicit before calling work done.
6. Preserve compacting and handoff priorities so context compression does not lose the important state.
7. Avoid duplicate rules across global and repo scope.

## Layer mapping

| Claude guidance | Codex translation |
| --- | --- |
| Global `CLAUDE.md` | `~/AGENTS.md` |
| Repo `CLAUDE.md` | repo `AGENTS.md` |
| `rules/` | nested `AGENTS.md` at real module boundaries, or repo docs such as `docs/ai/*.md` linked from `AGENTS.md` |
| `skills/` | `~/.codex/skills` |
| hooks | repo verification commands, CI, or other real automation only if Codex actually supports it in context |
| subagents | use Codex subagents when available, otherwise use narrower skills and tighter prompts |
| verifiers | repo build, test, lint, typecheck, screenshot, and smoke-test commands |

## Root contract guidance

Keep `AGENTS.md` focused on:

- build and test commands
- architecture boundaries
- repo-specific safety rails
- verification rules
- compacting or handoff priorities

Do not fill the root contract with:

- long background prose
- detailed examples better suited for docs
- low-frequency workflows that belong in skills
- duplicate rules already covered by a more local `AGENTS.md`

## Skill guidance

Use skills for workflows that are:

- reusable
- easy to trigger with a clear description
- too detailed to keep in `AGENTS.md`
- low-frequency or specialized

Good patterns:

- put the core workflow in `SKILL.md`
- move long detail into `references/`
- use `scripts/` for deterministic helper commands
- keep the body concise and operational

Avoid:

- broad descriptions such as "help with backend"
- giant `SKILL.md` files that duplicate reference material
- multiple skills with overlapping purpose

## Verification and compacting

Before marking work done:

- run the smallest relevant verification
- report command plus pass or fail
- call out what was not verified

When compressing or handing off, preserve:

1. architecture decisions
2. changed files and why
3. verification status
4. open risks, TODOs, and rollback notes
5. only the important result from tool output

## Practical heuristics

- Prefer one lean home `AGENTS.md` over a giant global playbook.
- Prefer a small number of high-signal home skills over many vague ones.
- Split repo detail into linked docs once the root contract starts feeling crowded.
- Use nested `AGENTS.md` only when a directory truly has its own rules.
