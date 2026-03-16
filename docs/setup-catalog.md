# Setup Catalog

This is the current reference snapshot of the portable shared Codex layer plus the Unix/mac-specific helpers that still live in this repo. The installer and audit scripts read `config/reference-paths.tsv` so the Windows and Unix/mac flows stay aligned.

## Portable Shared Codex Files

- `AGENTS.md`
  The small global Codex contract for all repos.
- `.codex/config.toml`
  Minimal Codex runtime defaults.
- `.codex/home_setup_summary.md`
  Short explanation of the home setup philosophy.

## Portable Knowledge Notes

- `.codex/knowledge/work-start-checklist.md`
  Lightweight reminder for how to begin substantial work.
- `.codex/knowledge/global/INDEX.md`
  Entry point for cross-repo knowledge notes.
- `.codex/knowledge/global/common-gotchas.md`
  Template starter for recurring pitfalls across repos.
- `.codex/knowledge/global/glossary.md`
  Template starter for shared terms.
- `.codex/knowledge/global/shared-services.md`
  Template starter for shared services or reusable platforms.
- `.codex/knowledge/global/system-map.md`
  Template starter for cross-repo system relationships.

The global note files are currently mostly starter templates. That is intentional: they are part of the structure even when lightly populated.

## Portable Custom Skills

- `lv0-home-codex-health`
  Audits home or repo Codex setup for drift, context cost, and verification gaps.
- `lv0-home-global-knowledge-capture`
  Saves or refreshes stable cross-repo knowledge under `~/.codex/knowledge/global`.
- `lv0-home-shared-context`
  Loads the smallest relevant saved knowledge note instead of searching broadly.
- `lv1-workflow-project-contract`
  Creates or tightens a repo `AGENTS.md`.
- `lv1-workflow-repo-bootstrap`
  Onboards an existing repo or scaffolds a new one for reliable Codex work.
- `lv1-workflow-repo-knowledge-capture`
  Saves reusable repo-specific deep dives inside the repo.
- `lv1-workflow-session-handoff`
  Writes short handoff notes for unfinished work.

These live in `templates/.codex/skills/` and are treated as part of the shared reference model. The skill directories also include supporting `references/` and `agents/` files that the installers carry along with each skill.

## Optional Portable Automation

- `weekly-codex-health`
  A weekly Sunday 9:00 local-time automation that runs the home Codex health audit against the home setup.

The automation lives at `templates/.codex/automations/weekly-codex-health/automation.toml`. It is part of the reference model, but optional on each machine.

## Unix/mac Reference-Only Files

- `.gitconfig`
  Minimal shared Git defaults for Unix/mac machines.
- `.zprofile`
  Homebrew shell bootstrap plus a hook for `~/.config/home-setup/secrets.zsh`.
- `.config/home-setup/secrets.zsh.example`
  Example local secrets file for Unix-style shell setup.

These are installed by `scripts/install.sh` and checked by `scripts/audit-home.sh`, but they are intentionally skipped by the Windows duplication flow.

## Visible Environment-Provided Skills

- `openai-docs`
  Helps with official OpenAI product and API documentation workflows.
- `skill-creator`
  Helps create new Codex skills.
- `skill-installer`
  Helps install Codex skills from curated sources or repos.

These are visible in the current Codex environment under `.codex/skills/.system/`, but they are not managed by this repo and should not be copied into the reference export.

## Local-Only Pieces Not Owned By This Repo

- `~/.config/home-setup/secrets.zsh`
  Machine-local environment overrides and secrets.
- `~/.codex/auth.json`
  Local Codex sign-in state.
- `~/.codex/logs_*.sqlite*`, `~/.codex/state_*.sqlite*`
  Local runtime databases.
- `~/.codex/models_cache.json`, `~/.codex/sessions`, `~/.codex/shell_snapshots`
  Local caches and session state.

These may exist on the reference machine, but they are intentionally excluded from this repo.
