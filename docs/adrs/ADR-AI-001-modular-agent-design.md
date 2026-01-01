# ADR-AI-001: Modular Agent Design

## Status
**PROPOSED** - Phase 2 du Harmony Framework

## Date
2025-12-31

## Context

### Probleme Identifie
Les agents Harmony sont actuellement des fichiers monolithiques. Avec l'enrichissement continu:
- Les fichiers grossissent (1000-1600 lignes)
- Risque de "lost-in-middle" dans le context LLM
- Knowledge non extensible sans modifier le core
- Profiles et Specialties non integres aux agents

### Analyse Context Window
| Modele | Context | Lignes (~) | Impact 1500L agent |
|--------|---------|------------|-------------------|
| Claude 3.5 | 200K tokens | ~30K lignes | 0.5% (negligeable) |
| GPT-4 | 128K tokens | ~20K lignes | 0.75% (acceptable) |

**Conclusion**: A court terme, fichiers monolithiques sont acceptables. Mais pour scalabilite long terme, architecture modulaire necessaire.

## Decision

Adopter une **architecture modulaire pour les agents** avec JIT (Just-In-Time) loading.

### Structure Proposee

```
.harmony/agents/
├── {agent}/                    # Chaque agent = dossier
│   ├── manifest.yaml           # Metadata + regles de chargement
│   ├── core.md                 # Identite, regles (~150L) - TOUJOURS charge
│   ├── anti-patterns.md        # Ce qu'il ne faut PAS faire (~100L)
│   ├── patterns/               # Charge selon framework detecte
│   │   ├── react-mvc.md
│   │   ├── nestjs.md
│   │   └── angular.md
│   └── knowledge/              # Enrichi via /harmony learn
│       ├── typescript.md
│       ├── prisma.md
│       └── {topic}.md
```

### Manifest.yaml Specification

```yaml
name: developer
persona: Amelia
version: 2.0
tier: 1
phase: 4

# Regles de chargement
loading:
  # Toujours charge (petit, essentiel)
  always:
    - core.md
    - anti-patterns.md

  # Charge conditionnellement selon le projet
  conditional:
    - file: patterns/react-mvc.md
      when:
        - file_exists: "vite.config.ts"
        - package_json_has: "react"

    - file: patterns/nestjs.md
      when:
        - file_exists: "nest-cli.json"

    - file: patterns/angular.md
      when:
        - file_exists: "angular.json"

  # Charge a la demande via semantic search
  on_demand:
    - knowledge/*
    - path: ".harmony/profiles/{detected}/"
      similarity_threshold: 0.7

# Integration avec systemes existants
integrations:
  profiles: true      # Utilise .harmony/profiles/
  specialties: true   # Utilise .harmony/specialties/
  sentinel: true      # Lit error-journal.json
```

### Mecanisme JIT Loading

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         JIT LOADING FLOW                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. GUARDIAN DETECTE INTENT                                                 │
│     User: "Developpe le scoring gaming"                                     │
│     → Intent: IMPLEMENT                                                      │
│     → Agent: Developer (Amelia)                                             │
│                                                                              │
│  2. GUARDIAN LIT MANIFEST.YAML                                              │
│     → always: [core.md, anti-patterns.md]                                   │
│     → conditional: check project files                                       │
│                                                                              │
│  3. GUARDIAN ANALYSE PROJET                                                 │
│     → vite.config.ts existe? OUI → load react-mvc.md                        │
│     → nest-cli.json existe? OUI → load nestjs.md                            │
│     → Specialty active? gaming → load gaming patterns                        │
│                                                                              │
│  4. GUARDIAN ASSEMBLE CONTEXT                                               │
│     ┌──────────────────────────────────────┐                                │
│     │ core.md (150L)                       │                                │
│     │ anti-patterns.md (100L)              │                                │
│     │ patterns/react-mvc.md (200L)         │                                │
│     │ patterns/nestjs.md (200L)            │                                │
│     │ specialties/gaming/scoring.md (100L) │                                │
│     └──────────────────────────────────────┘                                │
│     TOTAL: ~750L (vs 1600L monolithique)                                    │
│                                                                              │
│  5. AGENT EXECUTE AVEC CONTEXT OPTIMISE                                     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Rationale

### Options Evaluees

| Option | Pros | Cons | Score |
|--------|------|------|:-----:|
| **A. Fichiers monolithiques** | Simple, tout au meme endroit | Non scalable, lost-in-middle | 4/10 |
| **B. Sub-agents (Nova style)** | Delegation claire | Overhead coordination | 7/10 |
| **C. Modular + JIT** | Scalable, context optimal | Migration complexe | 9/10 |
| **D. Hybrid** | Best of B+C | Plus complexe | 8/10 |

### Pourquoi Option C?

1. **Scalabilite infinie**: Knowledge peut grandir sans impacter le core
2. **Context optimal**: Charge uniquement le pertinent
3. **Compatible profiles**: Reutilise l'infrastructure existante
4. **Enrichissement facile**: `/harmony learn` ajoute dans knowledge/
5. **Separation des concerns**: Core stable, patterns evoluent

## Consequences

### Positives
- Core agents restent petits (~150L)
- Knowledge extensible sans limite
- Context LLM optimise (pas de lost-in-middle)
- Profiles et Specialties integres naturellement
- `/harmony learn` plus puissant

### Negatives
- Migration initiale complexe
- Guardian doit implementer JIT loading
- Manifest.yaml a maintenir par agent
- Tests d'integration necessaires

### Mitigations
- **Migration**: Faire en Phase 2, apres presentation Anthropic
- **Guardian**: Enrichir progressivement
- **Manifest**: Templates pour faciliter creation
- **Tests**: Ajouter tests de loading dans CI

## Implementation Notes

### Phase 1 (Actuelle - Preparation Anthropic)
- Enrichir agents en fichiers monolithiques
- Documenter cette ADR
- Taille acceptable: 1000-1600 lignes

### Phase 2 (v2.1 - Post-presentation)
1. Creer structure modulaire pour Developer
2. Migrer patterns vers patterns/
3. Implementer JIT loading dans Guardian
4. Migrer autres agents progressivement

### Phase 3 (v2.2)
- Integration complete profiles
- Semantic search pour knowledge/
- Analytics sur usage des modules

## References

- [Anthropic: Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [AI Agent Architecture: Mapping to Clean Architecture](https://medium.com/@naoyuki.sakai/ai-agent-architecture-mapping-domain-agent-and-orchestration-to-clean-architecture-fd359de8fa9b)
- [SymfonyCon 2025: Cloud-Agnostic AI Agents](https://symfony.com/blog/symfonycon-amsterdam-2025-cloud-agnostic-ai-agents-with-clean-architecture)

## Review

- **AI Architect**: Nova
- **Date**: 2025-12-31
- **Confidence**: 95%
- **Status**: En attente approbation user

---

> **Note**: Cette ADR documente la vision Phase 2.
> Phase 1 (enrichissement monolithique) proceed maintenant.
