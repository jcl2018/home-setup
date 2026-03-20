---
name: retro
description: Retrospective workflow. Use after a meaningful delivery cycle to capture what worked, what broke, who shipped what, and what should change.
---

# Retro

Use this after shipping or after a costly incident.

## Windows

Default to the last 7 days unless the user gives a different window such as `24h`, `14d`, `30d`, or `compare`.

## Data To Gather

Collect enough repo history to answer:

- what shipped
- who contributed
- where hotspots appeared
- what the test ratio looked like
- whether there were repeated fix loops or unstable areas

When the repo supports it, gather commit stats, file hotspots, PR references, and per-author summaries.

## Output Style

This should feel like an engineering retrospective, not a changelog dump.

- include summary metrics
- include concrete praise
- include one constructive growth opportunity per person or for the system
- name themes and risks, not just raw numbers

Use [references/retro-template.md](references/retro-template.md) as the artifact shape.

## Workflow

1. Ensure the project store exists with `~/.codex/bin/codex-project-log ensure`.
2. Create a retro artifact path with `~/.codex/bin/codex-project-log stamp retro retro`.
3. Gather the raw data for the selected time window.
4. Compute the summary metrics and contribution patterns.
5. Write the praise, growth opportunities, themes, and next actions.
6. Keep the retro specific and evidence-based.

## Output

- A retrospective note under `retro/`
- Actionable follow-up items
