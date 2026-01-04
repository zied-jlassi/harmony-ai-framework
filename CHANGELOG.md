# Changelog

All notable changes to the Harmony Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Gaming specialty agents: game-ux, game-sound, game-narrative, game-qa
- Local overrides structure (.harmony/local/)
- Unified workflow-state.json schema

### Changed
- Standardized agent naming: removed `-agent` suffix from all agent `name:` fields
- Scrum Master tier: 3 → 2 (aligned with pipeline)
- Database agent: created `agents/database.md`

### Fixed
- Install script set -e compatibility
- CLAUDE.md template header
- Intent naming consistency (EXPLORE_QA)
- Pipeline orchestration: all agent references updated (no `-agent` suffix)
- Routing rules: all agent references updated
- Security manifest: agent file paths corrected
- Documentation: all `-agent` references updated

## [0.0.1] - 2025-01-04

### Added
- Initial release
- Core agents: Guardian, Sentinel, Developer, Analyst, Architect, SM, Tester
- HQVF (UCV system)
- Multi-IDE integration support (Claude Code, Cursor, Windsurf, Cody, Continue)
- Specialty packs: Gaming, Security, Quality, Compliance
- Harmony Sentinel memory system
- Guardian Protocol for intent routing
