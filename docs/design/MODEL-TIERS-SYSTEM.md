# Model Tiers System

> **🌐 Language:** English · [Français](../fr/design/MODEL-TIERS-SYSTEM.md)

> **Version**: 2.0
> **Status**: Production
> **Config**: `config/model-tiers.yaml`
> **Related**: `docs/design/CONTEXT-DETECTION-SYSTEM.md`

## Overview

The Model Tiers System is the LLM abstraction layer of the Harmony Framework. It lets you use any LLM provider (Claude, OpenAI, Mistral, etc.) without changing the code.

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

## Key Concepts

### 1. Provider Detection

Harmony automatically detects the LLM provider:

| Order | Check | Provider |
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

Three model levels for different complexities:

| Tier | Usage | Claude | OpenAI | Groq |
|------|-------|--------|--------|------|
| **T1** | Architecture, Audit | opus | gpt-4o | llama70b |
| **T2** | Daily dev | sonnet | gpt-4o-mini | llama8b |
| **T3** | Quick tasks | haiku | gpt-4o-mini | llama8b |
| **Router** | Classification | haiku | gpt-4o-mini | llama8b |

### 3. Router Model (RouteLLM)

The router is a lightweight model that classifies intents when keywords do not match.

**Why a dedicated model?**

- Specialized for classification
- Ultra-fast (< 500ms)
- Minimal cost
- Does not engage the large models for a simple question

**Choice per provider:**

| Provider | Router Model | Latency | Cost/1M tokens |
|----------|--------------|---------|----------------|
| Claude | haiku | ~400ms | $0.25 |
| OpenAI | gpt-4o-mini | ~300ms | $0.15 |
| Groq | llama-3.1-8b | ~100ms | Free* |
| Mistral | mistral-small | ~350ms | ~$0.20 |
| Ollama | codellama:7b | Variable | $0 (local) |

*Groq free up to 6000 req/min

## Configuration

### Base Configuration

File: `config/model-tiers.yaml`

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

### Per-Project Override

File: `.harmony/config.yaml`

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

### Configuration Examples

#### 1. Use Claude (default)

No config needed if `ANTHROPIC_API_KEY` is set.

#### 2. Use OpenAI

```bash
export OPENAI_API_KEY="sk-..."
```

Harmony will automatically detect it and use:
- Router: gpt-4o-mini
- T1: gpt-4o
- T2/T3: gpt-4o-mini

#### 3. Groq Router + Claude Dev

For an ultra-fast router with dev on Claude:

```yaml
# .harmony/config.yaml
llm:
  provider: "claude"  # Dev tasks
  router:
    provider: "groq"  # Classification rapide
    model: "llama-3.1-8b-instant"
```

#### 4. 100% Local (GDPR)

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

#### 5. Disable RouteLLM

To use only keywords:

```yaml
# .harmony/config.yaml
llm:
  disable_router: true
```

## Task Routing

### By Complexity

| Tier | Task Types |
|------|-----------------|
| T1 | architecture_design, security_audit, complex_refactoring, adr_creation |
| T2 | feature_implementation, code_review, test_writing, bug_fixing |
| T3 | simple_fixes, formatting, quick_lookups, status_checks |

### Background Tasks

Background tasks always use T3:
- exploration
- linting
- validation
- health_check

## Metrics

The system tracks:

| Metric | Target |
|----------|-------|
| Router accuracy | > 90% |
| T3 usage | > 40% |
| Cost reduction | > 50% |
| Router latency | < 500ms |

Log: `.harmony/local/memory/model-metrics.log`

## FAQ

### Q: What happens if no provider is detected?

RouteLLM is disabled; only keyword-based routing works.

### Q: Can I use a different provider for the router?

Yes, via `.harmony/config.yaml`:
```yaml
llm:
  provider: "claude"
  router:
    provider: "groq"
    model: "llama-3.1-8b-instant"
```

### Q: How do I force a specific tier?

Via a comment in the request:
```
@tier1: Analyse cette architecture complexe
```

### Q: Is Groq really free?

Yes, with limits:
- 6000 requests/minute
- 28,800 requests/day
- Perfect for the router (< 150 tokens/req)

### Q: How much latency does RouteLLM add?

- Claude (haiku): ~400ms
- OpenAI (4o-mini): ~300ms
- Groq (llama8b): ~100ms

Compare this with the time saved by avoiding a bad route.

## See Also

- [Context Detection System](./CONTEXT-DETECTION-SYSTEM.md) - RouteLLM in detail
- [Routing Rules](../../config/routing-rules.yaml) - Keywords and patterns
- [Pipeline Orchestration](../../config/pipeline-orchestration.yaml) - Phases and agents
