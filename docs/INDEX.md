# Harmony Framework Documentation

> Documentation complete du framework Harmony pour le developpement assiste par IA.

---

## Navigation Rapide

| Section | Description |
|---------|-------------|
| [QUICK-START](QUICK-START.md) | **Demarrage en 2 minutes** |
| [INDEX-REFERENCE](INDEX-REFERENCE.md) | Reference rapide (agents, commandes, HQVF) |
| [Getting Started](getting-started.md) | Guide de demarrage complet |
| [Installation](installation.md) | Installation et configuration |
| [Concepts](concepts.md) | Concepts fondamentaux |
| [Architecture](architecture.md) | Architecture technique |

---

## Prérequis

### Requis

| Outil | Version Min | Description |
|-------|-------------|-------------|
| **Bash** | 4.0+ | Shell requis (natif Linux/macOS, Git Bash Windows) |
| **npm** | 8.0+ | Pour l'installation du framework |

### Optionnels (Performance)

Ces outils sont détectés automatiquement à l'installation. Leur présence améliore les performances.

| Outil | Gain | Installation |
|-------|------|--------------|
| **Node.js** | +30% | Scripts async, JSON natif |
| **Bun** | +80% | Runtime ultra-rapide (remplace Node) |
| **jq** | +15% | Traitement JSON streaming |

### Niveaux de Performance

| Niveau | Configuration | Description |
|--------|---------------|-------------|
| **TURBO** 🚀 | Bash + Bun + jq | Performance maximale |
| **ENHANCED** ⚡ | Bash + Node + jq | Très bonnes performances |
| **STANDARD** | Bash + Node | Performances correctes |
| **BASIC** | Bash seul | Fonctionnel, performances de base |

> Voir [Installation](installation.md) pour les instructions detaillees par OS.

---

## Guides

### Pour Commencer

- [Getting Started](getting-started.md) - Premier pas avec Harmony
- [Installation](installation.md) - Installation complete
- [Concepts](concepts.md) - Comprendre les concepts cles

### Reference Technique

- [Architecture](architecture.md) - Architecture du framework
- [Architecture Reference](ARCHITECTURE-REFERENCE.md) - Reference complete architecture
- [Memory Architecture](memory-architecture.md) - **Modele memoire deux zones** (base read-only / `local/` mutable, ADR-010)
- [Library Reference](library-reference.md) - **Reference complete des bibliotheques bash** (ARIA, Circuit Breaker...)
- [How It Works](how-it-works.md) - Fonctionnement interne
- [Instruction Resilience](architecture/instruction-resilience.md) - Separation CLAUDE.md / .harmony, checksums, self-repair
- [Working Memory](working-memory.md) - Systeme de memoire
- [UCV Types](ucv-types.md) - **Classification des Use Case Verifiables** (Fonctionnel, Edge Case, Non-fonctionnel)
- [Context Persistence](context-persistence.md) - Persistance du contexte entre sessions
- [MCP AutoLearning](mcp-autolearning.md) - Apprentissage automatique via MCP servers
- [Overrides](overrides.md) - Personnalisation et surcharges
- [Natural Language Config](natural-language-config.md) - Configuration en langage naturel
- [Evolution](evolution.md) - Roadmap et evolution
- [Commands Reference](commands.md) - Reference rapide des commandes

### Guidelines

- [Documentation Guidelines](DOCUMENTATION-GUIDELINES.md) - Standards de documentation
- [README Technique](README-technical.md) - Details techniques

### Enterprise & Consulting

- [Enterprise & AI Consulting](enterprise.md) - Intégration sécurisée, sandboxing, agents spécialisés, optimisation LLM
- [Security Guards](security-guards.md) - Protection supply-chain + anti-injection LLM

---

## Bibliotheques

### Core Libraries

> Bibliotheques bash puissantes qui propulsent le framework.

**[Reference Complete des Bibliotheques →](library-reference.md)**

| Bibliotheque | Description |
|--------------|-------------|
| **ARIA Detector** | Detection automatique d'intent et contexte (Two-Stage: Pattern + LLM) |
| **Context Preloader** | Chargement securise avec state machine (anti-boucle infinie) |
| **Sprint Tracker** | Gestion sprint/story avec Autopilot Pipeline et Circuit Breaker |
| **Cost Tracker** | Suivi des couts API avec multi-devises (USD/EUR) |
| **Config Loader** | Configuration avec lazy caching et backward compatibility |

### Assistant Toolkit

> Modules pour le developpement assiste par IA.

**[Acceder au Assistant Toolkit →](assistant-toolkit.md)**

Inclut:
- Model Manager (aliases, tiers, estimation de cout)
- Auto Linter (detection langage, linting automatique)
- Repomap (cartographie du repository)
- File Watcher (detection de changements, hooks)
- History Summarizer (historique, compression de contexte)

### Prompt Monitor

> Dashboard temps-reel pour tracker et ameliorer vos interactions avec Claude.

**[Acceder au Prompt Monitor →](../commands/monitor.md)**

Inclut:
- Tracking automatique des prompts utilisateur et outils
- Scoring de clarte (0-100) et qualite de reponse
- Learning Mode avec insights et suggestions
- Estimation automatique des tokens et couts
- Categories d'alignement (OPTIMAL, IMPRESSIVE, PROBLEM, EXPECTED)

**Prerequis:** Python 3.8+ avec FastAPI, uvicorn, aiosqlite, pydantic

```bash
pip3 install -r .harmony/tools/prompt-monitor/requirements.txt
harmony monitor start
```

### Error Library

> Bibliotheque mondiale d'erreurs/solutions - AutoLearning collectif. Chargement JIT par agents.

**[Acceder a l'Error Library →](../error-library/README.md)**

Inclut:
- Erreurs versionnees (BASH-001, JS-001, etc.)
- Sync MCP Memory automatique
- Loader bash pour agents JIT

### Quality & Testing Knowledge

> Knowledge pour configurer des frameworks de test et assurer la qualite.

**[Acceder au Knowledge Quality →](../knowledge/domains/quality/)**

Inclut:
- **test-framework-setup.md** - Configuration Playwright/Cypress, fixtures, factories
- **atdd-patterns.md** - TDD red-green-refactor, acceptance testing
- **nfr-assessment.md** - Audit performance, securite, release readiness
- **traceability-patterns.md** - Matrices de couverture, requirements mapping

**Templates:**
- **CI Templates** - GitHub Actions et GitLab CI pour test automation
- **Quality Templates** - Matrices de tracabilite, rapports NFR, design de tests

**ARIA Detection:**
Les flags `needs_test_setup`, `needs_tdd`, `needs_ci_tests`, `needs_coverage`, `needs_nfr_audit` sont detectes automatiquement et routent vers les agents tester/devops/ucv-validator.

### Governance Modules (v1.1)

> 15 concepts de gouvernance avancée pour agents IA enterprise-grade.

**[Référence des Modules →](governance-reference.md)**

| Couche | Modules | Description |
|--------|---------|-------------|
| **Governance** | audit-trail, compliance-reporter | Traçabilité et conformité |
| **Intelligence** | confidence-scorer, agent-maturity, ab-testing | Mesure et évolution |
| **Context** | context-filter (FILCO), mesh-network | Optimisation et collaboration |
| **Safety** | data-sandbox, security-gates, anomaly-detector | Protection et détection |

**Patterns Cognitifs:**
- `emotional-prompting.md` - Engagement psychologique
- `meta-prompting.md` - Génération dynamique de prompts
- `self-evolving.md` - Amélioration continue LLM-as-Judge

**Tests:**
```bash
./tests/e2e/scripts/test.sh /path/to/project governance
```

### Patterns

> Bibliotheque de patterns pour la detection automatique et resolution rapide des problemes.

**[Acceder aux Patterns →](../patterns/INDEX.md)**

Inclut:
- 15 patterns documentes (dont P-021 à P-024 gouvernance)
- 7 patterns auto-detectables par Sentinel
- 3 patterns cognitifs (emotional, meta, self-evolving)
- Case studies avec benchmarks ROI

### Agents

> Agents specialises pour differents roles de developpement.

**Core Agents:**
- [Harmony Agent](../agents/harmony.md) - Agent principal
- [Developer Agent](../agents/developer.md) - Agent developpeur
- [Guardian Agent](../agents/guardian.md) - Protection et validation
- [Sentinel Agent](../agents/sentinel.md) - Memoire et apprentissage

**Specialists:**
- [UCV QA](../specialties/ucv/branchs/qa.md) - Validation UCV en browser
- [UCV Writer](../specialties/ucv/branchs/writer.md) - Creation UCVs
- [UCV Validator](../specialties/ucv/branchs/validator.md) - Verification 100%
- [Exploratory QA](../agents/exploratory-qa.md) - QA exploratoire

**Compliance:**
- [Accessibility](../agents/accessibility.md) - WCAG/RGAA/EAA
- [Security](../agents/security.md) - Audit securite
- [RGPD](../agents/rgpd.md) - Conformite GDPR

### Workflows

> Workflows pre-definis pour les taches courantes.

- Voir le dossier [workflows/](../workflows/)

### Routing

> Detection, routage et orchestration des agents.

- [Routing README](../routing/README.md) - Vue d'ensemble
- [Routing INDEX](../routing/INDEX.md) - Reference rapide
- [Detection Patterns](../routing/detection-patterns.yaml) - Keywords et scores
- [Routing Algorithm](../routing/routing-algorithm.yaml) - Algorithme de scoring

---

## Architecture Globale

```
harmony-framework/
├── README.md              ← Vous etes ici (via lien)
├── docs/
│   ├── INDEX.md           ← Point d'entree documentation
│   ├── INDEX-REFERENCE.md ← Reference rapide
│   ├── getting-started.md
│   ├── installation.md
│   ├── concepts.md
│   ├── architecture.md
│   └── ...
├── error-library/         ← AutoLearning erreurs/solutions
│   ├── README.md          ← Documentation + workflow
│   ├── errors/bash/       ← BASH-001 a BASH-00X
│   ├── schema/            ← JSON schema validation
│   └── tools/sync-mcp.sh  ← Sync vers MCP Memory
├── patterns/
│   ├── INDEX.md           ← Bibliotheque de patterns
│   ├── P-XXX-*.md         ← Patterns système
│   ├── case-studies/      ← Exemples concrets
│   └── cognitive/         ← Patterns de raisonnement (ReAct, Reflection...)
├── agents/
│   ├── INDEX.md           ← Index des agents
│   └── *.md               ← Tous les agents (flat structure)
├── specialties/
│   └── ai/                ← Specialty AI Systems
│       ├── manifest.yaml  ← Detection et config
│       └── knowledge/     ← RAG, Memory, Orchestration patterns
├── routing/               ← Detection et routage agents
│   ├── INDEX.md
│   ├── detection-patterns.yaml
│   └── routing-algorithm.yaml
├── workflows/             ← Workflows pre-definis
├── hooks/                 ← Hooks Sentinel
└── profiles/              ← Profils de langage
```

---

## Liens Externes

- [GitHub Repository](https://github.com/zied-jlassi/harmony-ai-framework)
- [Issues & Support](https://github.com/zied-jlassi/harmony-ai-framework/issues)

---

## Changelog

Voir [CHANGELOG.md](../CHANGELOG.md) pour l'historique des versions.
