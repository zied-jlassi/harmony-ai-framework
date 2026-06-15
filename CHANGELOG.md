# Changelog

All notable changes to the Harmony Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.5.0] - 2026-06-15

### Added
- **Visible hook status (`lib/hook-ui.sh`)**: every guard now proves it fired via a
  `systemMessage` (the only channel shown for non-blocking hooks) plus per-hook
  `statusMessage` spinners. Toggle with `HARMONY_HOOK_UI=off`.
- **`rules-enforcer` active by default** in `--full` (wired first in the PreToolUse
  `Edit|Write|Bash` group): blocks destructive shell/SQL commands, fork bombs,
  curl-piped-to-shell and secrets before execution.
- **Config-driven intent routing (RouteLLM)** in `lib/context-preloader.sh`: path
  resolved by priority **CLAUDECODE (native Task tool, no key) > API key > pattern**,
  override via `HARMONY_ROUTER_MODE`; the classifier model comes from config
  (`router_model`), robust to python-yq. `preload_context` accepts a pre-computed
  classification and emits a visible "Context loaded" summary at agent dispatch.
- **New reference docs**: `docs/hooks.md` (all 11 hooks, the stdin/exit-2 contract,
  visibility) and `docs/configuration.md` (every `HARMONY_*` variable + config files).
- **Bilingual documentation**: English canonical at `docs/*.md` + French mirror at
  `docs/fr/**` with a language switcher on every page (40 EN ↔ 40 FR); diagrams,
  code and commands kept verbatim.

### Changed
- **Hooks migrated to the Claude Code stdin contract**: `guardian-checkpoint`,
  `sentinel-pre`, `sentinel-post`, `aria-detect`, `rules-enforcer` now read event
  JSON on stdin (`.tool_name` / `.tool_input` / `.tool_response`) and block with
  `exit 2` — they previously used positional args / `$TOOL_INPUT` and received empty
  input under Claude Code. `install.sh` hook wiring updated accordingly.
- **Agent dispatch formalized** in `agents/guardian.md` (Step 4) and `INSTRUCTIONS.md`:
  run the router via `Task(model=router_model)` then preload context, surfacing the
  summary in the P-010 announcement.
- **Stale install commands corrected** across docs (`npx harmony init` / `harmony doctor`
  → `npx harmony-ai --full`; ops via slash commands).

### Fixed
- **`--full` aborted at checksum verification**: `SECURITY.md` was listed in
  `checksums.sha256` but missing from the essential-files copy loop in `bin/install.sh`.
- **`working.json` stored `{"error":"invalid classification"}`**: the classification
  cache, set inside a `$(...)` subshell, was lost before injection; it is now
  propagated to the parent shell.
- **Stray `.harmony/` created outside an install**: the preloader's cache and
  `working.json` writes are now gated on an already-existing memory dir, so running it
  from the repo (with `HARMONY_DIR` unset) no longer creates a `.harmony/` tree.

## [1.4.1] - 2026-06-07

### Changed
- **Leaner README**: refocused on the three pillars (routing, error memory, quality gates) instead of error memory alone; Quick Start moved up; a "How It Works" page; testimonials reworded as first-person experience reports; ~527 → ~210 lines. The removed content is not lost — it moved to linked docs pages.
- **`docs/how-it-works.md`**: added an intro + table of contents and grouped into 6 numbered parts; hosts the diagrams moved from the README (self-improving engine, UCV / zero context loss, JIT loading, runs-everywhere) + IDE/profiles/specialties tables.
- **`docs/enterprise.md`**: ROI / token savings / productivity moved here under "Estimated impact (based on our experience)", clearly labeled as experience-based estimates (not audited figures).
- **`SECURITY.md`**: vulnerability reporting via GitHub Security Advisories only.

### Fixed
- **Misaligned ASCII boxes ("zigzag")** in the README and docs: an emoji takes 2 display columns but 1 character, which made the right border (`║`/`│`) drift line by line. Each line is re-padded to a constant display width (emoji = 2 columns) to align all borders (GitHub/terminal rendering).

## [1.4] - 2026-06-07

### Added
- **Two-zone memory architecture (ADR-010)**: all mutable state lives under `.harmony/local/`; the `.harmony/` base stays read-only and regenerable. Seeds from `templates/memory/`, additive merge (existing values win) → an update no longer destroys project state.
- **Two-layer security logs** in `.harmony/local/logs/security/`: `security.log` (app / dev-workstation: dangerous commands, shell injection, supply-chain) and `llm-security.log` (LLM layer: prompt-injection, exfiltration, steganography, data-sandbox). `supply-chain-guard` and `llm-output-sanitizer` now persist their detections.
- **Shell anti-injection patterns** (rules-enforcer): `base64 -d | bash`, `eval $(curl …)`, `bash <(curl …)`, `source <(curl …)`, `curl … | python/perl/ruby/node` (low false-positive rate).
- **Pattern P-025 — Regression-First Bug Resolution**: for any bug, first write a test that reproduces it (RED), fix (GREEN), harden, learn (Sentinel). Anchored in `INSTRUCTIONS.md` (applies to any LLM).
- **Error-library BASH-006**: `set -euo pipefail` in a sourced lib leaks into the caller.
- **Onboarding `tips_seen` completed**: seen-tips tracking (template + state planned but never wired) is now functional — already-seen tips are no longer re-shown on reinstalls/updates, and adding a new tip shows only that one (`routellm` flag added).
- **Docs**: `docs/memory-architecture.md` + `knowledge/gaming-edtech-patterns.md`.

### Changed
- **Memory path migration**: `.claude/memory/` and the base `memory/` unified to `.harmony/local/memory/` across agents, specialties, hooks, libs and docs.
- **Lib hardening (BASH-006)**: `set -euo pipefail` no longer leaks from sourced libraries (strict mode kept for direct execution only); `recovery.sh` no longer has a side effect on load.
- **Minimal install**: now seeds `local/memory/` from the templates (no more polluted seeds); the vestigial base `.harmony/memory/` folder is no longer created.

### Fixed
- **Broken agent references** repaired (`core/sentinel.md`, `core/think-protocol.md`, `shared/protocols/…`, workflow diagrams, `core/config.yaml`) — the scrum-master agent finally reads the correct `working.json`.

### Removed
- **cost-tracker module** (cost tracking handled natively): `lib/cost-tracker.sh`, the `/costs` command, and associated references.

## [1.3] - 2026-06-06

### Added
- **Security Guards** — two switchable protection hooks:
  - `supply-chain-guard` (PreToolUse/Bash): screens package installs (npm/pip/composer/cargo/gem/go/npx) against vulnerabilities, typosquatting (list enriched with 2026 incidents), non-official sources, cooling period for recent packages, missing lock files
  - `llm-output-sanitizer` (PostToolUse/Bash,WebFetch,WebSearch): filters external content (prompt injection, exfiltration, secrets, Unicode steganography) — 2 modes: `external-only` (default) and `strict` (+ Read + Semgrep)
- **MCP server verification**: blocks MCP installs without a pinned version + scan of unpinned `.mcp.json` (protection against auto-update to a vulnerable version)
- **Slash command** `/hf:security:guards` (status/on/off/mode) + env override `HARMONY_GUARDS=off`
- **`lib/security-guards.sh`**: the switch engine (config persisted in `local/security-guards.json`)
- **`docs/security-guards.md`**: complete documentation + a dedicated section in the README
- **Tests**: `validate-security-guards.sh` (9 tests), `validate-testarch.sh`, `validate-bash-syntax.sh`

### Changed
- **README**: Security Guards section (defense in depth, scripts to keep updated), testimonials integration, removal of Discord links
- **LICENSE**: commercial contact email updated
- **`docs/enterprise.md`** reworked into an **AI Consulting** page: secure multi-environment integration (WSL2, Firecracker/gVisor sandboxing, air-gapped on-premise), optimal LLM management, advanced workflows and domain-specialized agents, data security as priority

## [1.2] - 2026-06-06

### Added
- **TestArch — 8 complete test workflows** (100% Harmony originals)
  - `testarch/framework`: automatic selection of Vitest, Jest, Playwright, Cypress, pytest, JUnit, go test
  - `testarch/atdd`: RED→GREEN→REFACTOR cycle from acceptance criteria (BDD, Gherkin)
  - `testarch/test-design`: equivalence, boundary values, decision tables, state transition
  - `testarch/automate`: coverage analysis (line/branch/function) + generation of missing tests
  - `testarch/test-review`: anti-pattern detection (ice cream cone, flaky, over-mocking, dead tests)
  - `testarch/nfr-assess`: performance (k6/Gatling/Artillery), security (OWASP/SAST/DAST), accessibility (WCAG 2.1/Axe)
  - `testarch/trace`: bidirectional requirements ↔ tests traceability matrix + CI quality gate
  - `testarch/ci`: 4-layer pipeline GitHub Actions + GitLab CI with Playwright sharding
- **8 TestArch slash commands**: `/hf:testarch:framework`, `atdd`, `test-design`, `automate`, `test-review`, `nfr-assess`, `trace`, `ci`
- **25 enriched agents**: `persona` property, `Absolute Rule` section, mandatory closing template
- **12 new libs**: `harmony-audit`, `security-gates`, `ab-testing`, `agent-maturity`, `anomaly-detector`, `audit-trail`, `compliance-reporter`, `confidence-scorer`, `context-filter`, `data-sandbox`, `mesh-network`, `recovery`
- **5 new patterns**: P-020 parallel-execution, P-021 meta-prompting, P-022 agent-maturity, P-023 mesh-networks, P-024 context-filtering
- **3 cognitive patterns**: emotional-prompting, meta-prompting, self-evolving
- **Integrated testarch workflows**: ready-to-use GitHub Actions and GitLab CI templates
- **`docs/prompt-monitor.md`**: activation guide with `${HARMONY_DIR}`, Case A (copy) / Case B (merge)
- **`tools/prompt-monitor/settings-addon.json`**: isolated hooks, copy to `.claude/settings.local.json`
- **2 new agents**: `analyst-mini`, `developer-quickwin`
- **New quality patterns**: `knowledge/domains/quality/` (atdd, nfr, traceability, test-framework-setup)
- **Memory templates**: 18 JSON schemas/templates for Harmony persistence
- **`memory/` folder**: initial state and templates for onboarding

### Changed
- **Prompt Monitor disabled by default**: hooks removed from the installed `settings.json`, opt-in activation via `settings-addon.json`
- **`generate-commands.sh`**: 4 → 8 TestArch commands registered
- **`checksums.sha256`**: regenerated (857 files, excludes `bin/` and `memory/`)

### Fixed
- **`autopilot-commands.sh`**: removed the invalid `local` keyword on the `display_status()` function declaration
- **`rules/R-001-story-required.yaml`**: more restrictive `allowed_paths` (removed `docs/`)

### Security
- **15 Dependabot vulnerabilities** fixed in `tools/document-parser/requirements.txt`:
  - `pillow` 10.4.0 → 12.2.0 (OOB write, decompression bomb)
  - `urllib3` 2.6.2 → 2.7.0 (decompression bomb, sensitive headers)
  - `lxml` 5.1.0 → 6.1.0 (XXE local files)
  - `protobuf` 6.33.2 → 6.33.5 (JSON recursion bypass)
  - `requests` 2.32.5 → 2.33.0 (temp file reuse)
  - `transformers` 4.57.3 → 5.0.0rc3 (code exec in Trainer)
  - `idna` 3.11 → 3.15, `python-dotenv` 1.2.1 → 1.2.2, `filelock` 3.20.1 → 3.20.3
- **`torch==2.9.1+cpu`** → `torch==2.9.1`: version installable via standard PyPI

## [1.1] - 2026-06-04

### Security
- **Removal of offensive pentest modules** for safe public use
  - `pentest-metasploit.md` removed: Meterpreter, EternalBlue, reverse shells
  - `pentest-exploit.md` removed: shellcode, buffer overflow, ROP chains
  - `pentest-malware.md` removed: msfvenom payloads, AV evasion techniques
  - `pentest-post.md` removed: credential harvesting, data exfiltration
  - `pentest-network.md` removed: WiFi hacking, MITM, Pass the Hash
  - `pentest-social.md` removed: phishing, USB attacks (Rubber Ducky/BadUSB)
  - These modules remain archived in the `1.0` tag for use in an isolated, authorized lab environment only
  - Reference: OWASP Testing Guide — defensive and educational use

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
