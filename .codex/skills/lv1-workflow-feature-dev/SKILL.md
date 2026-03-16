---
name: lv1-workflow-feature-dev
description: Use when a local repo needs structured feature delivery for one or more feature items. Split multi-item work into separate item slugs, create or refresh a complete PRD for each item under the repo knowledge root, and maintain a detailed progress note for each item in `.local-work/feature/` while delivery is in flight.
---

# Feature Dev

Use this when the user wants to plan or implement one feature, a backlog slice, or a grouped set of feature items in a local repo and the work needs durable specs plus durable execution tracking.

## PRD

- Outcomes, checklist, and success criteria live in [../../knowledge/setup-prd/lv1-workflow-feature-dev.md](../../knowledge/setup-prd/lv1-workflow-feature-dev.md).

## Repo Setup

1. Read the nearest repo `AGENTS.md` and `.local-work/current.md`.
2. Identify the repo knowledge root from the repo contract. Default to `docs/ai/knowledge/` only when the repo does not define one.
3. Keep `.local-work/current.md` as the required repo-level session tracker. Feature-specific tracking complements it instead of replacing it.
4. Respect an existing repo feature-doc convention when the repo already has one. Otherwise use the default pair:
   - PRD: `<repo-knowledge-root>/features/<slug>.md`
   - progress doc: `.local-work/feature/<slug>.md`
5. If the repo uses a non-default feature-doc path or tracker path, make sure that mapping is documented in repo-local docs or `AGENTS.md` so future audits can verify it.

## Split Multi-Item Requests

- Break grouped requests into the smallest shippable feature items that still have coherent acceptance criteria.
- Give every item a stable slug and reuse it across the PRD, the progress note, branch notes, and verification entries.
- Do not merge unrelated items into one PRD just because they were requested together.
- Capture dependencies between items inside each PRD so sequencing stays explicit.

## Required Docs Per Item

Every feature item needs both documents:

- a complete PRD
- a detailed progress note

Also keep `.local-work/current.md` updated with short links or references to the currently active feature items so repo-level resumes still start from the required tracking doc.

### Complete PRD

Use [references/feature-prd-template.md](references/feature-prd-template.md) as the starting shape.

Each item PRD should cover:

- title and slug
- status
- summary and problem statement
- affected users, workflows, or surfaces
- in-scope and out-of-scope boundaries
- functional requirements
- non-functional requirements when they matter
- UX, API, data, or migration notes as applicable
- dependencies, risks, and open questions
- acceptance criteria
- verification plan
- related sources and last-updated date

### Detailed Progress Note

Use [references/feature-progress-template.md](references/feature-progress-template.md) as the starting shape.

Each progress note should capture:

- the linked PRD path
- current status
- the current implementation slice
- completed work
- next planned work
- decisions made during development
- files touched
- exact verification commands and outcomes
- blockers or open questions

Refresh the progress note after material changes to scope, status, files touched, verification, blockers, or next steps.

## Delivery Loop

1. Normalize the request into feature items and slugs.
2. Create or refresh the PRD for each item before coding.
3. Create or refresh `.local-work/feature/<slug>.md` for each active item before substantive implementation.
4. Implement one slice at a time and update the matching progress note as the slice lands.
5. If the accepted scope changes, update the PRD and the progress note together.
6. Run the smallest relevant verification for the slice and record the exact commands in the feature note and the repo-level `.local-work/current.md`.
7. When the item is done, leave the progress note in a resumable done state rather than deleting it.

## Audit Convention

- Repo audits should be able to prove that every feature PRD has a matching tracker note.
- For the default convention, `<repo-knowledge-root>/features/<slug>.md` maps to `.local-work/feature/<slug>.md`.
- For repo-specific conventions, keep the mapping documented so audits can verify the equivalent pair.
- A missing tracker for a feature PRD is structural drift because future sessions lose the execution history needed to resume or review the work.

## Optional Repo Hygiene

- When a repo accumulates multiple feature PRDs, add `<repo-knowledge-root>/features/INDEX.md` if navigation starts getting noisy.
- Reconcile old one-off planning docs into the feature PRD set when they overlap, instead of letting multiple sources of truth drift.
