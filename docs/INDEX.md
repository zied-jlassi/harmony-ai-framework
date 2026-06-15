# Harmony Framework Documentation

> **🌐 Language:** English · [Français](fr/INDEX.md)

> Complete documentation of the Harmony framework for AI-assisted development.

---

## Quick Navigation

| Section | Description |
|---------|-------------|
| [QUICK-START](QUICK-START.md) | **Get started in 2 minutes** |
| [INDEX-REFERENCE](INDEX-REFERENCE.md) | Quick reference (agents, commands, HQVF) |
| [Getting Started](getting-started.md) | Complete getting-started guide |
| [Installation](installation.md) | Installation and configuration |
| [Concepts](concepts.md) | Core concepts |
| [Architecture](architecture.md) | Technical architecture |

---

## Prerequisites

### Required

| Tool | Min Version | Description |
|------|-------------|-------------|
| **Bash** | 4.0+ | Required shell (native on Linux/macOS, Git Bash on Windows) |
| **npm** | 8.0+ | For installing the framework |

### Optional (Performance)

These tools are auto-detected at install time. Their presence improves performance.

| Tool | Gain | Installation |
|------|------|--------------|
| **Node.js** | +30% | Async scripts, native JSON |
| **Bun** | +80% | Ultra-fast runtime (replaces Node) |
| **jq** | +15% | Streaming JSON processing |

### Performance Levels

| Level | Configuration | Description |
|-------|---------------|-------------|
| **TURBO** 🚀 | Bash + Bun + jq | Maximum performance |
| **ENHANCED** ⚡ | Bash + Node + jq | Very good performance |
| **STANDARD** | Bash + Node | Decent performance |
| **BASIC** | Bash only | Functional, baseline performance |

> See [Installation](installation.md) for detailed per-OS instructions.

---

## Guides

### Getting Started

- [Getting Started](getting-started.md) - First steps with Harmony
- [Installation](installation.md) - Full installation
- [Concepts](concepts.md) - Understand the key concepts

### Technical Reference

- [Architecture](architecture.md) - Framework architecture
- [Architecture Reference](ARCHITECTURE-REFERENCE.md) - Complete architecture reference
- [Hooks](hooks.md) - **Hooks reference**: all 11 hooks, stdin/exit-2 contract, visibility (`systemMessage`), default vs optional
- [Configuration](configuration.md) - **Configuration reference**: every `HARMONY_*` variable and config file
- [Memory Architecture](memory-architecture.md) - **Two-zone memory model** (read-only core / mutable `local/`, ADR-010)
- [Library Reference](library-reference.md) - **Complete bash library reference** (ARIA, Circuit Breaker...)
- [How It Works](how-it-works.md) - Internals (intelligent routing, **Observable by design**, JIT context)
- [Instruction Resilience](architecture/instruction-resilience.md) - CLAUDE.md / .harmony separation, checksums, self-repair
- [Working Memory](working-memory.md) - Memory system
- [UCV Types](ucv-types.md) - **Use Case Verifiable classification** (Functional, Edge Case, Non-functional)
- [Context Persistence](context-persistence.md) - Cross-session context persistence
- [MCP AutoLearning](mcp-autolearning.md) - Automatic learning via MCP servers
- [Overrides](overrides.md) - Customization and overrides
- [Natural Language Config](natural-language-config.md) - Natural-language configuration
- [Evolution](evolution.md) - Roadmap and evolution
- [Commands Reference](commands.md) - Quick command reference

### Guidelines

- [Documentation Guidelines](DOCUMENTATION-GUIDELINES.md) - Documentation standards
- [README Technical](README-technical.md) - Technical details

### Enterprise & Consulting

- [Enterprise & AI Consulting](enterprise.md) - Secure integration, sandboxing, specialized agents, LLM optimization
- [Security Guards](security-guards.md) - Protection layer active by default: **rules-enforcer** (destructive commands, shell injection), **supply-chain**, **LLM anti-injection** — with **visible proof** on every trigger (`systemMessage`)

---

## Libraries

### Core Libraries

> Powerful bash libraries that drive the framework.

**[Complete Library Reference →](library-reference.md)**

| Library | Description |
|---------|-------------|
| **ARIA Detector** | Automatic intent and context detection (Two-Stage: Pattern + LLM) |
| **Context Preloader** | Safe loading with a state machine (infinite-loop guard) + config-driven RouteLLM router (priority Claude Code native > API key > pattern; visible `📥 Context` summary) |
| **Sprint Tracker** | Sprint/story management with Autopilot Pipeline and Circuit Breaker |
| **Cost Tracker** | API cost tracking with multi-currency (USD/EUR) |
| **Config Loader** | Configuration with lazy caching and backward compatibility |

### Assistant Toolkit

> Modules for AI-assisted development.

**[Open the Assistant Toolkit →](assistant-toolkit.md)**

Includes:
- Model Manager (aliases, tiers, cost estimation)
- Auto Linter (language detection, automatic linting)
- Repomap (repository mapping)
- File Watcher (change detection, hooks)
- History Summarizer (history, context compression)

### Prompt Monitor

> Real-time dashboard to track and improve your interactions with Claude.

**[Open the Prompt Monitor →](../commands/monitor.md)**

Includes:
- Automatic tracking of user prompts and tools
- Clarity scoring (0-100) and response quality
- Learning Mode with insights and suggestions
- Automatic token and cost estimation
- Alignment categories (OPTIMAL, IMPRESSIVE, PROBLEM, EXPECTED)

**Prerequisites:** Python 3.8+ with FastAPI, uvicorn, aiosqlite, pydantic

```bash
pip3 install -r .harmony/tools/prompt-monitor/requirements.txt
harmony monitor start
```

### Error Library

> Global error/solution library - collective AutoLearning. JIT loading by agents.

**[Open the Error Library →](../error-library/README.md)**

Includes:
- Versioned errors (BASH-001, JS-001, etc.)
- Automatic MCP Memory sync
- Bash loader for JIT agents

### Quality & Testing Knowledge

> Knowledge to configure test frameworks and ensure quality.

**[Open the Quality Knowledge →](../knowledge/domains/quality/)**

Includes:
- **test-framework-setup.md** - Playwright/Cypress configuration, fixtures, factories
- **atdd-patterns.md** - TDD red-green-refactor, acceptance testing
- **nfr-assessment.md** - Performance, security, release-readiness audit
- **traceability-patterns.md** - Coverage matrices, requirements mapping

**Templates:**
- **CI Templates** - GitHub Actions and GitLab CI for test automation
- **Quality Templates** - Traceability matrices, NFR reports, test design

**ARIA Detection:**
The flags `needs_test_setup`, `needs_tdd`, `needs_ci_tests`, `needs_coverage`, `needs_nfr_audit` are detected automatically and route to the tester/devops/ucv-validator agents.

### Governance Modules (v1.1)

> 15 advanced governance concepts for enterprise-grade AI agents.

**[Modules Reference →](governance-reference.md)**

| Layer | Modules | Description |
|-------|---------|-------------|
| **Governance** | audit-trail, compliance-reporter | Traceability and compliance |
| **Intelligence** | confidence-scorer, agent-maturity, ab-testing | Measurement and evolution |
| **Context** | context-filter (FILCO), mesh-network | Optimization and collaboration |
| **Safety** | data-sandbox, security-gates, anomaly-detector | Protection and detection |

**Cognitive Patterns:**
- `emotional-prompting.md` - Psychological engagement
- `meta-prompting.md` - Dynamic prompt generation
- `self-evolving.md` - Continuous LLM-as-Judge improvement

**Tests:**
```bash
./tests/e2e/scripts/test.sh /path/to/project governance
```

### Patterns

> Pattern library for automatic detection and fast problem resolution.

**[Open the Patterns →](../patterns/INDEX.md)**

Includes:
- 15 documented patterns (incl. P-021 to P-024 governance)
- 7 Sentinel auto-detectable patterns
- 3 cognitive patterns (emotional, meta, self-evolving)
- Case studies with ROI benchmarks

### Agents

> Specialized agents for different development roles.

**Core Agents:**
- [Harmony Agent](../agents/harmony.md) - Main agent
- [Developer Agent](../agents/developer.md) - Developer agent
- [Guardian Agent](../agents/guardian.md) - Protection and validation
- [Sentinel Agent](../agents/sentinel.md) - Memory and learning

**Specialists:**
- [UCV QA](../specialties/ucv/branchs/qa.md) - In-browser UCV validation
- [UCV Writer](../specialties/ucv/branchs/writer.md) - UCV creation
- [UCV Validator](../specialties/ucv/branchs/validator.md) - 100% verification
- [Exploratory QA](../agents/exploratory-qa.md) - Exploratory QA

**Compliance:**
- [Accessibility](../agents/accessibility.md) - WCAG/RGAA/EAA
- [Security](../agents/security.md) - Security audit
- [RGPD](../agents/rgpd.md) - GDPR compliance

### Workflows

> Predefined workflows for common tasks.

- See the [workflows/](../workflows/) folder

### Routing

> Agent detection, routing and orchestration.

- [Routing README](../routing/README.md) - Overview
- [Routing INDEX](../routing/INDEX.md) - Quick reference
- [Detection Patterns](../routing/detection-patterns.yaml) - Keywords and scores
- [Routing Algorithm](../routing/routing-algorithm.yaml) - Scoring algorithm

---

## Global Architecture

```
harmony-framework/
├── README.md              ← You are here (via link)
├── docs/
│   ├── INDEX.md           ← Documentation entry point
│   ├── INDEX-REFERENCE.md ← Quick reference
│   ├── getting-started.md
│   ├── installation.md
│   ├── concepts.md
│   ├── architecture.md
│   └── ...
├── error-library/         ← AutoLearning errors/solutions
│   ├── README.md          ← Documentation + workflow
│   ├── errors/bash/       ← BASH-001 to BASH-00X
│   ├── schema/            ← JSON schema validation
│   └── tools/sync-mcp.sh  ← Sync to MCP Memory
├── patterns/
│   ├── INDEX.md           ← Pattern library
│   ├── P-XXX-*.md         ← System patterns
│   ├── case-studies/      ← Concrete examples
│   └── cognitive/         ← Reasoning patterns (ReAct, Reflection...)
├── agents/
│   ├── INDEX.md           ← Agents index
│   └── *.md               ← All agents (flat structure)
├── specialties/
│   └── ai/                ← AI Systems specialty
│       ├── manifest.yaml  ← Detection and config
│       └── knowledge/     ← RAG, Memory, Orchestration patterns
├── routing/               ← Agent detection and routing
│   ├── INDEX.md
│   ├── detection-patterns.yaml
│   └── routing-algorithm.yaml
├── workflows/             ← Predefined workflows
├── hooks/                 ← Hooks (rules-enforcer, Guardian, Sentinel, ARIA, supply-chain, sanitizer)
└── profiles/              ← Language profiles
```

---

## External Links

- [GitHub Repository](https://github.com/zied-jlassi/harmony-ai-framework)
- [Issues & Support](https://github.com/zied-jlassi/harmony-ai-framework/issues)

---

## Changelog

See [CHANGELOG.md](../CHANGELOG.md) for the version history.
