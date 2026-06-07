# Changelog

All notable changes to the Harmony Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.1] - 2026-06-07

### Changed
- **README allégé** : recentré sur les trois piliers (routing, mémoire d'erreurs, quality gates) au lieu de la seule mémoire d'erreurs ; Quick Start remonté ; onglet « How It Works » ; témoignages reformulés en retour d'expérience à la première personne ; ~527 → ~210 lignes. Le contenu retiré n'est pas perdu — il est déplacé dans des pages docs liées.
- **`docs/how-it-works.md`** : ajout d'une intro + sommaire et regroupement en 6 parties numérotées ; accueille les schémas déplacés depuis le README (self-improving engine, UCV/zéro perte de contexte, JIT loading, runs-everywhere) + tableaux IDE/profils/spécialités.
- **`docs/enterprise.md`** : ROI / économies de tokens / productivité déplacés ici sous « Impact estimé (basé sur notre expérience) », clairement étiquetés comme estimations issues du vécu (et non des chiffres audités).
- **`SECURITY.md`** : signalement des vulnérabilités via GitHub Security Advisories uniquement.

### Fixed
- **Boîtes ASCII mal alignées (« zigzag »)** dans le README et les docs : un emoji occupe 2 colonnes d'affichage mais 1 caractère, ce qui faisait dériver le bord droit (`║`/`│`) ligne par ligne. Chaque ligne est re-paddée à une largeur d'affichage constante (emoji = 2 colonnes) pour aligner tous les bords (rendu GitHub/terminal).

## [1.4] - 2026-06-07

### Added
- **Architecture mémoire à deux zones (ADR-010)** : tout l'état mutable vit sous `.harmony/local/` ; la base `.harmony/` reste read-only et régénérable. Seeds depuis `templates/memory/`, merge additif (les valeurs existantes gagnent) → une mise à jour ne détruit plus l'état du projet.
- **Logs sécurité à deux couches** dans `.harmony/local/logs/security/` : `security.log` (app/poste-dev : commandes dangereuses, injection shell, supply-chain) et `llm-security.log` (couche LLM : prompt-injection, exfiltration, stéganographie, data-sandbox). `supply-chain-guard` et `llm-output-sanitizer` persistent désormais leurs détections.
- **Patterns anti-injection shell** (rules-enforcer) : `base64 -d | bash`, `eval $(curl …)`, `bash <(curl …)`, `source <(curl …)`, `curl … | python/perl/ruby/node` (faible taux de faux positifs).
- **Pattern P-025 — Regression-First Bug Resolution** : sur tout bug, écrire d'abord un test qui le reproduit (RED), corriger (GREEN), renforcer, apprendre (Sentinel). Ancré dans `INSTRUCTIONS.md` (valable pour tout LLM).
- **Error-library BASH-006** : `set -euo pipefail` dans une lib sourcée fuit dans l'appelant.
- **Onboarding `tips_seen` complété** : le suivi des tips vus (template + état planifiés mais jamais câblés) est désormais fonctionnel — les tips déjà vus ne sont plus re-affichés aux réinstallations/mises à jour, et l'ajout d'un nouveau tip n'affiche que celui-ci (flag `routellm` ajouté).
- **Doc** : `docs/memory-architecture.md` + `knowledge/gaming-edtech-patterns.md`.

### Changed
- **Migration des chemins mémoire** : `.claude/memory/` et la base `memory/` unifiés vers `.harmony/local/memory/` à travers agents, specialties, hooks, libs et docs.
- **Durcissement des libs (BASH-006)** : `set -euo pipefail` ne fuit plus des bibliothèques sourcées (strict mode gardé en exécution directe uniquement) ; `recovery.sh` n'a plus d'effet de bord au chargement.
- **Install minimal** : sème désormais `local/memory/` depuis les templates (plus de seeds pollués) ; le dossier base vestigial `.harmony/memory/` n'est plus créé.

### Fixed
- **Références d'agents cassées** réparées (`core/sentinel.md`, `core/think-protocol.md`, `shared/protocols/…`, workflows diagrams, `core/config.yaml`) — l'agent scrum-master lit enfin le bon `working.json`.

### Removed
- **Module cost-tracker** (suivi de coût géré nativement) : `lib/cost-tracker.sh`, commande `/costs`, références associées.

## [1.3] - 2026-06-06

### Added
- **Security Guards** — deux hooks de protection activables via switch :
  - `supply-chain-guard` (PreToolUse/Bash) : vérifie les installations de packages (npm/pip/composer/cargo/gem/go/npx) contre vulnérabilités, typosquatting (liste enrichie incidents 2026), sources non-officielles, période de quarantaine des packages récents, lock files manquants
  - `llm-output-sanitizer` (PostToolUse/Bash,WebFetch,WebSearch) : filtre le contenu externe (injection de prompt, exfiltration, secrets, stéganographie Unicode) — 2 modes : `external-only` (défaut) et `strict` (+ Read + Semgrep)
- **Vérification des serveurs MCP** : blocage des installs MCP sans version pinnée + scan des `.mcp.json` non-pinnés (protection auto-update vers version vulnérable)
- **Slash command** `/hf:security:guards` (status/on/off/mode) + override env `HARMONY_GUARDS=off`
- **`lib/security-guards.sh`** : engine du switch (config persistée dans `local/security-guards.json`)
- **`docs/security-guards.md`** : documentation complète + section dédiée dans le README
- **Tests** : `validate-security-guards.sh` (9 tests), `validate-testarch.sh`, `validate-bash-syntax.sh`

### Changed
- **README** : section Security Guards (défense en profondeur, scripts à maintenir à jour), intégration testimonials, suppression des liens Discord
- **LICENSE** : email de contact commercial mis à jour
- **`docs/enterprise.md`** retravaillé en page **AI Consulting** : intégration sécurisée multi-environnement (WSL2, sandboxing Firecracker/gVisor, on-premise air-gapped), gestion optimale des LLM, workflows avancés et agents spécialisés par domaine, sécurité des données en priorité

## [1.2] - 2026-06-06

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

## [1.1] - 2026-06-04

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
