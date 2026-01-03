# Harmony Framework - Index de Reference Rapide

> **Version**: 1.1.0
> **Date**: 2026-01-03
> **Status**: ✅ VALIDATED - Toutes les references verifiees
> **Purpose**: Navigation rapide dans le framework sans relecture

---

## Navigation Rapide par Besoin

| Je veux... | Fichier | Chemin |
|------------|---------|--------|
| **Creer une story** | Scrum Master | `agents/scrum-master.md` |
| **Implementer du code** | Developer | `agents/developer.md` |
| **Creer des UCVs** | UCV Writer | `agents/specialists/ucv-writer.md` |
| **Tester UCVs manuellement** | UCV QA | `agents/specialists/ucv-qa.md` |
| **Valider 100% UCVs** | UCV Validator | `agents/specialists/ucv-validator.md` |
| **Designer l'architecture** | Architect | `agents/architect.md` |
| **Analyser les besoins** | Analyst | `agents/analyst.md` |
| **Tester automatiquement** | Tester | `agents/tester.md` |
| **Tests exploratoires** | Exploratory QA | `agents/specialists/exploratory-qa.md` |
| **Concevoir RAG/IA** | AI Architect | `agents/specialists/ai-architect.md` |
| **Audit accessibilite** | Accessibility | `agents/compliance/accessibility.md` |
| **Audit securite** | Security | `agents/compliance/security.md` |

---

## Structure Agents - Reference Canonique

```
framework/agents/
|
+-- CORE AGENTS (Toujours charges)
|   +-- analyst.md           # Business Analyst
|   +-- architect.md         # Technical Architect
|   +-- developer.md         # Developer
|   +-- scrum-master.md      # Scrum Master (PAS specialists/sm.md!)
|   +-- tester.md            # QA Engineer
|   +-- guardian.md          # Intent Router
|   +-- harmony.md           # Framework Orchestrator
|   +-- sentinel.md          # Memory Manager
|   +-- atlas.md             # Clean Architecture
|   +-- product-manager.md   # Product Manager
|   +-- tech-writer.md       # Technical Writer
|   +-- ux-designer.md       # UX Designer
|   +-- quick-flow.md        # Rapid Dev Mode
|   +-- quick-flow-solo.md   # Solo Dev Mode
|   +-- backlog.md           # Backlog Dashboard
|   +-- review.md            # Code Review
|   +-- supervisor.md        # Multi-Agent Supervisor
|   +-- party.md             # Multi-Agent Brainstorming
|
+-- specialists/             # Agents specialises CORE
|   +-- exploratory-qa.md    # Luna - QA Exploratoire
|   +-- ai-architect.md      # Nova - AI/LLM Systems
|   +-- ucv-writer.md        # Clara - UCV Writer v2.0
|   +-- ucv-qa.md            # UCV QA - Manual browser testing
|   +-- ucv-validator.md     # Victor - UCV Validator v2.0
|   |
|   +-- sub-agents/          # Sous-agents de Nova UNIQUEMENT
|       +-- rag-architect.md         # Riley
|       +-- memory-architect.md      # Milo
|       +-- orchestration-architect.md # Oscar
|       +-- observability-architect.md # Olivia
|       +-- graphrag-architect.md    # Grace
|       +-- safety-architect.md      # Sage
|
+-- compliance/              # Agents conformite
|   +-- security.md          # Security Auditor
|   +-- accessibility.md     # Accessibility (WCAG/RGAA/EAA)
|   +-- rgpd.md              # RGPD/Privacy
|   +-- pentest.md           # Penetration Tester
|
+-- cognitive/               # Modules cognitifs
    +-- react.md             # ReAct Pattern
    +-- reflection.md        # Self-Reflection
    +-- self-consistency.md  # Multi-Path
    +-- lats.md              # Language Agent Tree Search
    +-- graph-of-thoughts.md # Graph-based Reasoning
```

---

## Specialties - Domaines Metier (Chargement JIT)

```
framework/specialties/
|
+-- gaming/                  # Projets gaming
|   +-- agents/architect.md  # REMPLACE agents/architect.md
|   +-- agents/developer.md  # REMPLACE agents/developer.md
|   +-- agents/designer.md   # NOUVEAU (game design)
|   +-- agents/scrum-master.md # REMPLACE scrum-master
|   +-- knowledge/           # Mecanique jeu, scoring
|   +-- patterns/            # ECS, state machine
|
+-- security/                # Projets security
|   +-- agents/
|   +-- modules/             # 14 modules pentest
|   +-- knowledge/           # OWASP Top 10
|
+-- creative/                # Projets design
|   +-- agents/              # 6 CIS agents
|   +-- knowledge/           # Brainstorming
|
+-- (medical, finance, devops, quality, ai, i18n, mobile, a11y, compliance)
```

---

## Profiles - Stack Technique (Chargement JIT)

```
framework/profiles/
|
+-- languages/               # Langages
|   +-- typescript/
|   +-- javascript/
|   +-- python/
|
+-- frontend/                # Frontend
|   +-- react/
|   +-- nextjs/
|   +-- react-native/
|
+-- backend/                 # Backend
|   +-- nestjs/
|   +-- express/
|   +-- fastify/
|
+-- databases/               # Databases
|   +-- prisma/
|   +-- mongodb/
|   +-- redis/
```

---

## Workflows - Reference Rapide

| Phase | Workflow | Fichier |
|-------|----------|---------|
| 1 | Discovery | `workflows/discovery.md` |
| 2 | Planning | `workflows/planning.md` |
| 3 | Solutioning | `workflows/solutioning.md` |
| 4 | Implementation | `workflows/implementation.md` |
| 4 | Story Lifecycle | `workflows/story-lifecycle.md` |
| 5 | Release | `workflows/release.md` |
| 5 | Retrospective | `workflows/rex.md` |

---

## Patterns - Reference Rapide

| ID | Nom | Usage |
|----|-----|-------|
| P-001 | Search Resource | POST pour filtres, zero params URL |
| P-005 | Closed-Loop Learning | Retour d'experience automatique |
| P-012 | Framework Guardian | Protection immutabilite framework |
| P-013 | Test Environment | Isolation bases test |

---

## Regles Architecture (R1-R5)

| Regle | Description |
|-------|-------------|
| **R1** | Pas de references croisees entre agents |
| **R2** | Noms descriptifs (pas de personas dans filename) |
| **R3** | Structure plate par categorie |
| **R4** | Specialties pour contenu domain-specific |
| **R5** | Knowledge packs au lieu de skills individuels |

---

## Commandes Harmony Rapides

```bash
# Agents
/hf:agent:sm [story-id]       # Scrum Master
/hf:agent:dev [story-id]      # Developer
/hf:agent:architect [topic]   # Architect
/hf:agent:ucv-writer [story]  # UCV Writer
/hf:agent:ucv-qa [story]      # UCV QA (browser testing)
/hf:agent:ucv-validator [story] # UCV Validator
/hf:agent:qa [module]         # Exploratory QA (Luna)

# Compliance
/accessibility [module]       # Audit WCAG/RGAA/EAA
/accessibility --wcag AA      # Niveau WCAG specifique
/security [module]            # Audit securite OWASP
/rgpd [module]                # Audit RGPD/GDPR

# Workflows
/hf:workflow:dev-story [story-id]  # Dev story
/hf:workflow:sprint-planning       # Sprint planning
/hf:workflow:code-review           # Code review

# Harmony
/harmony                       # Menu interactif
/harmony --mode sentinel       # Dashboard memoire
/harmony --mode ucv STORY-XXX  # Creer UCVs
/harmony --mode ucv --validate STORY-XXX  # Valider UCVs
```

---

## Fichiers Memoire

| Fichier | Description |
|---------|-------------|
| `.claude/memory/error-journal.json` | Journal erreurs |
| `.claude/memory/circuit-breaker.json` | Protection 3 retries |
| `.claude/memory/learned-patterns.json` | Patterns appris |
| `.claude/memory/workflow-state.json` | Etat workflow |

---

## HQVF - Cycle Qualite

```
1. SM cree story
2. UCV Writer (Clara) genere UCVs
3. USER approuve (GATE bloquant)
4. DEV implemente + coche [dev]
5. TEA teste + coche [test]
6. UCV QA valide en browser + coche [qa]
7. Luna exploration (OBLIGATOIRE) → Go/No-Go
8. UCV Validator verifie 100%
9. Story DONE
```

---

## Documents Reference Complets

| Document | Chemin | Description |
|----------|--------|-------------|
| Architecture | `docs/ARCHITECTURE-REFERENCE.md` | Reference complete architecture |
| Specialties vs Specialists | `research/STUDY-SPECIALTIES-VS-SPECIALISTS.md` | Pourquoi cette structure |
| Architecture Modulaire | `research/STUDY-ARCHITECTURE-MODULAIRE.md` | JIT loading, CV analogy |

---

*Index genere pour navigation rapide - evite la relecture multiple*
