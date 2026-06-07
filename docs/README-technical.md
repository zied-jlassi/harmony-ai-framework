# Harmony Framework - Technical Reference

> **Version technique détaillée du README original.**
>
> Ce document préserve toute la documentation technique originale
> développée durant la création du framework.

---

## Vue d'Ensemble Technique

Harmony est un **self-improving AI development framework** qui apporte structure, mémoire, et assurance qualité au développement assisté par IA. Contrairement aux frameworks traditionnels qui se concentrent uniquement sur l'orchestration LLM, Harmony crée un écosystème de développement complet qui:

- **Learn** - Apprend de ses erreurs et ne les répète jamais
- **Protect** - Protège le workflow avec des guardrails intelligents
- **Deliver** - Livre la qualité via des Use Cases vérifiables

---

## Architecture Détaillée

```
┌─────────────────────────────────────────────────────────────────┐
│                    HARMONY FRAMEWORK                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐        │
│   │  GUARDIAN   │    │  SENTINEL   │    │    HQVF     │        │
│   │  Protocol   │    │   System    │    │   Quality   │        │
│   ├─────────────┤    ├─────────────┤    ├─────────────┤        │
│   │ • Intent    │    │ • Error     │    │ • UCV       │        │
│   │   Detection │    │   Memory    │    │   Writer    │        │
│   │ • Agent     │    │ • Circuit   │    │ • UCV       │        │
│   │   Routing   │    │   Breaker   │    │   Validator │        │
│   │ • Workflow  │    │ • Pattern   │    │ • Coverage  │        │
│   │   Protection│    │   Learning  │    │   Tracking  │        │
│   └─────────────┘    └─────────────┘    └─────────────┘        │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │                   3-TIER MEMORY                          │  │
│   ├─────────────────────────────────────────────────────────┤  │
│   │  Working │ Session │ Long-term                          │  │
│   │  Memory  │ Memory  │ Memory                             │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Les Trois Piliers - Détail Complet

### 1. Guardian Protocol

Protège le workflow en détectant l'intention et routant vers l'agent correct.

```
User: "développe le scoring"
           ↓
    [Intent Detection]
           ↓
    Intent: IMPLEMENT
    Context: Gaming
    Story: STORY-026
           ↓
    [Route to Developer Agent]
```

**Table de routage:**

| Intent | Mots-clés | Agent | Prérequis |
|--------|-----------|-------|-----------|
| IMPLEMENT | développer, coder, implémenter, ajouter | Developer | Story DOIT exister |
| FIX | corriger, bug, erreur, problème | Developer | Story ou BUGFIX |
| PLAN | story, sprint, planifier, backlog | SM (Scrum Master) | Architecture existe |
| TEST | tester, test, coverage, TDD | TEA (Tester) | - |
| EXPLORE_QA | Exploratory QA, QA exploratoire | Exploratory QA | - |
| ANALYZE | analyser, besoin, comprendre | Analyst (Analyst) | - |
| DESIGN | architecture, ADR, structurer | Architect | PRD existe |
| UCV | UCV, use case, vérifications | UCV Writer | Story existe |
| AI | IA, RAG, LLM, mémoire | AI Architect + sub-agents | - |

### 2. Sentinel System

Garde la mémoire des erreurs pour ne pas les répéter.

```
┌─────────────────────────────────────────┐
│         CIRCUIT BREAKER                 │
├─────────────────────────────────────────┤
│ Failure 1 → Continue (1/3)              │
│ Failure 2 → Continue (2/3)              │
│ Failure 3 → CIRCUIT OPEN! 🛑            │
│                                         │
│ Diagnosis required before continuing    │
└─────────────────────────────────────────┘
```

**Fichiers mémoire:**

| Fichier | Description |
|---------|-------------|
| `error-journal.json` | Journal des erreurs avec patterns |
| `circuit-breaker.json` | État du circuit (CLOSED/OPEN) |
| `learned-patterns.json` | Patterns appris et validés |
| `anti-patterns.json` | Anti-patterns à éviter |

**Format Error Journal:**

```json
{
  "id": "ERR-XXX",
  "date": "YYYY-MM-DD",
  "category": "typescript|build|test|api|database|security",
  "severity": "low|medium|high|critical",
  "title": "[titre court]",
  "context": {
    "module": "[module]",
    "file": "[fichier]"
  },
  "symptom": "[description observable]",
  "root_cause": "[cause racine]",
  "correct_solution": "[solution appliquée]",
  "prevention_rule": "[règle pour éviter]",
  "tags": ["tag1", "tag2"]
}
```

### 3. HQVF (Harmony Quality Verification Framework)

Garantit la qualité via Use Cases Verifiables (UCV).

**Règles HQVF:**

| Règle | Description |
|-------|-------------|
| HQVF-1 | Jamais de dev sans UCV approuvé |
| HQVF-2 | Chaque story a un fichier UCV |
| HQVF-3 | User approuve UCVs avant dev |
| HQVF-4 | DEV coche chaque vérification |
| HQVF-5 | TEA écrit 1+ test par vérification |
| HQVF-6 | Exploratory QA valide chaque UCV |
| HQVF-7 | Story DONE = 100% UCVs validés |

**Format UCV:**

```yaml
story_id: STORY-042
title: "Modifier utilisateur via popin"
status: PENDING | APPROVED | REJECTED

use_cases:
  - id: UC-001
    title: "Ouvrir formulaire modification"
    gherkin: |
      Given je suis connecté en tant qu'admin
      And je suis sur la page liste utilisateurs
      When je clique sur l'icône crayon
      Then une popin modale s'affiche au centre

    verifications:
      - id: V-001-1
        description: "Popin visible centrée"
        dev: false   # ☐ à cocher par DEV
        test: false  # ☐ à cocher par TEA
        qa: false    # ☐ à cocher par Exploratory QA
```

---

## Écosystème des Agents

### Core Agents

| Agent | Persona | Rôle | Phase |
|-------|---------|------|-------|
| **Guardian** | - | Protection workflow | All |
| **Sentinel** | - | Mémoire erreurs | All |
| **Analyst** | Analyst | Analyse besoins | 1-2 |
| **Architect** | Architect | Design technique | 3 |
| **Developer** | Developer | Implémentation | 4 |
| **Tester** | Tester | Assurance qualité | 4 |
| **Scrum Master** | Scrum Master | Gestion sprint | 3-4 |

### Specialist Agents

| Agent | Persona | Spécialité |
|-------|---------|-----------|
| **AI Architect** | AI Architect | Architecture AI/LLM (+ 6 sub-agents) |
| **Exploratory QA** | Exploratory QA | QA Exploratoire |
| **UCV Writer** | UCV Writer | UCV Writer |
| **UCV Validator** | UCV Validator | UCV Validator |

### AI Architect's Sub-Agents (AI Specialists)

| Agent | Persona | Domaine |
|-------|---------|---------|
| **Riley** | Riley | Pipelines RAG, Vector DBs |
| **Milo** | Milo | Systèmes mémoire, 3-Tier |
| **Oscar** | Oscar | Orchestration multi-agent |
| **Olivia** | Olivia | Observabilité, tracing |
| **Grace** | Grace | GraphRAG, Knowledge Graphs |
| **Sage** | Sage | Safety & Guardrails |

### Compliance Agents

| Agent | Domaine |
|-------|---------|
| **Security** | Sécurité applicative |
| **Pentest** | Tests de pénétration |
| **RGPD** | Conformité données |
| **Accessibility** | WCAG, RGAA |

---

## Phases du Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ PHASE 1      PHASE 2      PHASE 3        PHASE 4      PHASE 5  │
│ Discovery    Planning     Solutioning    Implementation Release │
│                                                                 │
│ ┌─────┐     ┌─────┐      ┌─────┐        ┌─────┐      ┌─────┐  │
│ │Brief│ ──► │ PRD │ ──►  │Arch │  ──►   │ Dev │ ──►  │Deploy│  │
│ └─────┘     └─────┘      │Story│        │Test │      │Monitor│ │
│                          │ UCV │        │ QA  │      └─────┘  │
│                          └─────┘        └─────┘               │
│                                                                 │
│ Analyst     Analyst      Architect      Developer    DevOps    │
│             PM           SM             Tester                  │
│                          UX             Exploratory QA                    │
│                          UCV Writer          UCV Validator                  │
└─────────────────────────────────────────────────────────────────┘
```

**Phase Gates:**

| De | Vers | Prérequis |
|----|------|-----------|
| 1 → 2 | Discovery → Planning | Brief approuvé |
| 2 → 3 | Planning → Solutioning | PRD approuvé |
| 3 → 4 | Solutioning → Implementation | Architecture + Stories + UCVs |
| 4 → 5 | Implementation → Release | 100% UCV + Exploratory QA approved |

---

## Architecture Mémoire 3-Tier

```yaml
memory:
  tier_1_working:
    name: "Working Memory"
    location: "In-Context"
    size: "~2000 tokens (10-20% context)"
    persistence: "Current message"
    content:
      - Active task
      - Current persona
      - Immediate context
    refresh: "Every message"

  tier_2_session:
    name: "Session Memory"
    location: "External (compressed)"
    size: "Unlimited"
    persistence: "Current session"
    content:
      - Conversation history
      - Recent decisions
      - Sprint context
    compression: "Auto-summarize after 10 messages"

  tier_3_longterm:
    name: "Long-term Memory"
    location: "Persistent storage"
    size: "Unlimited"
    persistence: "Permanent"
    content:
      - Learned patterns
      - Error journal
      - User preferences
      - Architecture decisions
    retrieval: "Semantic search"
```

---

## Design Patterns

| Pattern | Description |
|---------|-------------|
| **P-001** | Hybrid Orchestration (Supervisor + Sequential + Parallel) |
| **P-002** | Three-Tier Memory Hierarchy |
| **P-003** | JIT Context Loading (charge à la demande) |
| **P-004** | Circuit Breaker Protection (3 retries max) |
| **P-005** | Closed-Loop Learning (Execute → Evaluate → Reflect → Store) |
| **P-006** | Intent Detection & Routing |
| **P-007** | Story-Based Development (jamais de dev sans story) |
| **P-008** | UCV Quality Gate (100% coverage obligatoire) |

---

## Rules Engine

| Règle | Description |
|-------|-------------|
| **R-001** | Never develop without a story |
| **R-002** | Strict role separation between agents |
| **R-003** | UCV must be approved before development |
| **R-004** | Exploratory QA (Exploratory QA) before release |
| **R-005** | 100% verification coverage for story completion |
| **R-006** | Handoff protocol between agents |
| **R-007** | Circuit breaker after 3 consecutive failures |

---

## Configuration

### harmony.config.js

```javascript
module.exports = {
  // Project info
  project: {
    name: 'my-project',
    language: 'en', // 'en' | 'fr'
  },

  // Guardian settings
  guardian: {
    enabled: true,
    mode: 'warn', // 'warn' | 'block'
    intents: ['implement', 'fix', 'test', 'analyze'],
  },

  // Sentinel settings
  sentinel: {
    enabled: true,
    circuitBreaker: {
      maxFailures: 3,
      cooldownMinutes: 5,
    },
  },

  // HQVF settings
  hqvf: {
    enabled: true,
    requireUcvApproval: true,
    coverageTarget: 100,
  },

  // Memory settings
  memory: {
    path: '.harmony/local/memory',
    persistErrors: true,
    persistPatterns: true,
  },

  // Agent settings
  agents: {
    enabled: ['analyst', 'architect', 'developer', 'tester'],
    specialists: ['ai-architect', 'exploratory-qa'],
  },
};
```

---

## Profiles & Specialties

### Tech Profiles (COMMENT construire)

```
profiles/
├── profiles-registry.yaml
├── languages/
│   ├── javascript/ (L0)
│   └── typescript/ (L0)
├── runtimes/
│   └── nodejs/     (L1)
├── backend/
│   └── nestjs/     (L2)
└── frontend/
    └── angular/    (L2)
```

**Niveaux de dépendance:**

| Level | Type | Exemples |
|-------|------|----------|
| L0 | Languages | javascript, typescript, python |
| L1 | Runtimes | nodejs, deno, bun |
| L2 | Frameworks | nestjs, angular, django |
| L3 | Meta/Tools | prisma, graphql, docker |

### Specialties (QUOI construire)

```
specialties/
└── gaming/
    ├── manifest.yaml        # 7 agents
    ├── agents/              # game-designer, game-ux...
    ├── patterns/            # ECS, state-machine
    └── knowledge/           # Via /harmony learn
```

**Specialties disponibles:**
- `gaming` - Jeux, gamification
- `medical` - Santé, HIPAA, HL7
- `fintech` - Finance, PCI-DSS
- `education` - E-learning, LMS
- `iot` - IoT, embedded
- `ecommerce` - E-commerce, payments

---

## Intégrations IDE

### Niveaux de support

| IDE | Support | Features |
|-----|---------|----------|
| **Claude Code** | Full | Hooks, Memory, MCP, Skills |
| **Cursor** | Good | Rules (.mdc), Personas |
| **Windsurf** | Good | Rules (.windsurfrules) |
| **Continue** | Good | Assistants, Context |
| **Cody** | Partial | Prompts |

### Feature Mapping

| Harmony Feature | Claude Code | Cursor | Windsurf |
|-----------------|-------------|--------|----------|
| Guardian | hooks/ | .mdc rules | rules section |
| Sentinel | memory/*.json | N/A | N/A |
| HQVF | CLAUDE.md | .mdc rules | rules section |
| Agents | Skills | Personas | Instructions |

---

## Acknowledgments

Harmony Framework s'appuie sur les meilleures pratiques de:
- Anthropic's Context Engineering research
- Microsoft's Multi-Agent patterns
- Google's ADK architecture
- Industry-standard DevOps practices
- Senior development workflows

---

## Related Documents

- [Evolution & Design Decisions](evolution.md)
- [Architecture](architecture.md)
- [Getting Started](getting-started.md)
- [Commands Reference](../commands/index.md)
