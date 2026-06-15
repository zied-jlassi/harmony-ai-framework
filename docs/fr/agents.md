# Écosystème d'Agents Harmony

> **🌐 Langue :** [English](../agents.md) · Français

> Référence complète de tous les agents Harmony et de leurs rôles.

---

## Vue d'ensemble

Harmony utilise une architecture multi-agents où chaque agent a un rôle et une phase d'activation spécifiques.

---

## Agents Cœur

| Agent | Persona | Rôle | Phase |
|-------|---------|------|:-----:|
| Guardian | - | Protection du workflow, détection d'intention | Toutes |
| Sentinel | - | Mémoire d'erreurs, circuit breaker | Toutes |
| Analyst | Analyst | Analyse des exigences | 1-2 |
| Architect | Architect | Conception technique, ADRs | 3 |
| Scrum Master | Scrum Master | Gestion de sprint, création de stories | 3-4 |
| Developer | Developer | Implémentation | 4 |
| Tester | Tester | Assurance qualité, couverture de tests | 4 |

---

## Agents Spécialistes

| Agent | Persona | Spécialité |
|-------|---------|-----------|
| AI Architect | AI Architect | Architecture IA/LLM |
| Exploratory QA | Luna | QA exploratoire, test d'expérience utilisateur |
| UCV Writer | Clara | Crée les Use Case Verifiables |
| UCV Validator | Victor | Valide 100% de couverture |

### Sous-agents de l'AI Architect

L'AI Architect a 6 sous-agents spécialisés pour une expertise approfondie :

| Sous-agent | Persona | Focus |
|------------|---------|-------|
| Riley | RAG Architect | Pipelines RAG, Vector DBs, Embedding |
| Oscar | Orchestration Architect | Multi-Agent, Supervisor, Handoff |
| Sage | Safety Architect | Guardrails, prévention des hallucinations |
| Milo | Memory Architect | Mémoire 3 niveaux, architecture cognitive |
| Grace | GraphRAG Architect | Knowledge Graphs, Neo4j |
| Olivia | Observability Architect | Tracing, évaluation, LangSmith |

---

## Agents de Conformité

| Agent | Focus |
|-------|-------|
| RGPD Agent | Conformité GDPR |
| Security Agent | Audits de sécurité |
| A11y Agent | Accessibilité (WCAG/RGAA) |
| Pentest Agent | Tests d'intrusion |

---

## Activation des Agents

### Protocole Guardian

Guardian route automatiquement vers le bon agent selon l'intention :

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

### Mapping des Intentions

| Intention | Mots-clés | Agent cible |
|-----------|-----------|-------------|
| IMPLEMENT | develop, code, implement | Developer |
| FIX | fix, bug, error | Developer |
| PLAN | story, sprint, plan | Scrum Master |
| TEST | test, coverage, TDD | Tester |
| EXPLORE_QA | QA, verify, check | Exploratory QA |
| ANALYZE | analyze, requirements | Analyst |
| DESIGN | architecture, ADR | Architect |

---

## Workflow par Phase

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

## Invoquer les Agents

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

### Via Langage Naturel (Auto-routage Guardian)

Guardian détecte automatiquement l'intention et route vers l'agent approprié :

```
"develop STORY-042"           → Developer
"design the architecture"     → Architect
"plan the sprint"             → Scrum Master
"analyze requirements"        → Analyst
"test the login feature"      → Tester
```

---

## Liens connexes

- [Core Concepts](concepts.md)
- [Architecture](architecture.md)
- [Commands Reference](commands.md)
