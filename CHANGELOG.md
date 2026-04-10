# Changelog

All notable changes to home-setup will be documented in this file.

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
