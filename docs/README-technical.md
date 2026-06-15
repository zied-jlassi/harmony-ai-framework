# Harmony Framework - Technical Reference

> **🌐 Language:** English · [Français](fr/README-technical.md)

> **Detailed technical version of the original README.**
>
> This document preserves all the original technical documentation
> developed during the creation of the framework.

---

## Technical Overview

Harmony is a **self-improving AI development framework** that brings structure, memory, and quality assurance to AI-assisted development. Unlike traditional frameworks that focus solely on LLM orchestration, Harmony builds a complete development ecosystem that:

- **Learn** - Learns from its mistakes and never repeats them
- **Protect** - Protects the workflow with intelligent guardrails
- **Deliver** - Delivers quality through verifiable Use Cases

---

## Detailed Architecture

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

## The Three Pillars - Full Detail

### 1. Guardian Protocol

Protects the workflow by detecting intent and routing to the correct agent.

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

**Routing table:**

| Intent | Keywords | Agent | Prerequisites |
|--------|-----------|-------|-----------|
| IMPLEMENT | develop, code, implement, add | Developer | A story MUST exist |
| FIX | fix, bug, error, problem | Developer | Story or BUGFIX |
| PLAN | story, sprint, plan, backlog | SM (Scrum Master) | Architecture exists |
| TEST | test, testing, coverage, TDD | TEA (Tester) | - |
| EXPLORE_QA | Exploratory QA | Exploratory QA | - |
| ANALYZE | analyze, requirement, understand | Analyst (Analyst) | - |
| DESIGN | architecture, ADR, structure | Architect | PRD exists |
| UCV | UCV, use case, verifications | UCV Writer | Story exists |
| AI | AI, RAG, LLM, memory | AI Architect + sub-agents | - |

### 2. Sentinel System

Keeps a memory of errors so they are not repeated.

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

**Memory files:**

| File | Description |
|---------|-------------|
| `error-journal.json` | Error journal with patterns |
| `circuit-breaker.json` | Circuit state (CLOSED/OPEN) |
| `learned-patterns.json` | Learned and validated patterns |
| `anti-patterns.json` | Anti-patterns to avoid |

**Error Journal format:**

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

Guarantees quality through Verifiable Use Cases (UCVs).

**HQVF rules:**

| Rule | Description |
|-------|-------------|
| HQVF-1 | Never develop without an approved UCV |
| HQVF-2 | Every story has a UCV file |
| HQVF-3 | The user approves UCVs before development |
| HQVF-4 | DEV checks off each verification |
| HQVF-5 | TEA writes 1+ test per verification |
| HQVF-6 | Exploratory QA validates each UCV |
| HQVF-7 | Story DONE = 100% of UCVs validated |

**UCV format:**

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

## Agent Ecosystem

### Core Agents

| Agent | Persona | Role | Phase |
|-------|---------|------|-------|
| **Guardian** | - | Workflow protection | All |
| **Sentinel** | - | Error memory | All |
| **Analyst** | Analyst | Requirements analysis | 1-2 |
| **Architect** | Architect | Technical design | 3 |
| **Developer** | Developer | Implementation | 4 |
| **Tester** | Tester | Quality assurance | 4 |
| **Scrum Master** | Scrum Master | Sprint management | 3-4 |

### Specialist Agents

| Agent | Persona | Specialty |
|-------|---------|-----------|
| **AI Architect** | AI Architect | AI/LLM architecture (+ 6 sub-agents) |
| **Exploratory QA** | Exploratory QA | Exploratory QA |
| **UCV Writer** | UCV Writer | UCV Writer |
| **UCV Validator** | UCV Validator | UCV Validator |

### AI Architect's Sub-Agents (AI Specialists)

| Agent | Persona | Domain |
|-------|---------|---------|
| **Riley** | Riley | RAG pipelines, Vector DBs |
| **Milo** | Milo | Memory systems, 3-Tier |
| **Oscar** | Oscar | Multi-agent orchestration |
| **Olivia** | Olivia | Observability, tracing |
| **Grace** | Grace | GraphRAG, Knowledge Graphs |
| **Sage** | Sage | Safety & Guardrails |

### Compliance Agents

| Agent | Domain |
|-------|---------|
| **Security** | Application security |
| **Pentest** | Penetration testing |
| **RGPD** | Data compliance |
| **Accessibility** | WCAG, RGAA |

---

## Workflow Phases

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

| From | To | Prerequisites |
|----|------|-----------|
| 1 → 2 | Discovery → Planning | Brief approved |
| 2 → 3 | Planning → Solutioning | PRD approved |
| 3 → 4 | Solutioning → Implementation | Architecture + Stories + UCVs |
| 4 → 5 | Implementation → Release | 100% UCV + Exploratory QA approved |

---

## 3-Tier Memory Architecture

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
| **P-003** | JIT Context Loading (load on demand) |
| **P-004** | Circuit Breaker Protection (3 retries max) |
| **P-005** | Closed-Loop Learning (Execute → Evaluate → Reflect → Store) |
| **P-006** | Intent Detection & Routing |
| **P-007** | Story-Based Development (never develop without a story) |
| **P-008** | UCV Quality Gate (100% coverage required) |

---

## Rules Engine

| Rule | Description |
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

### Tech Profiles (HOW to build)

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

**Dependency levels:**

| Level | Type | Examples |
|-------|------|----------|
| L0 | Languages | javascript, typescript, python |
| L1 | Runtimes | nodejs, deno, bun |
| L2 | Frameworks | nestjs, angular, django |
| L3 | Meta/Tools | prisma, graphql, docker |

### Specialties (WHAT to build)

```
specialties/
└── gaming/
    ├── manifest.yaml        # 7 agents
    ├── agents/              # game-designer, game-ux...
    ├── patterns/            # ECS, state-machine
    └── knowledge/           # Via /harmony learn
```

**Available specialties:**
- `gaming` - Games, gamification
- `medical` - Healthcare, HIPAA, HL7
- `fintech` - Finance, PCI-DSS
- `education` - E-learning, LMS
- `iot` - IoT, embedded
- `ecommerce` - E-commerce, payments

---

## IDE Integrations

### Support levels

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

The Harmony Framework draws on the best practices of:
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
