# Global Knowledge Index

- Scope: private cross-repo knowledge that is stable enough to reuse.
- When to use this note: when a task depends on shared terminology, system relationships, or recurring patterns across repos.
- Source files or docs: add paths or doc links as notes are filled in.
- Last checked: 2026-03-15

## Notes

- `glossary.md`: template for shared terms, abbreviations, and naming conventions.
- `system-map.md`: template for high-level relationships between repos, services, and data flow.
- `shared-services.md`: template for reusable shared components, platforms, or backend services.
- `common-gotchas.md`: template for recurring pitfalls that show up across repos.

## Boundaries

- Keep this directory focused on shared cross-repo knowledge.
- Move repo-specific deep dives into the repo's local knowledge docs, preferably `docs/ai/knowledge/`.
- If repo code or docs disagree with a summary here, the repo wins.
