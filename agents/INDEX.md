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
| **UCV Writer** | [ucv-writer.md](ucv-writer.md) | Creation UCVs | `/hf:agent:ucv-writer STORY-XXX` |
| **UCV QA** | [ucv-qa.md](ucv-qa.md) | Validation UCV en browser | `/hf:agent:ucv-qa STORY-XXX` |
| **UCV Validator** | [ucv-validator.md](ucv-validator.md) | Verification 100% coverage | `/hf:agent:ucv-validator STORY-XXX` |
| **Exploratory QA** | [exploratory-qa.md](exploratory-qa.md) | QA Exploratoire | `/hf:agent:exploratory-qa [module]` |
| **AI Architect** | [ai-architect.md](ai-architect.md) | AI/LLM Systems | `/hf:agent:ai-architect` |

### AI Knowledge Domains

> Knowledge bases loaded by AI Architect for specialized domains.

| Domain | Fichier | Alias |
|--------|---------|-------|
| RAG Patterns | [../specialties/ai/knowledge/rag-patterns.md](../specialties/ai/knowledge/rag-patterns.md) | `/ai:riley` |
| Memory Patterns | [../specialties/ai/knowledge/memory-patterns.md](../specialties/ai/knowledge/memory-patterns.md) | `/ai:milo` |
| Orchestration Patterns | [../specialties/ai/knowledge/orchestration-patterns.md](../specialties/ai/knowledge/orchestration-patterns.md) | `/ai:oscar` |
| Observability Patterns | [../specialties/ai/knowledge/observability-patterns.md](../specialties/ai/knowledge/observability-patterns.md) | `/ai:olivia` |
| GraphRAG Patterns | [../specialties/ai/knowledge/graphrag-patterns.md](../specialties/ai/knowledge/graphrag-patterns.md) | `/ai:grace` |
| Safety Patterns | [../specialties/ai/knowledge/safety-patterns.md](../specialties/ai/knowledge/safety-patterns.md) | `/ai:sage` |

---

## Compliance

> Agents d'audit et conformite pour differentes normes.

| Agent | Fichier | Standards | Invocation |
|-------|---------|-----------|------------|
| **Accessibility** | [accessibility.md](accessibility.md) | WCAG 2.2, RGAA 4.1.2, EAA 2025 | `/hf:agent:accessibility [module]` |
| **Security** | [security.md](security.md) | OWASP Top 10 | `/hf:agent:security [module]` |
| **RGPD** | [rgpd.md](rgpd.md) | GDPR/RGPD | `/hf:agent:rgpd [module]` |
| **Pentest** | [pentest.md](pentest.md) | Security Testing | `/hf:agent:pentest` |

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
/hf:agent:ucv-writer STORY-XXX       # Creer UCVs
/hf:agent:ucv-qa STORY-XXX           # Valider en browser
/hf:agent:ucv-qa STORY-XXX --uc UC-002  # UCV specifique
/hf:agent:ucv-validator STORY-XXX    # Verifier 100%
/hf:agent:exploratory-qa [module]    # Session exploratoire
/hf:agent:ai-architect               # AI Systems Architecture

# AI Knowledge Domains (via AI Architect)
/ai:riley    # RAG Patterns
/ai:milo     # Memory Patterns
/ai:oscar    # Orchestration Patterns
/ai:olivia   # Observability Patterns
/ai:grace    # GraphRAG Patterns
/ai:sage     # Safety Patterns

# Compliance
/hf:agent:accessibility [module]     # Audit WCAG/RGAA/EAA
/hf:agent:accessibility --wcag AA    # Niveau specifique
/hf:agent:security [module]          # Audit OWASP
/hf:agent:rgpd [module]              # Audit RGPD
/hf:agent:pentest                    # Security Testing
```

---

## Related

- [INDEX-REFERENCE](../docs/INDEX-REFERENCE.md) - Reference rapide complete
- [Routing](../routing/INDEX.md) - Detection et routage
- [Workflows](../workflows/INDEX.md) - Workflows disponibles
- [Specialties](../specialties/INDEX.md) - Domaines metier
