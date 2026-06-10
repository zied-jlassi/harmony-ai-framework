# Harmony Agent Ecosystem

> **🌐 Language:** English · [Français](fr/agents.md)

> Complete reference for all Harmony agents and their roles.

---

## Overview

Harmony uses a multi-agent architecture where each agent has a specific role and phase of activation.

---

## Core Agents

| Agent | Persona | Role | Phase |
|-------|---------|------|:-----:|
| Guardian | - | Workflow protection, intent detection | All |
| Sentinel | - | Error memory, circuit breaker | All |
| Analyst | Analyst | Requirements analysis | 1-2 |
| Architect | Architect | Technical design, ADRs | 3 |
| Scrum Master | Scrum Master | Sprint management, story creation | 3-4 |
| Developer | Developer | Implementation | 4 |
| Tester | Tester | Quality assurance, test coverage | 4 |

---

## Specialist Agents

| Agent | Persona | Specialty |
|-------|---------|-----------|
| AI Architect | AI Architect | AI/LLM Architecture |
| Exploratory QA | Luna | Exploratory QA, user experience testing |
| UCV Writer | Clara | Creates Use Case Verifiables |
| UCV Validator | Victor | Validates 100% coverage |

### AI Architect Sub-Agents

The AI Architect has 6 specialized sub-agents for deep expertise:

| Sub-Agent | Persona | Focus |
|-----------|---------|-------|
| Riley | RAG Architect | RAG Pipelines, Vector DBs, Embedding |
| Oscar | Orchestration Architect | Multi-Agent, Supervisor, Handoff |
| Sage | Safety Architect | Guardrails, Hallucination Prevention |
| Milo | Memory Architect | 3-Tier Memory, Cognitive Architecture |
| Grace | GraphRAG Architect | Knowledge Graphs, Neo4j |
| Olivia | Observability Architect | Tracing, Evaluation, LangSmith |

---

## Compliance Agents

| Agent | Focus |
|-------|-------|
| RGPD Agent | GDPR compliance |
| Security Agent | Security audits |
| A11y Agent | Accessibility (WCAG/RGAA) |
| Pentest Agent | Penetration testing |

---

## Agent Activation

### Guardian Protocol

Guardian automatically routes to the right agent based on intent:

```
User: "develop the scoring system"
         ↓
┌─────────────────────────────────────┐
│    GUARDIAN INTENT DETECTION        │
├─────────────────────────────────────┤
│  Keywords: "develop", "scoring"     │
│  Intent: IMPLEMENT                  │
│  Context: Gaming                    │
│  Story Required: Yes                │
└─────────────────────────────────────┘
         ↓
    [Route to Developer Agent]
```

### Intent Mapping

| Intent | Keywords | Target Agent |
|--------|----------|--------------|
| IMPLEMENT | develop, code, implement | Developer |
| FIX | fix, bug, error | Developer |
| PLAN | story, sprint, plan | Scrum Master |
| TEST | test, coverage, TDD | Tester |
| EXPLORE_QA | QA, verify, check | Exploratory QA |
| ANALYZE | analyze, requirements | Analyst |
| DESIGN | architecture, ADR | Architect |

---

## Phase Workflow

```
Phase 1: Analysis
├── Analyst - Requirements gathering
└── Architect - Initial assessment

Phase 2: Planning
├── Analyst - PRD creation
└── Scrum Master - Story breakdown

Phase 3: Solutioning
├── Architect - Technical design
└── Scrum Master - Sprint planning

Phase 4: Implementation
├── Developer - Code implementation
├── Tester - Test coverage
└── Luna - Exploratory QA
```

---

## Invoking Agents

### Via Slash Commands (Skills)

```bash
/hf-agent-dev STORY-042       # Developer
/hf-agent-architect           # Architect
/hf-agent-sm                  # Scrum Master
/hf-agent-analyst             # Analyst
/hf-agent-tester              # Tester
```

### Via Workflows

```bash
/hf-workflow-dev-story STORY-042
/hf-workflow-sprint-planning
```

### Via Natural Language (Guardian Auto-Routing)

Guardian automatically detects intent and routes to the appropriate agent:

```
"develop STORY-042"           → Developer
"design the architecture"     → Architect
"plan the sprint"             → Scrum Master
"analyze requirements"        → Analyst
"test the login feature"      → Tester
```

---

## Related

- [Core Concepts](concepts.md)
- [Architecture](architecture.md)
- [Commands Reference](commands.md)
