# Harmony Framework - Architecture Reference

> **Version**: 1.0.0
> **Date**: 2026-01-03
> **Status**: AUTHORITATIVE
> **Purpose**: Document de référence définitif pour l'architecture Harmony

---

## Table des Matières

1. [Philosophie Harmony](#1-philosophie-harmony)
2. [Règles d'Architecture](#2-règles-darchitecture)
3. [Hiérarchie des Agents](#3-hiérarchie-des-agents)
4. [Specialties vs Profiles](#4-specialties-vs-profiles)
5. [Framework vs User Space](#5-framework-vs-user-space)
6. [Systèmes Uniques Harmony](#6-systèmes-uniques-harmony)
7. [Duplications et Résolutions](#7-duplications-et-résolutions)

---

## 1. Philosophie Harmony

### Motto
```
"Learn. Protect. Deliver."
```

### Différence avec BMAD

| Aspect | BMAD | Harmony |
|--------|------|---------|
| **Focus** | Workflow orchestration | Quality + Memory |
| **Mémoire** | Aucune persistante | Sentinel (error-journal, patterns) |
| **Protection** | Aucune | Guardian (intent routing, circuit breaker) |
| **Qualité** | Tests classiques | HQVF (UCVs obligatoires) |
| **Agents** | Personas avec noms | Descriptifs fonctionnels |

### Coexistence BMAD + Harmony

```
BMAD → Orchestration des workflows (Discovery → Release)
Harmony → Qualité + Mémoire + Protection

Résultat combiné: 97% completion stories (benchmark interne)
```

---

## 2. Règles d'Architecture

### R1: Pas de références croisées entre agents

```
❌ INTERDIT:
agents/developer.md → "voir aussi agents/tester.md"

✅ AUTORISÉ:
agents/developer.md → "voir workflows/implementation.md"
```

**Raison**: Chaque agent est autonome. Les workflows orchestrent, pas les agents.

### R2: Noms descriptifs (pas de personas)

```
❌ INTERDIT:
agents/bob-scrum-master.md
agents/amelia-developer.md

✅ AUTORISÉ:
agents/scrum-master.md
agents/developer.md
```

**Raison**: Les personas sont DANS le fichier, pas dans le nom. Facilite la maintenance.

### R3: Structure plate par catégorie

```
agents/                     # Structure PLATE - tous les agents au même niveau
├── [core agents]           # analyst, architect, developer, etc.
├── [specialists]           # ai-architect, exploratory-qa, ucv-*, etc.
├── [compliance]            # security, rgpd, pentest, accessibility
└── cognitive/              # Exception: patterns de raisonnement
    └── react.md, reflection.md, lats.md, etc.

specialties/ai/             # Knowledge AI (pas des agents)
├── manifest.yaml           # Detection (langchain, openai, etc.)
└── knowledge/              # Patterns RAG, Memory, Orchestration...
```

**Raison**: Navigation prévisible. Pas de nesting infini. AI knowledge dans specialties/.

### R4: Specialties pour contenu domain-specific

```
specialties/
├── gaming/
│   ├── agents/             # game-developer.md, game-designer.md
│   └── knowledge/          # game-mechanics.md, scoring-systems.md
├── security/
│   ├── agents/
│   └── knowledge/
└── creative/
    ├── agents/
    └── knowledge/
```

**Raison**: Isolation totale. Un projet gaming charge SEULEMENT gaming/, pas security/.

### R5: Knowledge packs au lieu de skills individuels

```
❌ INTERDIT:
skills/
├── nestjs-setup.md
├── nestjs-guards.md
├── nestjs-interceptors.md
└── ... (500 fichiers)

✅ AUTORISÉ:
profiles/
└── nestjs/
    └── nestjs-knowledge.md  # Un fichier consolidé, chargeable à la demande
```

**Raison**: JIT loading. Charge le pack quand nécessaire, pas 500 fichiers.

---

## 3. Hiérarchie des Agents

### Vue d'ensemble

```
framework/agents/
│
├── [CORE AGENTS - 18 agents]
│   ├── analyst.md           # Business Analyst (Mary)
│   ├── architect.md         # Technical Architect (Winston)
│   ├── developer.md         # Developer (Amelia)
│   ├── tester.md            # QA Engineer (Emma)
│   ├── scrum-master.md      # Scrum Master (Bob) ← VERSION RICHE
│   ├── product-manager.md   # Product Manager (Olivia)
│   ├── tech-writer.md       # Technical Writer
│   ├── ux-designer.md       # UX Designer (Evan)
│   ├── guardian.md          # Intent Router + Circuit Breaker
│   ├── harmony.md           # Framework Orchestrator
│   ├── sentinel.md          # Memory Manager (error-journal)
│   ├── atlas.md             # Clean Architecture Validator
│   ├── quick-flow.md        # Rapid Development Mode
│   ├── quick-flow-solo.md   # Solo Dev Mode
│   ├── backlog.md           # Backlog Dashboard
│   ├── review.md            # Code Review
│   ├── supervisor.md        # Multi-Agent Supervisor
│   └── party.md             # Multi-Agent Brainstorming
│
├── [SPECIALISTS - au même niveau, pas de sous-dossier]
│   ├── exploratory-qa.md    # Luna - QA Exploratoire
│   ├── ai-architect.md      # Nova - AI/LLM Systems
│   ├── ucv-writer.md        # Clara - UCV Writer v2.0
│   ├── ucv-validator.md     # Victor - UCV Validator v2.0
│   └── ucv-qa.md            # UCV QA - Browser validation
│
├── [COMPLIANCE - au même niveau, pas de sous-dossier]
│   ├── security.md          # Security Auditor
│   ├── accessibility.md     # WCAG/RGAA/EAA
│   ├── rgpd.md              # RGPD/Privacy Expert
│   └── pentest.md           # Penetration Tester
│
└── cognitive/               # [5 modules cognitifs]
    ├── react.md             # ReAct Pattern
    ├── reflection.md        # Self-Reflection
    ├── self-consistency.md  # Multi-Path Verification
    ├── lats.md              # Language Agent Tree Search
    └── graph-of-thoughts.md # Graph-based Reasoning
```

### Quand utiliser quel agent

| Besoin | Agent | Fichier |
|--------|-------|---------|
| Analyser requirements | Analyst | `agents/analyst.md` |
| Designer architecture | Architect | `agents/architect.md` |
| Implémenter code | Developer | `agents/developer.md` |
| Écrire tests automatisés | Tester | `agents/tester.md` |
| Planifier sprints/stories | Scrum Master | `agents/scrum-master.md` |
| Tests exploratoires UI | Luna | `agents/exploratory-qa.md` |
| Créer UCVs | Clara | `agents/ucv-writer.md` |
| Valider UCVs | Victor | `agents/ucv-validator.md` |
| Concevoir RAG | Riley | `specialties/ai/knowledge/rag-patterns.md` |
| Concevoir mémoire | Milo | `specialties/ai/knowledge/memory-patterns.md` |
| Multi-agents | Oscar | `specialties/ai/knowledge/orchestration-patterns.md` |

---

## 4. Specialties vs Profiles

### Specialties = Domaine métier

**Chargement**: Au démarrage projet, basé sur `project_type`

```yaml
# .harmony/local/config.yaml
project:
  type: gaming  # → Charge specialties/gaming/

# Résultat:
# - agents/game-developer.md disponible
# - agents/game-designer.md disponible
# - knowledge/game-mechanics.md disponible
```

**Exemples de Specialties**:
- `gaming/` - Jeux, scores, leaderboards
- `security/` - Pentest, hardening, compliance
- `creative/` - Design, UX, branding
- `medical/` - HIPAA, données patients
- `finance/` - PCI-DSS, transactions

### Profiles = Stack technique

**Chargement**: JIT (Just-In-Time), à la demande

```yaml
# .harmony/local/config.yaml
profiles:
  - nestjs
  - prisma
  - react

# Résultat:
# Chargé SEULEMENT quand Claude travaille sur ce stack
```

**Exemples de Profiles**:
- `nestjs/` - Guards, interceptors, modules
- `prisma/` - Migrations, schema, queries
- `react/` - Hooks, components, state
- `angular/` - Services, modules, RxJS
- `docker/` - Compose, Dockerfile, networks

### Différence clé

| Aspect | Specialty | Profile |
|--------|-----------|---------|
| **Quand** | Au démarrage | À la demande |
| **Scope** | Domaine métier | Stack technique |
| **Contenu** | Agents + Knowledge | Knowledge only |
| **Exemple** | "Ce projet est un jeu" | "Ce fichier utilise NestJS" |

---

## 5. Framework vs User Space

### Protection P-012 (Framework Guardian)

```
.harmony/
│
├── [FRAMEWORK - IMMUTABLE AFTER INSTALL]
│   ├── agents/              # ❌ Écriture interdite
│   ├── workflows/           # ❌ Écriture interdite
│   ├── patterns/            # ❌ Écriture interdite
│   ├── templates/           # ❌ Écriture interdite
│   ├── docs/                # ❌ Écriture interdite (framework docs)
│   └── bin/                 # ❌ Écriture interdite
│
└── local/                   # ✅ USER SPACE (mutable)
    ├── overrides/
    │   ├── agents/          # Custom agents
    │   └── hooks/           # Custom hooks
    ├── project/
    │   ├── backlog/         # Stories, epics
    │   ├── prd/             # PRD documents
    │   ├── architecture/    # ADRs
    │   └── rex/             # Retrospectives
    └── config.yaml          # Project config
```

### Hook Guardian

Le hook `.claude/hooks/guardian-checkpoint.sh` bloque automatiquement:
- Toute écriture dans `.harmony/agents/`
- Toute écriture dans `.harmony/workflows/`
- Modifications framework sans override explicite

### Comment customiser

```bash
# ❌ INTERDIT - Modifier directement
Edit .harmony/agents/developer.md

# ✅ AUTORISÉ - Créer un override
Write .harmony/local/overrides/agents/developer.md
# → L'override sera chargé EN PRIORITÉ sur le framework
```

---

## 6. Systèmes Uniques Harmony

### Sentinel (Mémoire persistante)

```
.claude/memory/
├── error-journal.json       # Journal des erreurs avec patterns
├── circuit-breaker.json     # État protection (3 retries max)
├── learned-patterns.json    # Patterns appris et validés
└── anti-patterns.json       # Anti-patterns à éviter
```

**Commandes**:
```bash
/harmony --mode sentinel            # Dashboard
/harmony --mode sentinel --learn    # Documenter erreur
/harmony --mode sentinel --reset    # Reset circuit breaker
```

### Guardian (Routage intelligent)

```
┌─────────────────────────────────────────┐
│         GUARDIAN PROTOCOL               │
├─────────────────────────────────────────┤
│                                         │
│  USER MESSAGE                           │
│       ↓                                 │
│  [Intent Detection]                     │
│  "corriger bug" → Intent: FIX           │
│       ↓                                 │
│  [Context Detection]                    │
│  "leaderboard" → Context: GAMING        │
│       ↓                                 │
│  [Story Check]                          │
│  Existe-t-il une story?                 │
│       ↓                                 │
│  [Route to Agent]                       │
│  Developer (gaming context)             │
│                                         │
└─────────────────────────────────────────┘
```

### HQVF (Quality Verification Framework)

```
STORY-XXX.md
     ↓
UCV Writer (Clara) crée STORY-XXX-UCV.md
     ↓
User APPROUVE les UCVs (Gate bloquant)
     ↓
Developer implémente + coche [dev]
     ↓
Tester teste + coche [test]
     ↓
Luna valide + coche [qa]
     ↓
UCV Validator vérifie 100%
     ↓
Story DONE
```

**Format UCV**:
```yaml
use_cases:
  - id: UC-001
    title: "Ouvrir formulaire modification"
    verifications:
      - id: V-001-1
        description: "Popin visible centrée"
        dev: false   # ☐ à cocher par DEV
        test: false  # ☐ à cocher par TEA
        qa: false    # ☐ à cocher par Luna
```

---

## 7. Structure Actuelle (Post-Restructure 2026-01)

### Restructuration effectuée ✅

La structure agents a été aplatie. Tous les agents sont maintenant au même niveau dans `agents/`:

| Ancien Chemin | Nouveau Chemin | Status |
|---------------|----------------|--------|
| `agents/specialists/*.md` | `agents/*.md` | ✅ Déplacé |
| `agents/compliance/*.md` | `agents/*.md` | ✅ Déplacé |
| `agents/specialists/sub-agents/*.md` | `specialties/ai/knowledge/*-patterns.md` | ✅ Déplacé |

### AI Knowledge (pas des agents)

Les sous-agents AI ont été renommés en **knowledge files** dans `specialties/ai/knowledge/`:

| Ancien | Nouveau | Commande |
|--------|---------|----------|
| `rag-architect.md` | `rag-patterns.md` | `/ai:riley` |
| `memory-architect.md` | `memory-patterns.md` | `/ai:milo` |
| `orchestration-architect.md` | `orchestration-patterns.md` | `/ai:oscar` |
| `observability-architect.md` | `observability-patterns.md` | `/ai:olivia` |
| `graphrag-architect.md` | `graphrag-patterns.md` | `/ai:grace` |
| `safety-architect.md` | `safety-patterns.md` | `/ai:sage` |

### Règle pour le futur

```
AVANT de créer un nouvel agent:
1. Vérifier qu'il n'existe pas déjà dans agents/
2. Placer DIRECTEMENT dans agents/ (pas de sous-dossier)
3. Exception: cognitive/ pour les patterns de raisonnement
4. Suivre R1-R5
5. Mettre à jour ce document
```

---

## Annexe: Fichiers Clés

| Fichier | Description |
|---------|-------------|
| `framework/docs/ARCHITECTURE-REFERENCE.md` | Ce document |
| `research/HARMONY-FRAMEWORK-ARCHITECT-BRIEF.md` | Brief architecte complet |
| `research/EXPORT-PLAN-bmadV2-to-harmony.md` | Plan migration BMAD → Harmony |
| `research/ARCH-001-framework-protection-structure.md` | Pattern P-012 détaillé |
| `patterns/P-012-framework-guardian.md` | Pattern protection framework |
| `patterns/P-013-test-environment-isolation.md` | Pattern isolation tests |

---

*Document généré automatiquement. Dernière mise à jour: 2026-01-03*
