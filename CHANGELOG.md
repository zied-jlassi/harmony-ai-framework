# Changelog

All notable changes to the Harmony Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.20] - 2026-01-05

### Fixed
- **Install script SCRIPT_DIR resolution**: Added robust validation with fallback methods
  - Validates `harmony.manifest.json` exists at resolved path
  - Tries alternative resolution methods (`dirname $0`, `BASH_SOURCE`)
  - Fails explicitly with clear error message if source directory cannot be found
- **Install script diagnostics**: Added source/target/IDE display after prerequisites check
- **Essential files copy**: Changed from warnings to fatal errors when essential files missing
  - Shows exact expected path for missing files
  - Aborts installation immediately instead of continuing with incomplete setup
  - Double-checks `harmony.manifest.json` was copied successfully

## [1.0.19] - 2026-01-05

### Changed
- **Command Format Optimization**: Compact YAML frontmatter for all slash commands
  - Format: `name` + `description` fields mandatory
  - All paths use `${HARMONY_DIR}` variable instead of `.harmony`
  - Reduced ~100 lines in install.sh by removing inline command definitions
- `generate-commands.sh`: Generates 37 commands in compact format
  - Core: `/go`, `/harmony`, `/sentinel`
  - Agents: `/hf:agent:*` (18 agents)
  - Workflows: `/hf:workflow:*` (8 workflows)
  - TestArch: `/hf:testarch:*` (4 commands)
  - Diagrams: `/hf:diagram:*` (4 commands)
- `install.sh`: Simplified `create_slash_commands()` to use `generate-commands.sh` with fallback

### Fixed
- TestArch commands now have proper descriptions from workflow.yaml files
- All command files now have mandatory `name` field

## [1.0.18] - 2026-01-05

### Changed
- **Knowledge Centralization**: Reorganized 73 knowledge files from scattered locations to centralized `knowledge/` directory
  - `knowledge/domains/` - AI, Security, DevOps, Gaming, Quality
  - `knowledge/frameworks/` - React, NestJS, Angular, Symfony, NextJS, Tailwind
  - `knowledge/languages/` - JavaScript, TypeScript, Python, Bash
  - `knowledge/runtimes/` - NodeJS
  - `knowledge/shared/` - Shared patterns (API, SQL, Error handling)
- Updated manifest.yaml format to reference centralized knowledge paths
- Install script now copies `knowledge/` directory

### Fixed
- Manifests (NestJS, React, Angular, Symfony) updated to new centralized knowledge format

## [1.0.17] - 2026-01-05

### Fixed
- Install script: empty directories in profiles/ and specialties/ are now created
- Install script: added verification for `harmony.manifest.json` copy
- Install script: added warning when essential files not found in source
- Install script: added `harmony.manifest.json` to critical files verification list

## [1.0.16] - 2026-01-04

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
