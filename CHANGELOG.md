# Changelog

All notable changes to home-setup will be documented in this file.

## [0.0.2.0] - 2026-04-10

### Added
- docs/system-health/ triplet (PRD + ARCHITECTURE + TEST-SPEC) for the unified health dashboard
- docs/test-align-contract/ triplet for the doc triplet test harness
- docs/generated/ namespace for auto-built reference docs (traceability.md, skills-reference.md)
- Replaced skill detection in health-checks.sh via `replaces` field in skills-catalog.json
- docs/generated/README.md explaining what auto-generated docs are

### Changed
- docs/ restructured: 7 feature families + generated/ + inspections/ (was 6 dirs + 2 orphans)
- gen-docs.sh outputs to docs/generated/ instead of docs/design/ and docs/operations/
- test-gen-docs.sh and test-deploy.sh updated for new paths and live skills
- README.md documentation table updated, 5 broken links removed
- CLAUDE.md layout tree reflects new docs/ structure
- /work-audit references replaced with /system-health --scope across work-pipeline docs

### Removed
- docs/design/ and docs/operations/ (single-file orphan directories)
- docs/audit/ triplet (superseded by docs/system-health/)
- /advisor and /work-audit references from all owned files
- Dead advisor permissions from settings.local.json

## [0.0.1.0] - 2026-04-09

### Changed
- P5 principle now uses rules and CLAUDE.md for enforcement instead of knowledge files
- Deploy pipeline no longer syncs knowledge/ directory
- Infrastructure docs updated to reflect current deploy topology

### Removed
- knowledge/INDEX.md and knowledge/code-best-practices.md (enforcement moved to rules and CLAUDE.md)
- 4 knowledge-related audit checks (1.3, 4.1, 4.2, 4.4) from audit-spec.json
- Knowledge sync section from deploy.sh

### Fixed
- Deploy.sh now cleans up legacy ~/.claude/knowledge/ on upgraded machines
- Advisor inspection snapshot updated with current quality scores (avg 4.6/5.0)
- Infrastructure docs no longer reference deleted knowledge/ paths

### Added
- 4 new TODO items from advisor round 2 review (T9-T12)
- Generated design and operations documentation directories
