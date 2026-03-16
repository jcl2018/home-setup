# Lv0 Home Shared Context PRD

## Purpose

Define how cached knowledge is loaded on demand, with special handling for home/workflow PRDs and repo-local `lv2` skill PRDs.

## Desired State

- Shared context starts with the smallest matching note set instead of broad knowledge loading.
- Home or workflow contract questions begin with `~/.codex/knowledge/setup-prd/INDEX.md`.
- Cross-repo concept questions can begin with `~/.codex/knowledge/INDEX.md` or a smaller matching note.
- Repo-local questions begin with the repo knowledge root and consult `<repo-knowledge-root>/setup-prd/INDEX.md` when `lv2` skills or repo workflow contracts are relevant.
- Cached notes stay subordinate to repo truth and live code.

## Audit Checklist

- The skill distinguishes home/workflow PRDs from general shared-context notes.
- It does not force-load broad home knowledge for narrow repo tasks.
- It checks repo-local PRDs when the task is about a repo `lv2` workflow.
- It avoids writing new notes; capture flows stay in the capture skills.

## Success Criteria

- The right note loads quickly without unnecessary context cost.
- Users can find the home or repo contract note they need without guessing.

## Out of Scope

- Saving or restructuring knowledge notes.
- Treating cached notes as more authoritative than repo code or docs.

## Related Sources

- `~/.codex/skills/lv0-home-shared-context/SKILL.md`
- `~/.codex/knowledge/INDEX.md`
- `~/.codex/knowledge/setup-prd/INDEX.md`

## Last Checked

- 2026-03-15
