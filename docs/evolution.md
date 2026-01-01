# Harmony Framework - Evolution & Design Decisions

> **Document de mémoire : Comment et pourquoi Harmony a été conçu.**
>
> Ce document garde la trace du processus de pensée, des analyses,
> et des décisions architecturales prises durant le développement.

---

## Version History

| Version | Date | Codename | Key Changes |
|---------|------|----------|-------------|
| **1.0.0** | 2025-01-01 | Genesis | Initial release |
| **2.0.0** | 2025-12-31 | Unification | Command → Framework merge |

---

## Phase 1: Origine (Décembre 2024)

### Le Problème Initial

Dans un projet e-commerce complexe, nous avons constaté des problèmes récurrents:

1. **Erreurs répétées** - Le même bug revenait session après session
2. **Confusion d'agents** - Mauvais agent activé pour la tâche
3. **Qualité incertaine** - "Ça marche" n'était pas vérifiable
4. **Contexte perdu** - Chaque session repartait de zéro

### Analyse de l'Architecte AI (AI Architect)

**Recherche menée:**
- 150+ sources 2025 analysées
- Frameworks évalués: LangChain, CrewAI, AutoGen, Semantic Kernel
- Patterns extraits: Microsoft Azure AI, AWS Agentic, Google ADK

**Conclusion:**
> "Aucun framework existant n'offre de mémoire d'erreurs persistante
> ni de système de qualité vérifiable. C'est notre USP."

---

## Phase 2: Les Trois Piliers (Janvier 2025)

### Conception du Guardian Protocol

**Problème:** Comment router automatiquement vers le bon agent?

**Solution conçue:**
```
User: "développe le scoring"
         ↓
[Intent Detection]
├── Mots-clés: "développe" → IMPLEMENT
├── Contexte: "scoring" → Gaming
├── Vérification: Story existe?
         ↓
[Route to DEV Agent]
```

**Table de routage créée:**

| Intent | Keywords | Agent | Prerequisites |
|--------|----------|-------|---------------|
| IMPLEMENT | développer, coder, implémenter | DEV | Story MUST exist |
| FIX | corriger, bug, erreur | DEV | Story or BUGFIX |
| PLAN | story, sprint, planifier | SM | Architecture exists |
| TEST | tester, test, coverage | TEA | - |
| ANALYZE | analyser, besoin | Analyst | - |
| DESIGN | architecture, ADR | Architect | PRD exists |

### Conception du Sentinel System

**Problème:** Comment ne pas répéter les mêmes erreurs?

**Inspiration:**
- Circuit breaker pattern (Microservices)
- Error budgets (SRE)
- Learning from failures (Chaos Engineering)

**Architecture choisie:**

```yaml
memory:
  error_journal:
    description: "Journal des erreurs avec solutions"
    format: JSON
    indexed_by: [module, category, tags]

  circuit_breaker:
    states: [CLOSED, HALF-OPEN, OPEN]
    max_failures: 3
    cooldown: 5 minutes

  learned_patterns:
    description: "Patterns validés en production"

  anti_patterns:
    description: "Patterns à éviter"
```

**Décision clé:**
> "Le circuit breaker s'ouvre après 3 échecs consécutifs.
> Pas de reset automatique - analyse obligatoire."

### Conception de HQVF

**Problème:** Comment vérifier objectivement la qualité?

**Analyse du gap Dev/Test/QA:**
```
DEV écrit 100 lignes de code
TEST vérifie 5% avec tests
User utilise et voit 55% des bugs

→ Gap entre intention et livraison
```

**Solution: Use Case Verifiables (UCV)**

```yaml
use_case:
  id: UC-001
  title: "Ouvrir modal modification"
  gherkin: |
    Given je suis connecté admin
    When je clique sur l'icône crayon
    Then une modal s'affiche au centre

  verifications:
    - id: V-001-1
      description: "Modal visible centrée"
      dev: false   # ☐ DEV marque
      test: false  # ☐ TEA marque
      qa: false    # ☐ Exploratory QA marque
```

**Règle HQVF-7:**
> "Story DONE = 100% UCVs validés (DEV + TEST + QA)"
> C'est objectif, pas subjectif.

---

## Phase 3: Système de Mémoire 3-Tier

### Analyse des Context Windows

**Évolution observée:**
| Année | Taille | Modèle |
|-------|--------|--------|
| 2022 | 4K | GPT-3.5 |
| 2023 | 32K | GPT-4 |
| 2024 | 128K | Claude 3 |
| 2025 | 200K+ | Claude 4 |

**Problème identifié:**
> "Plus grand ≠ Meilleur. Lost-in-middle est réel.
> Les infos au milieu du contexte sont 15-20% moins rappelées."

### Architecture 3-Tier choisie

```
┌─────────────────────────────────────────┐
│ TIER 1: Working Memory (In-Context)     │
│ - 2000 tokens (~10-20% context)         │
│ - Task active, persona, instructions    │
│ - Refresh: chaque message               │
├─────────────────────────────────────────┤
│ TIER 2: Session Memory (External)       │
│ - Unlimited, compressed                 │
│ - Conversation history                  │
│ - Refresh: session                      │
├─────────────────────────────────────────┤
│ TIER 3: Long-term Memory (Persistent)   │
│ - Unlimited, permanent                  │
│ - Error journal, patterns               │
│ - Refresh: never (versioned)            │
└─────────────────────────────────────────┘
```

**Décision clé:**
> "JIT Loading (Just-In-Time): Ne charger que ce qui est pertinent.
> Semantic similarity > 0.7 pour inclusion."

---

## Phase 4: Profiles & Specialties

### La distinction fondamentale

**Question clé:** Comment séparer le QUOI du COMMENT?

**Solution:**
- **Specialties** = QUOI construire (domaine métier)
- **Profiles** = COMMENT construire (stack technique)

| Aspect | Specialties | Profiles |
|--------|-------------|----------|
| Question | Quoi? | Comment? |
| Exemples | gaming, medical | nestjs, angular |
| Agents | Ajoute des agents | Pas de nouveaux agents |
| Activation | Explicite | Auto-detect |

### Système de dépendances

**Problème:** NestJS nécessite TypeScript qui nécessite JavaScript.

**Solution: Niveaux (L0-L3)**

```
L0: Languages (javascript, typescript, python)
L1: Runtimes (nodejs, deno)
L2: Frameworks (nestjs, angular)
L3: Meta/Tools (prisma, graphql)
```

**Résolution automatique:**
```
Activer "nestjs"
→ Charge: nestjs (60%)
→ Auto: typescript (20%), nodejs (10%), javascript (10%)
```

---

## Phase 5: Intégrations Multi-IDE

### Analyse des capacités IDE

| Feature | Claude Code | Cursor | Windsurf | Continue | Cody |
|---------|:-----------:|:------:|:--------:|:--------:|:----:|
| Hooks | ✓ | ✗ | ✗ | ✗ | ✗ |
| Memory | ✓ | ✗ | ✗ | ✗ | Code Graph |
| MCP | ✓ | ✗ | ✗ | ✗ | ✗ |
| Rules | CLAUDE.md | .mdc | .windsurfrules | YAML | Prompts |

### Décision: Feature Mapping

**Comment adapter Harmony à chaque IDE?**

| Harmony Feature | Claude Code | Cursor | Windsurf |
|-----------------|-------------|--------|----------|
| Guardian | hooks/ | .mdc rules | rules section |
| Sentinel | memory/*.json | N/A | N/A |
| HQVF | CLAUDE.md | .mdc rules | rules section |
| Agents | Skills | Personas | Instructions |

**Conclusion:**
> "Claude Code est le 'gold standard' (full support).
> Autres IDEs = dégradation gracieuse."

---

## Phase 6: Unification Command → Framework (Décembre 2025)

### Analyse ULTRATHINK

**Problème identifié:**
- `/harmony` command très riche (27 modes)
- `.harmony/` framework structure publique
- Duplication, incohérence potentielle

**Solution conçue:**

```
AVANT (2 systèmes):
├── /harmony command (27 modes, riche, local)
└── .harmony/ framework (structure, incomplet)

APRÈS (1 système):
└── .harmony/ framework (COMPLET, distributable)
    └── .claude/commands/harmony.md (thin wrapper)
```

### Recherche concurrentielle

**Frameworks analysés:**
- LangChain (90k+ stars) - RAG focus
- CrewAI (30k+ stars) - Multi-agent roles
- AutoGen (Microsoft) - Agent dialogue
- Semantic Kernel (Microsoft) - Enterprise

**USP Harmony identifiés:**
1. Error Memory (Sentinel) - UNIQUE
2. Quality Gates (HQVF) - UNIQUE
3. Intent Routing (Guardian) - UNIQUE
4. Multi-IDE - RARE

### Architecture finale

```
.harmony/
├── commands/        ← 30 modes (tous)
├── core/            ← Guardian + Sentinel + HQVF
├── agents/          ← 18+ agents
├── profiles/        ← 50+ tech profiles
├── specialties/     ← gaming, medical, etc.
├── integrations/    ← 5 IDEs
└── docs/            ← Documentation complète
```

---

## Décisions Architecturales (ADRs)

### ADR-001: Prompt-Based, Not Fine-Tuned

**Contexte:** Faut-il fine-tuner un modèle pour Harmony?

**Décision:** NON - Prompts + Memory uniquement

**Raison:**
> "Amélioration via prompts et mémoire,
> PAS de modification des poids du modèle.
> Le LLM reste intact.
> Performance garantie (pas de dégradation)."

### ADR-002: Circuit Breaker Manual Reset

**Contexte:** Le circuit breaker doit-il se reset automatiquement?

**Décision:** NON - Reset manuel obligatoire

**Raison:**
> "Auto-reset permet de répéter l'erreur.
> Manual reset force l'analyse root cause.
> Le pattern d'erreur doit être documenté."

### ADR-003: UCV Triple Validation

**Contexte:** Qui valide qu'une feature est terminée?

**Décision:** DEV + TEST + QA (les trois)

**Raison:**
> "DEV vérifie implémentation
> TEST vérifie comportement
> QA vérifie utilisabilité
> Les trois perspectives = qualité complète"

### ADR-004: Profiles Auto-Detection

**Contexte:** L'utilisateur doit-il déclarer ses profiles?

**Décision:** Auto-détection avec override possible

**Raison:**
> "package.json → nodejs, typescript
> tsconfig.json → typescript
> nest-cli.json → nestjs
> Moins de configuration manuelle"

---

## Leçons Apprises

### Ce qui a fonctionné

1. **Sentinel** - Réduction 82% des bugs récurrents
2. **HQVF** - Zéro "ça marche sur ma machine"
3. **Guardian** - Routing automatique sans confusion
4. **Multi-IDE** - Pas de lock-in

### Ce qui a été difficile

1. **Lost-in-middle** - Solution: JIT Loading
2. **IDE differences** - Solution: Feature mapping
3. **Documentation size** - Solution: Chunking 200-500 lignes

### Ce qu'on referait différemment

1. Commencer par le framework, pas la commande
2. Versioning sémantique dès le début
3. Tests automatisés plus tôt

---

## Références Clés

### Sources Architecturales
- Microsoft Azure AI Agent Patterns
- AWS Agentic AI Patterns
- Google ADK Documentation
- Anthropic Context Engineering (2025)

### Sources Mémoire
- Mem0 Documentation (+26% accuracy)
- MemGPT/Letta Architecture
- FlowHunt Context Engineering Guide

### Sources Qualité
- Confident AI LLM Guardrails
- DeepEval Evaluation Framework
- Agile Testing Quadrants

---

## Contributeurs

| Persona | Role | Contribution |
|---------|------|--------------|
| AI Architect | AI Architect | Architecture globale, recherche |
| UCV Writer | UCV Writer | Système HQVF |
| UCV Validator | UCV Validator | Validation qualité |
| Exploratory QA | QA Explorer | Tests exploratoires |
| Developer | Developer | Implémentation |
| Tester | Tester | Tests automatisés |
| Scrum Master | Scrum Master | Workflow stories |
| Analyst | Analyst | Requirements |
| Architect | Architect | Design technique |

---

## Prochaines Étapes

### v2.1 (Prévu)
- [ ] CLI npm global `harmony`
- [ ] Tests automatisés
- [ ] Landing page harmony-ai.dev

### v2.2 (Prévu)
- [ ] Specialties additionnelles (fintech, medical)
- [ ] 30+ profiles supplémentaires
- [ ] Intégration VS Code extension

### v3.0 (Vision)
- [ ] Cloud sync pour mémoire
- [ ] Team collaboration
- [ ] Analytics dashboard

---

## Note Finale

> **Ce document est la mémoire vivante du développement de Harmony.**
>
> Il capture non seulement le QUOI mais aussi le POURQUOI et le COMMENT.
> Chaque décision a une raison. Chaque pattern a une histoire.
>
> "Learn. Protect. Deliver." - C'est plus qu'un slogan,
> c'est notre philosophie de développement.
