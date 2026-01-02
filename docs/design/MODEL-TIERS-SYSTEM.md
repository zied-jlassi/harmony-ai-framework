# Model Tiers System

> **Version**: 2.0
> **Status**: Production
> **Config**: `config/model-tiers.yaml`
> **Related**: `docs/design/CONTEXT-DETECTION-SYSTEM.md`

## Vue d'Ensemble

Le Model Tiers System est le systeme d'abstraction LLM de Harmony Framework. Il permet d'utiliser n'importe quel provider LLM (Claude, OpenAI, Mistral, etc.) sans modification du code.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MODEL TIERS SYSTEM                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   User Request                                                           │
│        │                                                                 │
│        ▼                                                                 │
│   ┌─────────────────┐                                                    │
│   │ Provider        │  Detecte: ANTHROPIC_API_KEY?                      │
│   │ Detection       │  → claude detected                                 │
│   └────────┬────────┘                                                    │
│            │                                                             │
│            ▼                                                             │
│   ┌─────────────────┐                                                    │
│   │ Keyword Match?  │  routing-rules.yaml keywords                      │
│   └────────┬────────┘                                                    │
│            │                                                             │
│     NO     │      YES                                                    │
│     ▼      │       │                                                     │
│   ┌─────────────────┐  │                                                 │
│   │ Router Model    │  │   "haiku" pour Claude                          │
│   │ (RouteLLM)      │  │   "gpt-4o-mini" pour OpenAI                    │
│   └────────┬────────┘  │   "llama8b" pour Groq                          │
│            │           │                                                 │
│            ▼           ▼                                                 │
│   ┌─────────────────────────┐                                            │
│   │ Task Routing            │  Selon complexite:                        │
│   │                         │  T1=Opus, T2=Sonnet, T3=Haiku             │
│   └────────┬────────────────┘                                            │
│            │                                                             │
│            ▼                                                             │
│   ┌─────────────────┐                                                    │
│   │ Execute Task    │  Avec le bon modele                               │
│   └─────────────────┘                                                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Concepts Cles

### 1. Provider Detection

Harmony detecte automatiquement le provider LLM:

| Ordre | Check | Provider |
|-------|-------|----------|
| 1 | `ANTHROPIC_API_KEY` | claude |
| 2 | `OPENAI_API_KEY` | openai |
| 3 | `GOOGLE_API_KEY` | google |
| 4 | `MISTRAL_API_KEY` | mistral |
| 5 | `GROQ_API_KEY` | groq |
| 6 | `OLLAMA_HOST` | ollama |
| 7 | `AZURE_OPENAI_ENDPOINT` | azure |
| 8 | `.claude/settings.json` | claude |
| 9 | Default | unknown |

### 2. Model Tiers

Trois niveaux de modeles pour differentes complexites:

| Tier | Usage | Claude | OpenAI | Groq |
|------|-------|--------|--------|------|
| **T1** | Architecture, Audit | opus | gpt-4o | llama70b |
| **T2** | Dev quotidien | sonnet | gpt-4o-mini | llama8b |
| **T3** | Taches rapides | haiku | gpt-4o-mini | llama8b |
| **Router** | Classification | haiku | gpt-4o-mini | llama8b |

### 3. Router Model (RouteLLM)

Le router est un modele leger qui classifie les intentions quand les mots-cles ne matchent pas.

**Pourquoi un modele dedie?**

- Specialise pour classification
- Ultra-rapide (< 500ms)
- Cout minimal
- Ne mobilise pas les gros modeles pour une simple question

**Choix par provider:**

| Provider | Router Model | Latence | Cout/1M tokens |
|----------|--------------|---------|----------------|
| Claude | haiku | ~400ms | $0.25 |
| OpenAI | gpt-4o-mini | ~300ms | $0.15 |
| Groq | llama-3.1-8b | ~100ms | Gratuit* |
| Mistral | mistral-small | ~350ms | ~$0.20 |
| Ollama | codellama:7b | Variable | $0 (local) |

*Groq gratuit jusqu'a 6000 req/min

## Configuration

### Configuration de Base

Fichier: `config/model-tiers.yaml`

```yaml
# Detection automatique
provider_detection:
  detection_order:
    - check: "env"
      var: "ANTHROPIC_API_KEY"
      provider: "claude"
    # ...

# Modeles par provider
providers:
  claude:
    models:
      tier1: { id: "claude-opus-4-5-20251101" }
      tier2: { id: "claude-sonnet-4-20250514" }
      tier3: { id: "claude-3-5-haiku-20241022" }
      router: { id: "claude-3-5-haiku-20241022" }
```

### Override par Projet

Fichier: `.harmony/config.yaml`

```yaml
llm:
  # Forcer un provider specifique
  provider: "openai"

  # Router personnalise
  router:
    provider: "groq"
    model: "llama-3.1-8b-instant"

  # Tier par defaut
  default_tier: "tier1"

  # Desactiver RouteLLM
  disable_router: false
```

### Exemples de Configuration

#### 1. Utiliser Claude (defaut)

Aucune config necessaire si `ANTHROPIC_API_KEY` est defini.

#### 2. Utiliser OpenAI

```bash
export OPENAI_API_KEY="sk-..."
```

Harmony detectera automatiquement et utilisera:
- Router: gpt-4o-mini
- T1: gpt-4o
- T2/T3: gpt-4o-mini

#### 3. Router Groq + Dev Claude

Pour un router ultra-rapide avec dev sur Claude:

```yaml
# .harmony/config.yaml
llm:
  provider: "claude"  # Dev tasks
  router:
    provider: "groq"  # Classification rapide
    model: "llama-3.1-8b-instant"
```

#### 4. 100% Local (RGPD)

```bash
export OLLAMA_HOST="http://localhost:11434"
```

```yaml
# .harmony/config.yaml
llm:
  provider: "ollama"
  router:
    provider: "ollama"
    model: "codellama:7b"
```

#### 5. Desactiver RouteLLM

Pour n'utiliser que les mots-cles:

```yaml
# .harmony/config.yaml
llm:
  disable_router: true
```

## Routing des Taches

### Par Complexite

| Tier | Types de Taches |
|------|-----------------|
| T1 | architecture_design, security_audit, complex_refactoring, adr_creation |
| T2 | feature_implementation, code_review, test_writing, bug_fixing |
| T3 | simple_fixes, formatting, quick_lookups, status_checks |

### Taches Background

Les taches en arriere-plan utilisent toujours T3:
- exploration
- linting
- validation
- health_check

## Metriques

Le systeme track:

| Metrique | Cible |
|----------|-------|
| Router accuracy | > 90% |
| Usage T3 | > 40% |
| Reduction cout | > 50% |
| Latence router | < 500ms |

Log: `.harmony/memory/model-metrics.log`

## FAQ

### Q: Que se passe-t-il si aucun provider n'est detecte?

RouteLLM est desactive, seul le routage par mots-cles fonctionne.

### Q: Puis-je utiliser un provider different pour le router?

Oui, via `.harmony/config.yaml`:
```yaml
llm:
  provider: "claude"
  router:
    provider: "groq"
    model: "llama-3.1-8b-instant"
```

### Q: Comment forcer un tier specifique?

Via le commentaire dans la requete:
```
@tier1: Analyse cette architecture complexe
```

### Q: Groq est-il vraiment gratuit?

Oui, avec limites:
- 6000 requetes/minute
- 28,800 requetes/jour
- Parfait pour router (< 150 tokens/req)

### Q: Quelle est la latence ajoutee par RouteLLM?

- Claude (haiku): ~400ms
- OpenAI (4o-mini): ~300ms
- Groq (llama8b): ~100ms

A comparer avec le temps economise en evitant un mauvais routage.

## Voir Aussi

- [Context Detection System](./CONTEXT-DETECTION-SYSTEM.md) - RouteLLM en detail
- [Routing Rules](../../config/routing-rules.yaml) - Mots-cles et patterns
- [Pipeline Orchestration](../../config/pipeline-orchestration.yaml) - Phases et agents
