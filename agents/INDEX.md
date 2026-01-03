# Harmony Framework - Agents Index

> **Version**: 1.1.0
> **Date**: 2026-01-03
> **Purpose**: Index complet de tous les agents du framework

---

## Vue d'Ensemble

Les agents Harmony sont organises en 4 categories:

| Categorie | Description | Chargement |
|-----------|-------------|------------|
| **Core** | Agents principaux toujours disponibles | Automatique |
| **Specialists** | Agents specialises pour taches specifiques | JIT |
| **Compliance** | Agents d'audit et conformite | A la demande |
| **Cognitive** | Modules de raisonnement avance | Optionnel |

---

## Core Agents

> Agents charges automatiquement au demarrage du framework.

| Agent | Fichier | Description |
|-------|---------|-------------|
| Harmony | [harmony.md](harmony.md) | Orchestrateur principal |
| Guardian | [guardian.md](guardian.md) | Intent router et protection |
| Sentinel | [sentinel.md](sentinel.md) | Memoire et apprentissage |
| Atlas | [atlas.md](atlas.md) | Clean Architecture |
| Analyst | [analyst.md](analyst.md) | Business Analyst |
| Architect | [architect.md](architect.md) | Technical Architect |
| Developer | [developer.md](developer.md) | Developer |
| Scrum Master | [scrum-master.md](scrum-master.md) | Scrum Master |
| Tester | [tester.md](tester.md) | QA Engineer |
| Product Manager | [product-manager.md](product-manager.md) | Product Manager |
| Tech Writer | [tech-writer.md](tech-writer.md) | Technical Writer |
| UX Designer | [ux-designer.md](ux-designer.md) | UX Designer |
| Quick Flow | [quick-flow.md](quick-flow.md) | Rapid Dev Mode |
| Quick Flow Solo | [quick-flow-solo.md](quick-flow-solo.md) | Solo Dev Mode |
| Backlog | [backlog.md](backlog.md) | Backlog Dashboard |
| Review | [review.md](review.md) | Code Review |
| Supervisor | [supervisor.md](supervisor.md) | Multi-Agent Supervisor |
| Party | [party.md](party.md) | Multi-Agent Brainstorming |

---

## Specialists

> Agents specialises charges a la demande (JIT).

| Agent | Fichier | Description | Invocation |
|-------|---------|-------------|------------|
| **UCV Writer** | [specialists/ucv-writer.md](specialists/ucv-writer.md) | Creation UCVs | `/ucv-writer STORY-XXX` |
| **UCV QA** | [specialists/ucv-qa.md](specialists/ucv-qa.md) | Validation UCV en browser | `/ucv-qa STORY-XXX` |
| **UCV Validator** | [specialists/ucv-validator.md](specialists/ucv-validator.md) | Verification 100% coverage | `/ucv-validator STORY-XXX` |
| **Exploratory QA** | [specialists/exploratory-qa.md](specialists/exploratory-qa.md) | Luna - QA Exploratoire | `/exploratory-qa [module]` |
| **AI Architect** | [specialists/ai-architect.md](specialists/ai-architect.md) | Nova - AI/LLM Systems | Contextuel |

### Sub-Agents (Nova)

> Sous-agents specialises de Nova pour l'architecture IA.

| Agent | Fichier | Domaine |
|-------|---------|---------|
| Riley | [specialists/sub-agents/rag-architect.md](specialists/sub-agents/rag-architect.md) | RAG Pipelines |
| Milo | [specialists/sub-agents/memory-architect.md](specialists/sub-agents/memory-architect.md) | Memory Systems |
| Oscar | [specialists/sub-agents/orchestration-architect.md](specialists/sub-agents/orchestration-architect.md) | Multi-Agent |
| Olivia | [specialists/sub-agents/observability-architect.md](specialists/sub-agents/observability-architect.md) | Observability |
| Grace | [specialists/sub-agents/graphrag-architect.md](specialists/sub-agents/graphrag-architect.md) | GraphRAG |
| Sage | [specialists/sub-agents/safety-architect.md](specialists/sub-agents/safety-architect.md) | Safety & Guardrails |

---

## Compliance

> Agents d'audit et conformite pour differentes normes.

| Agent | Fichier | Standards | Invocation |
|-------|---------|-----------|------------|
| **Accessibility** | [compliance/accessibility.md](compliance/accessibility.md) | WCAG 2.2, RGAA 4.1.2, EAA 2025 | `/accessibility [module]` |
| **Security** | [compliance/security.md](compliance/security.md) | OWASP Top 10 | `/security [module]` |
| **RGPD** | [compliance/rgpd.md](compliance/rgpd.md) | GDPR/RGPD | `/rgpd [module]` |
| **Pentest** | [compliance/pentest.md](compliance/pentest.md) | Security Testing | Contextuel |

---

## Cognitive

> Modules cognitifs pour raisonnement avance.

| Module | Fichier | Pattern |
|--------|---------|---------|
| ReAct | [cognitive/react.md](cognitive/react.md) | Reasoning + Acting |
| Reflection | [cognitive/reflection.md](cognitive/reflection.md) | Self-Reflection |
| Self-Consistency | [cognitive/self-consistency.md](cognitive/self-consistency.md) | Multi-Path Voting |
| LATS | [cognitive/lats.md](cognitive/lats.md) | Language Agent Tree Search |
| Graph of Thoughts | [cognitive/graph-of-thoughts.md](cognitive/graph-of-thoughts.md) | Graph-based Reasoning |

---

## Cycle HQVF (Quality Verification)

```
┌─────────────────────────────────────────────────────────────────┐
│                    STORY LIFECYCLE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Scrum Master    → Cree story                                │
│  2. UCV Writer      → Genere UCVs                               │
│  3. [USER]          → Approuve UCVs (GATE)                      │
│  4. Developer       → Implemente [dev]✓                         │
│  5. Tester          → Teste [test]✓                             │
│  6. UCV QA          → Valide en browser [qa]✓                   │
│  7. Exploratory QA  → Go/No-Go (OBLIGATOIRE)                    │
│  8. UCV Validator   → Verifie 100%                              │
│  9. Scrum Master    → Ferme story DONE                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Commandes Rapides

```bash
# Specialists
/ucv-writer STORY-XXX       # Creer UCVs
/ucv-qa STORY-XXX           # Valider en browser
/ucv-qa STORY-XXX --uc UC-002  # UCV specifique
/ucv-validator STORY-XXX    # Verifier 100%
/exploratory-qa [module]    # Session exploratoire

# Compliance
/accessibility [module]     # Audit WCAG/RGAA/EAA
/accessibility --wcag AA    # Niveau specifique
/security [module]          # Audit OWASP
/rgpd [module]              # Audit RGPD
```

---

## Related

- [INDEX-REFERENCE](../docs/INDEX-REFERENCE.md) - Reference rapide complete
- [Routing](../routing/INDEX.md) - Detection et routage
- [Workflows](../workflows/INDEX.md) - Workflows disponibles
- [Specialties](../specialties/INDEX.md) - Domaines metier
