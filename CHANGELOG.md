# Changelog

All notable changes to the Harmony Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0] - 2026-06-06

### Added
- **TestArch — 8 workflows de test complets** (100% originaux Harmony)
  - `testarch/framework` : sélection automatique Vitest, Jest, Playwright, Cypress, pytest, JUnit, go test
  - `testarch/atdd` : cycle RED→GREEN→REFACTOR depuis les critères d'acceptation (BDD, Gherkin)
  - `testarch/test-design` : équivalence, boundary values, tables de décision, transition d'état
  - `testarch/automate` : analyse couverture (line/branch/function) + génération tests manquants
  - `testarch/test-review` : détection anti-patterns (ice cream cone, flaky, over-mocking, dead tests)
  - `testarch/nfr-assess` : performance (k6/Gatling/Artillery), sécurité (OWASP/SAST/DAST), accessibilité (WCAG 2.1/Axe)
  - `testarch/trace` : matrice de traçabilité bidirectionnelle exigences ↔ tests + quality gate CI
  - `testarch/ci` : pipeline 4 couches GitHub Actions + GitLab CI avec sharding Playwright
- **8 slash commands TestArch** : `/hf:testarch:framework`, `atdd`, `test-design`, `automate`, `test-review`, `nfr-assess`, `trace`, `ci`
- **25 agents enrichis** : propriété `persona`, section `Règle Absolue`, template de fin obligatoire
- **12 nouvelles libs** : `harmony-audit`, `security-gates`, `ab-testing`, `agent-maturity`, `anomaly-detector`, `audit-trail`, `compliance-reporter`, `confidence-scorer`, `context-filter`, `data-sandbox`, `mesh-network`, `recovery`
- **5 nouveaux patterns** : P-020 parallel-execution, P-021 meta-prompting, P-022 agent-maturity, P-023 mesh-networks, P-024 context-filtering
- **3 patterns cognitifs** : emotional-prompting, meta-prompting, self-evolving
- **Workflows testarch intégrés** : templates CI GitHub Actions et GitLab CI prêts à l'emploi
- **`docs/prompt-monitor.md`** : guide d'activation avec `${HARMONY_DIR}`, Cas A (copie) / Cas B (fusion)
- **`tools/prompt-monitor/settings-addon.json`** : hooks isolés, copier vers `.claude/settings.local.json`
- **2 nouveaux agents** : `analyst-mini`, `developer-quickwin`
- **Nouveaux patterns de qualité** : `knowledge/domains/quality/` (atdd, nfr, traceability, test-framework-setup)
- **Templates memory** : 18 schemas/templates JSON pour la persistance Harmony
- **`memory/` folder** : état initial et templates pour l'onboarding

### Changed
- **Prompt Monitor désactivé par défaut** : hooks retirés du `settings.json` installé, activation opt-in via `settings-addon.json`
- **`generate-commands.sh`** : 4 → 8 commandes TestArch enregistrées
- **`checksums.sha256`** : régénéré (857 fichiers, exclut `bin/` et `memory/`)

### Fixed
- **`autopilot-commands.sh`** : suppression du mot-clé `local` invalide sur déclaration de fonction `display_status()`
- **`rules/R-001-story-required.yaml`** : `allowed_paths` plus restrictif (suppression de `docs/`)

### Security
- **15 vulnérabilités Dependabot** corrigées dans `tools/document-parser/requirements.txt` :
  - `pillow` 10.4.0 → 12.2.0 (OOB write, decompression bomb)
  - `urllib3` 2.6.2 → 2.7.0 (decompression bomb, sensitive headers)
  - `lxml` 5.1.0 → 6.1.0 (XXE local files)
  - `protobuf` 6.33.2 → 6.33.5 (JSON recursion bypass)
  - `requests` 2.32.5 → 2.33.0 (temp file reuse)
  - `transformers` 4.57.3 → 5.0.0rc3 (code exec in Trainer)
  - `idna` 3.11 → 3.15, `python-dotenv` 1.2.1 → 1.2.2, `filelock` 3.20.1 → 3.20.3
- **`torch==2.9.1+cpu`** → `torch==2.9.1` : version installable via PyPI standard

## [2.0] - 2026-06-04

### Security
- **Retrait des modules pentest offensifs** pour usage public sécurisé
  - `pentest-metasploit.md` supprimé : Meterpreter, EternalBlue, reverse shells
  - `pentest-exploit.md` supprimé : shellcode, buffer overflow, ROP chains
  - `pentest-malware.md` supprimé : msfvenom payloads, techniques d'évasion AV
  - `pentest-post.md` supprimé : credential harvesting, data exfiltration
  - `pentest-network.md` supprimé : WiFi hacking, MITM, Pass the Hash
  - `pentest-social.md` supprimé : phishing, USB attacks (Rubber Ducky/BadUSB)
  - Ces modules restent archivés dans le tag `1.0` pour usage en environnement lab isolé et autorisé uniquement
  - Référence : OWASP Testing Guide — usage défensif et éducatif

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
