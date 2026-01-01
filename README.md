<div align="center">

# 🛡️ Harmony Framework

### The AI Framework That Never Forgets Its Errors

**Learn. Protect. Deliver.**

[![npm version](https://img.shields.io/npm/v/harmony-ai-framework.svg?style=for-the-badge)](https://www.npmjs.com/package/harmony-ai-framework)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/harmony-ai/harmony-framework?style=for-the-badge)](https://github.com/harmony-ai/harmony-framework/stargazers)
[![Discord](https://img.shields.io/badge/Discord-Join%20Us-7289DA?style=for-the-badge&logo=discord)](https://discord.gg/harmony-ai)

[📚 Documentation](https://harmony-ai.dev/docs) • [🚀 Quick Start](#-quick-start) • [💬 Discord](https://discord.gg/harmony-ai) • [🎥 Demo](https://youtube.com/harmony-ai)

---

> **"Other frameworks help you build fast. Harmony helps you build right."**

<img src="https://harmony-ai.dev/assets/hero-diagram.svg" alt="Harmony Framework" width="600">

</div>

---

## 🎯 The Problem We Solve

| Scenario | Without Harmony | With Harmony |
|----------|:---------------:|:------------:|
| **Same bug, different day** | Keep repeating mistakes | ✅ Error memory prevents recurrence |
| **"Works on my machine"** | Vague quality claims | ✅ 100% verifiable acceptance criteria |
| **Wrong agent for the task** | Manual routing, confusion | ✅ Automatic intent detection |
| **Context lost between sessions** | Start from scratch | ✅ 3-tier persistent memory |
| **IDE lock-in** | Tied to one tool | ✅ Works with Claude Code, Cursor, Windsurf, Continue, Cody |

---

## 🏆 Why Harmony is Different

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      THE THREE PILLARS OF HARMONY                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔒 GUARDIAN           🛡️ SENTINEL           ✅ HQVF                         ║
║   ─────────────        ───────────           ──────────                       ║
║   Intent Detection     Error Memory          Quality Gates                    ║
║   Agent Routing        Circuit Breaker       Use Case Verifiables             ║
║   Workflow Protection  Pattern Learning      Triple Validation                ║
║                                                                               ║
║   "Right agent,        "Never repeat         "Quality you can                 ║
║    right time"          the same bug"         prove, not assume"              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

**No other AI framework offers these three pillars combined.**

---

## 🚀 Quick Start

```bash
# Full installation with hooks (recommended)
npx harmony-ai-framework --full

# Minimal installation (core files only)
npx harmony-ai-framework --minimal

# For specific IDE
npx harmony-ai-framework --full --ide cursor
npx harmony-ai-framework --full --ide windsurf
```

**That's it!** Harmony auto-detects your tech stack and configures itself.

### After Installation

```bash
/go                               # Session kickoff
/harmony                          # Menu interactif (30 commandes)

# 🔍 VALIDATION FRAMEWORK (1-5)
/harmony full                     # 1 - Audit complet (~2-5 min)
/harmony quick                    # 2 - Check rapide (~30s)
/harmony duplicates               # 3 - Detection duplicats
/harmony fix                      # 4 - Proposer corrections
/harmony fix --apply              #   - Appliquer avec confirmation
/harmony watch                    # 5 - Pre-commit hook
/harmony watch --install          #   - Installer hook
/harmony watch --status           #   - Status hook

# 📊 RAPPORTS (6-7)
/harmony report                   # 6 - Matrice coherence
/harmony report --verbose         #   - Details par categorie
/harmony tokens                   # 7 - Cout tokens par agent
/harmony tokens --breakdown       #   - Details par agent
/harmony tokens --optimize        #   - Suggestions optimisation

# 🎯 VALIDATION SPECIFIQUE (8-10)
/harmony pipeline                 # 8 - Coherence pipeline config vs docs
/harmony pipeline --verbose       #   - Details complets
/harmony pipeline --fix           #   - Proposer corrections
/harmony hooks                    # 9 - Validation hooks Claude
/harmony hooks --install          #   - Installer hooks par defaut
/harmony hooks --status           #   - Status hooks
/harmony patterns                 # 10 - Validation patterns
/harmony patterns --fix           #   - Proposer corrections

# 🔄 SYNCHRONISATION (11-12)
/harmony memory                   # 11 - Sync MCP <-> CLAUDE.md
/harmony memory --diff            #   - Afficher differences
/harmony claude                   # 12 - Validation config Claude Code
/harmony claude --update          # 12u - MAJ regles (GADER pattern)
/harmony claude --fix             #   - Proposer corrections

# 📏 REGLES APPLICATION (13-15)
/harmony rules                    # 13 - Audit regles
/harmony rules --usage            # 14 - Usage dans le code
/harmony rules --report           # 15 - Rapport conformite

# 🛡️ HARMONY SENTINEL (16-20)
/harmony sentinel                 # 16 - Status: Dashboard (defaut)
/harmony sentinel --status        #    - Alias pour status
/harmony sentinel --learn         # 17 - Learn: Documenter erreur
/harmony sentinel --reset         # 18 - Reset: Reinitialiser CB
/harmony sentinel --check         # 19 - Check: Verification complete
/harmony sentinel --report        # 20 - Report: Rapport detaille

# 📚 KNOWLEDGE & PROFILES (21-23)
/harmony learn <url>              # 21 - Apprendre depuis URL
/harmony profiles                 # 22 - Lister profiles
/harmony profiles --active        #    - Afficher actifs
/harmony profiles --add <name>    #    - Activer profile
/harmony profiles --remove <name> #    - Desactiver profile
/harmony specialties              # 23 - Lister specialties
/harmony specialties --active     #    - Afficher actives
/harmony specialties --add <name> #    - Activer specialty
/harmony specialties --remove <n> #    - Desactiver specialty

# 🔌 INTEGRATIONS (24-25)
/harmony install <ide>            # 24 - Deployer vers IDE
/harmony install --status         # 25 - Afficher integrations

# ✅ QUALITE HQVF (26-27)
/harmony ucv <story>              # 26 - Creer UCVs
/harmony ucv --validate <story>   # 27 - Verifier couverture

# 🆕 FRAMEWORK (28-30)
/harmony init                     # 28 - Initialiser Harmony
/harmony upgrade                  # 29 - Mettre a jour framework
/harmony upgrade --check          #    - Verifier updates
/harmony export                   # 30 - Exporter configuration
/harmony export --full            #    - Export complet avec memory
```

---

## 📊 Feature Comparison

| Feature | LangChain | CrewAI | AutoGen | Semantic Kernel | **Harmony** |
|---------|:---------:|:------:|:-------:|:---------------:|:-----------:|
| **Error Memory** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Circuit Breaker** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Intent Detection** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Quality Gates (UCV)** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **3-Tier Memory** | ❌ | ❌ | Partial | ❌ | ✅ |
| **Story-Based Dev** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Multi-IDE** | ❌ | ❌ | ❌ | ❌ | ✅ |
| Multi-Agent | ✅ | ✅ | ✅ | ✅ | ✅ |
| Workflow Control | Partial | Partial | Partial | ✅ | ✅ |
| Production Ready | ✅ | ✅ | ✅ | ✅ | ✅ |

> **Note**: LangChain/CrewAI are code orchestration libraries. Harmony is an SDLC methodology framework. Different categories, complementary usage.

---

## 🧠 How It Works

### 1. Guardian Protocol - Intelligent Routing

```
User: "develop the scoring system"
         ↓
┌─────────────────────────────────┐
│    GUARDIAN INTENT DETECTION     │
├─────────────────────────────────┤
│  Keywords: "develop", "scoring" │
│  Intent: IMPLEMENT              │
│  Context: Gaming                │
│  Story Required: Yes            │
└─────────────────────────────────┘
         ↓
  [Route to Developer Agent]
         ↓
  [Developer: Developer activated]
```

### 2. Sentinel System - Error Memory

```
┌─────────────────────────────────────────┐
│         CIRCUIT BREAKER STATE            │
├─────────────────────────────────────────┤
│  State: 🟢 CLOSED                       │
│  Failures: 0/3                          │
│                                         │
│  Error Journal:                         │
│  ├── 45 errors documented               │
│  ├── 42 resolved (93%)                  │
│  └── 0 recurring ✓                      │
│                                         │
│  Learned Patterns: 12                   │
│  Applied: 34 times                      │
└─────────────────────────────────────────┘
```

**Result**: -82% recurring bugs.

### 3. HQVF - Quality Verification

```yaml
# STORY-042-UCV.md
story: "User Profile Update"
status: APPROVED

use_cases:
  - id: UC-001
    title: "Open edit modal"
    verifications:
      - id: V-001-1
        description: "Modal centered on screen"
        dev: ✅    # Developer confirms
        test: ✅   # Tester validates
        qa: ✅     # QA approves

coverage: 100% → Story DONE ✓
```

**Result**: Zero "works on my machine".

---

## 👥 Agent Ecosystem

### Core Agents

| Agent | Persona | Role | Phase |
|-------|---------|------|:-----:|
| Guardian | - | Workflow protection, intent detection | All |
| Sentinel | - | Error memory, circuit breaker | All |
| Analyst | Analyst | Requirements analysis | 1-2 |
| Architect | Architect | Technical design, ADRs | 3 |
| Scrum Master | Scrum Master | Sprint management, story creation | 3-4 |
| Developer | Developer | Implementation | 4 |
| Tester | Tester | Quality assurance, test coverage | 4 |

### Specialist Agents

| Agent | Persona | Specialty |
|-------|---------|-----------|
| AI Architect | AI Architect | AI/LLM Architecture (+ 6 sub-agents: Riley, Oscar, Sage, Milo, Grace, Olivia) |
| Exploratory QA | Exploratory QA | Exploratory QA, user experience testing |
| UCV Writer | UCV Writer | UCV Writer - Creates Use Case Verifiables |
| UCV Validator | UCV Validator | UCV Validator - Validates 100% coverage |

### Compliance Agents

| Agent | Focus |
|-------|-------|
| RGPD Agent | GDPR compliance |
| Security Agent | Security audits |
| A11y Agent | Accessibility (WCAG/RGAA) |
| Pentest Agent | Penetration testing |

---

## 🔌 IDE Support

| IDE | Support | Features |
|-----|:-------:|----------|
| **Claude Code** | 🟢 Full | Hooks, Memory, MCP, Skills |
| **Cursor** | 🟡 Good | Rules (.mdc), Personas |
| **Windsurf** | 🟡 Good | Rules (.windsurfrules) |
| **Continue** | 🟡 Good | Assistants, Context |
| **Cody** | 🟠 Partial | Prompts |

```bash
# Install for specific IDE
npx harmony-ai-framework --full --ide claude-code  # Default
npx harmony-ai-framework --full --ide cursor
npx harmony-ai-framework --full --ide windsurf
npx harmony-ai-framework --full --ide continue
npx harmony-ai-framework --full --ide cody
```

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/getting-started.md) | 5-minute tutorial |
| [Core Concepts](docs/concepts.md) | Understand the pillars |
| [Architecture](docs/architecture.md) | Technical deep-dive |
| [Commands Reference](commands/index.md) | All 30 commands |
| [Agents Guide](agents/README.md) | Agent ecosystem |
| [Profiles & Specialties](profiles/README.md) | Tech stack knowledge |

---

## 🎮 Example: Gaming Project

```bash
# Initialize with gaming specialty
npx harmony-ai-framework --full --specialty gaming

# Learn game design patterns
/harmony learn https://www.gamedeveloper.com/design/progression-systems

# Create UCVs for a story
/harmony ucv STORY-026

# Sentinel (voir liste complete ci-dessus)
/harmony sentinel                 # Dashboard health
/harmony sentinel --learn         # Document error

# Deploy to Cursor
npx harmony-ai-framework --full --ide cursor
```

---

## 🏢 Enterprise Features

<table>
<tr>
<td width="33%">

### 🆓 Community (Free)

- Guardian Protocol (base)
- Sentinel System (base)
- HQVF Quality (base)
- 6 Core Agents
- 3 Tech Profiles
- Claude Code integration
- Community support

</td>
<td width="33%">

### 💎 Pro ($19/month)

- All Community features
- All Tech Profiles (50+)
- All Specialist Agents
- 2 Specialties included
- All IDE integrations
- Priority support
- `/harmony learn` full

</td>
<td width="33%">

### 🏢 Enterprise (Contact)

- All Pro features
- All Specialties
- Custom Specialty creation
- Compliance Agents (RGPD, HIPAA)
- SLA 99.9%
- Dedicated support
- On-premise option

</td>
</tr>
</table>

---

## 🏗️ Architecture: Core vs Local

> **Key principle**: Separate framework (shareable) from project data (local).

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE HARMONY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   .harmony/                    CORE FRAMEWORK (Read-Only)       │
│   ├── agents/                  Agent definitions                │
│   ├── workflows/               Workflow definitions             │
│   ├── templates/               Reusable templates               │
│   ├── patterns/                Documented patterns              │
│   ├── rules/                   Framework rules                  │
│   └── docs/                    Documentation                    │
│                                                                  │
│   .claude/                     PROJECT DATA (Local)             │
│   ├── memory/                  ← Project-specific data          │
│   │   ├── working.json         Sprint/Story tracking            │
│   │   ├── workflow-state.json  Workflow state                   │
│   │   ├── error-journal.json   Project errors                   │
│   │   └── learned-patterns.json Discovered patterns             │
│   ├── commands/                                                  │
│   │   └── harmony.md           /harmony skill                   │
│   └── settings.json            Hooks configuration              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Separation?

| Aspect | Benefit |
|--------|---------|
| **Immutable core** | Update Harmony without losing your data |
| **Isolated data** | Your sprints/errors don't pollute the framework |
| **Clean PRs** | Contribute to core without project data |
| **Multi-project** | Same Harmony version, independent data |

---

## 🤝 Community

- 💬 [Discord](https://discord.gg/harmony-ai) - Join 500+ developers
- 🐛 [Issues](https://github.com/harmony-ai/harmony-framework/issues) - Report bugs
- 💡 [Discussions](https://github.com/harmony-ai/harmony-framework/discussions) - Ideas & help
- 🐦 [Twitter](https://twitter.com/harmony_ai) - News & updates

---

## 🙏 Testimonials

> *"Harmony eliminated 90% of our recurring bugs. The Sentinel system is a game-changer."*
> — **Senior Developer, Fortune 500**

> *"HQVF transformed how we define quality. No more 'it works on my machine'."*
> — **QA Lead, SaaS Startup**

> *"Guardian routing saved us hours of context-switching confusion."*
> — **Tech Lead, AI Consulting**

---

## 📖 Origin & Design Philosophy

> *"Ce document garde la trace du processus de pensée."*

Harmony was born from real problems in production projects.

### The Genesis Story

In December 2024, on a complex e-commerce project, we observed:
- **45 recurring bugs** - The same bug kept coming back session after session
- **Dev/Test/QA gap** - DEV writes 100 lines, TEA tests 5%, User sees 55%
- **Context switching chaos** - Wrong agent activated, time wasted

AI Architect's analysis (AI Architect) across 150+ sources in 2025 revealed:
> "No existing framework offers persistent error memory
> or verifiable quality systems. This is our USP."

### Architectural Decision Records (ADRs)

| ADR | Decision | Rationale |
|-----|----------|-----------|
| **ADR-001** | Prompt-Based, Not Fine-Tuned | "The LLM stays intact. Guaranteed performance." |
| **ADR-002** | Circuit Breaker Manual Reset | "Auto-reset allows error repetition." |
| **ADR-003** | UCV Triple Validation | "DEV+TEST+QA = complete quality" |
| **ADR-004** | Profiles Auto-Detection | "Less manual configuration" |

### Lessons Learned

| What Worked | Impact |
|-------------|--------|
| Sentinel Error Memory | -82% recurring bugs |
| HQVF Quality Gates | Zero "works on my machine" |
| Guardian Routing | Auto-routing without confusion |

📚 **Deep Dive**: [Evolution & Design Decisions](docs/evolution.md) | [Technical Reference](docs/README-technical.md)

---

## 📄 License

MIT License - Use it anywhere. [See LICENSE](LICENSE)

---

<div align="center">

### 🛡️ Harmony Framework

**The AI framework that never forgets its errors.**

**Learn. Protect. Deliver.**

---

[Get Started](docs/getting-started.md) • [Documentation](https://harmony-ai.dev/docs) • [Discord](https://discord.gg/harmony-ai)

---

Made with 🧠 by developers who got tired of repeating the same bugs.

*Star us on GitHub if you find Harmony useful!* ⭐

</div>
