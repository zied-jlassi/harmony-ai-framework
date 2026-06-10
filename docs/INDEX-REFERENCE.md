# Harmony Framework - Quick Reference Index

> **🌐 Language:** English · [Français](fr/INDEX-REFERENCE.md)

> **Version**: 1.1.0
> **Date**: 2026-01-03
> **Status**: ✅ VALIDATED - All references verified
> **Purpose**: Fast navigation in the framework without re-reading

---

## Quick Navigation by Need

| I want to... | File | Path |
|------------|---------|--------|
| **Create a story** | Scrum Master | `agents/scrum-master.md` |
| **Implement code** | Developer | `agents/developer.md` |
| **Create UCVs** | UCV Writer | `specialties/ucv/branchs/writer.md` |
| **Test UCVs manually** | UCV QA | `specialties/ucv/branchs/qa.md` |
| **Validate 100% of UCVs** | UCV Validator | `specialties/ucv/branchs/validator.md` |
| **Design the architecture** | Architect | `agents/architect.md` |
| **Analyze requirements** | Analyst | `agents/analyst.md` |
| **Test automatically** | Tester | `agents/tester.md` |
| **Exploratory testing** | Exploratory QA | `agents/exploratory-qa.md` |
| **Design RAG/AI** | AI Architect | `agents/ai-architect.md` |
| **Accessibility audit** | Accessibility | `agents/accessibility.md` |
| **Security audit** | Security | `agents/security.md` |

---

## Agent Structure - Canonical Reference

```
framework/agents/              # Structure plate - TOUS les agents au meme niveau
|
+-- CORE AGENTS
|   +-- analyst.md           # Business Analyst
|   +-- architect.md         # Technical Architect
|   +-- developer.md         # Developer
|   +-- scrum-master.md      # Scrum Master
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
+-- SPECIALISTS (dans agents/, pas de sous-dossier)
|   +-- exploratory-qa.md    # QA Exploratoire
|   +-- ai-architect.md      # AI/LLM Systems
|   +-- ucv-writer.md        # UCV Writer v2.0
|   +-- ucv-qa.md            # UCV QA - Manual browser testing
|   +-- ucv-validator.md     # UCV Validator v2.0
|
+-- COMPLIANCE (dans agents/, pas de sous-dossier)
    +-- security.md          # Security Auditor
    +-- accessibility.md     # Accessibility (WCAG/RGAA/EAA)
    +-- rgpd.md              # RGPD/Privacy
    +-- pentest.md           # Penetration Tester

framework/patterns/cognitive/  # Modules cognitifs (patterns raisonnement)
+-- react.md                   # ReAct Pattern
+-- reflection.md              # Self-Reflection
+-- self-consistency.md        # Multi-Path
+-- lats.md                    # Language Agent Tree Search
+-- graph-of-thoughts.md       # Graph-based Reasoning
```

### AI Knowledge (Specialties)

```
framework/specialties/ai/     # Specialty AI Systems
|
+-- manifest.yaml            # Detection (langchain, openai, etc.)
+-- knowledge/               # Knowledge bases (PAS des agents)
    +-- rag-patterns.md              # RAG Pipelines (/ai:riley)
    +-- memory-patterns.md           # Memory Systems (/ai:milo)
    +-- orchestration-patterns.md    # Multi-Agent (/ai:oscar)
    +-- observability-patterns.md    # LLM Observability (/ai:olivia)
    +-- graphrag-patterns.md         # GraphRAG (/ai:grace)
    +-- safety-patterns.md           # Safety & Guardrails (/ai:sage)
```

---

## Specialties - Business Domains (JIT Loading)

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

## Profiles - Tech Stack (JIT Loading)

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

## Workflows - Quick Reference

| Phase | Workflow | File |
|-------|----------|---------|
| 1 | Discovery | `workflows/discovery.md` |
| 2 | Planning | `workflows/planning.md` |
| 3 | Solutioning | `workflows/solutioning.md` |
| 4 | Implementation | `workflows/implementation.md` |
| 4 | Story Lifecycle | `workflows/story-lifecycle.md` |
| 5 | Release | `workflows/release.md` |
| 5 | Retrospective | `workflows/rex.md` |

---

## Patterns - Quick Reference

| ID | Name | Usage |
|----|-----|-------|
| P-001 | Search Resource | POST for filters, zero URL params |
| P-005 | Closed-Loop Learning | Automatic feedback loop |
| P-012 | Framework Guardian | Framework immutability protection |
| P-013 | Test Environment | Test database isolation |

---

## Architecture Rules (R1-R5)

| Rule | Description |
|-------|-------------|
| **R1** | No cross-references between agents |
| **R2** | Descriptive names (no personas in filename) |
| **R3** | Flat structure by category |
| **R4** | Specialties for domain-specific content |
| **R5** | Knowledge packs instead of individual skills |

---

## Quick Harmony Commands

```bash
# Agents
/hf:agent:sm [story-id]              # Scrum Master
/hf:agent:dev [story-id]             # Developer
/hf:agent:architect [topic]          # Architect
/hf:agent:ucv-writer [story]         # UCV Writer
/hf:agent:ucv-qa [story]             # UCV QA (browser testing)
/hf:agent:ucv-validator [story]      # UCV Validator
/hf:agent:exploratory-qa [module]    # Exploratory QA
/hf:agent:ai-architect               # AI Architect

# AI Architect (menu interactif)
/hf:agent:ai-architect               # Menu selection domaines (1-6 ou AnyThing)
/hf:agent:ai-architect "question"    # Auto-detect domaines selon question

# Compliance
/hf:agent:accessibility [module]  # Audit WCAG/RGAA/EAA
/hf:agent:accessibility --wcag AA # Niveau WCAG specifique
/hf:agent:security [module]       # Audit securite OWASP
/hf:agent:rgpd [module]           # Audit RGPD/GDPR
/hf:agent:pentest                 # Security Testing

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

## Memory Files

| File | Description |
|---------|-------------|
| `.harmony/local/memory/error-journal.json` | Error journal |
| `.harmony/local/memory/circuit-breaker.json` | 3-retry protection |
| `.harmony/local/memory/learned-patterns.json` | Learned patterns |
| `.harmony/local/memory/workflow-state.json` | Workflow state |

---

## HQVF - Quality Cycle

```
1. SM cree story
2. UCV Writer genere UCVs
3. USER approuve (GATE bloquant)
4. DEV implemente + coche [dev]
5. TEA teste + coche [test]
6. UCV QA valide en browser + coche [qa]
7. Exploratory QA (OBLIGATOIRE) → Go/No-Go
8. UCV Validator verifie 100%
9. Story DONE
```

---

## Complete Reference Documents

| Document | Path | Description |
|----------|--------|-------------|
| Architecture | `docs/ARCHITECTURE-REFERENCE.md` | Complete architecture reference |

---

*Index generated for fast navigation - avoids multiple re-reads*
