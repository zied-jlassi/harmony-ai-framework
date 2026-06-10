# Harmony Framework Architecture

> **🌐 Language:** English · [Français](fr/architecture.md)

> **Improvement through Prompts and Memory, not model weight modification.**

---

## Overview

Harmony is an AI-assisted development framework that works with **every LLM** without modification. It structures knowledge and workflows to maximize the accuracy of responses.

```
┌─────────────────────────────────────────────────────────────────┐
│                      HARMONY FRAMEWORK                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┬─────────────┬─────────────────────────────┐   │
│  │  GUARDIAN   │  SENTINEL   │           HQVF              │   │
│  │  (Protect)  │  (Learn)    │         (Deliver)           │   │
│  └─────────────┴─────────────┴─────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────┬──────────────────────────────────┐   │
│  │    SPECIALTIES       │         TECH PROFILES            │   │
│  │    (QUOI)            │           (COMMENT)              │   │
│  │                      │                                   │   │
│  │  gaming, medical,    │   javascript → typescript        │   │
│  │  fintech, education  │   nodejs → nestjs, angular       │   │
│  └──────────────────────┴──────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                       AGENTS                             │   │
│  │  Core + Specialists + Domain (from specialties)          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Three Pillars

### 1. Guardian Protocol (Protect)

Protects the workflow by routing to the right agent.

| Function | Description |
|----------|-------------|
| Intent Detection | Analyzes keywords → intent |
| Agent Routing | Routes to the appropriate agent |
| Phase Validation | Checks the project phase |
| Prerequisites | Does a story exist? Is the UCV approved? |

### 2. Sentinel System (Learn)

Keeps a memory of errors so they are never repeated.

| Component | Description |
|-----------|-------------|
| Error Journal | History of errors + solutions |
| Circuit Breaker | 3 failures = stop |
| Learned Patterns | Validated patterns |
| Anti-Patterns | Patterns to avoid |

### 3. HQVF (Deliver)

Guarantees quality through Verifiable Use Cases (UCVs).

| Rule | Description |
|-------|-------------|
| HQVF-1 | Never develop without an approved UCV |
| HQVF-2 | Every story has a UCV file |
| HQVF-3 | The user approves UCVs before development |
| HQVF-7 | Story DONE = 100% of UCVs validated |

---

## Specialties vs Tech Profiles

**The fundamental distinction:**

| Aspect | Specialties | Tech Profiles |
|--------|-------------|---------------|
| **Question** | WHAT to build? | HOW to build? |
| **Type** | Business domain | Technical stack |
| **Examples** | gaming, medical | nestjs, angular |
| **Agents** | Adds agents | No new agents |
| **Activation** | Explicit | Auto-detect |

### Specialties (Domain Packs)

Business expertise with specialized agents:

```
specialties/
└── gaming/
    ├── manifest.yaml        # 7 agents
    ├── agents/              # game-designer, game-ux, game-sound...
    ├── patterns/            # ECS, state-machine, progression
    └── knowledge/           # Peuple via /harmony learn
```

**Available specialties:**
- `gaming` - Games, gamification
- `medical` - Healthcare, HIPAA, HL7
- `fintech` - Finance, PCI-DSS
- `education` - E-learning, LMS
- `iot` - IoT, embedded
- `ecommerce` - E-commerce, payments

### Tech Profiles (Technical Stacks)

Technical knowledge with dependencies:

```
profiles/
├── profiles-registry.yaml    # Index + graph dependances
├── languages/
│   ├── javascript/          (L0 - base)
│   └── typescript/          (L0 - requires javascript)
├── runtimes/
│   └── nodejs/              (L1 - requires javascript)
└── backend/
    └── nestjs/              (L2 - requires typescript, nodejs)
```

---

## Dependency System

### Levels

| Level | Type | Examples |
|-------|------|----------|
| L0 | Languages | javascript, typescript, python |
| L1 | Runtimes | nodejs, deno, bun |
| L2 | Frameworks | nestjs, angular, django |
| L3 | Meta/Tools | prisma, graphql, docker |

### Resolution

When `nestjs` is activated:

```
nestjs (L2)
├── typescript (L0) ← required
│   └── javascript (L0) ← required by typescript
└── nodejs (L1) ← required
    └── javascript (L0) ← already loaded
```

**Loading order:** javascript → typescript → nodejs → nestjs

### Token Budget

| Level | % Budget | Example nestjs |
|--------|----------|----------------|
| Target | 60% | nestjs knowledge |
| Direct | 30% | typescript, nodejs |
| Transitive | 10% | javascript |

---

## JIT Loading (Just-In-Time)

**Principle:** Load only what is relevant to the request.

```
User: "Cree un guard NestJS"
        ↓
Detecte: profile=nestjs, topic=guards
        ↓
Charge:
  1. nestjs/knowledge/guards.md (primary)
  2. nestjs/knowledge/providers.md (context)
  3. typescript/knowledge/decorators.md (cross-ref)
        ↓
Total: ~2000 tokens (pas 50,000)
```

### Benefits

| Without JIT | With JIT |
|----------|----------|
| 50,000 tokens | 2,000 tokens |
| Saturated context | 95% free |
| Slow | Fast |
| Hallucinations | Focus = precision |

---

## /harmony learn

**Command to populate knowledge from 2025 web sources.**

```bash
# Depuis URL
/harmony learn https://docs.nestjs.com/guards

# Depuis recherche
/harmony learn --search "Angular signals 2025"

# Refresh existant
/harmony learn --refresh nestjs/guards
```

### Workflow

1. **FETCH** - WebFetch, Context7, or Brave Search
2. **DETECT** - Auto-detection of profile/specialty
3. **EXTRACT** - Best practices, patterns, examples
4. **VALIDATE** - Size, duplicates, conflicts
5. **SAVE** - Knowledge file + update manifest
6. **REPORT** - Summary of what was learned

### Sources

| Tool | Usage |
|------|-------|
| Context7 | Official documentation |
| Brave Search | General search |
| WebFetch | Direct URL |

---

## File Structure

```
.harmony/
├── harmony.manifest.json      # Identite framework
├── agents/                    # Agents core
├── docs/                      # Documentation
├── patterns/                  # Patterns globaux
├── rules/                     # Regles globales
├── workflows/                 # Workflows (dont harmony-learn)
├── memory/                    # Memoire Sentinel
├── profiles/                  # Tech Profiles
│   ├── profiles-registry.yaml
│   ├── languages/
│   ├── runtimes/
│   ├── backend/
│   └── frontend/
└── specialties/               # Specialty Packs
    └── gaming/
```

---

## Multi-Specialty / Multi-Profile

A project can activate several specialties AND several profiles:

```yaml
# .harmony/project.yaml
project:
  name: fashion-store
  specialties:
    - e-commerce   # Vente en ligne
    - fashion      # Mode et tendances
  profiles:
    - nestjs       # Backend (+ typescript, nodejs, javascript)
    - angular      # Frontend (+ typescript)
    - prisma       # ORM
```

---

## LLM Compatibility

Harmony works with **every LLM** because:

| Reason | Explanation |
|--------|-------------|
| Markdown | The lingua franca of LLMs |
| Prompt-based | No fine-tuning |
| Optimized context | JIT = relevant only |
| Universal | Claude, GPT, Gemini, local |

### Tested LLMs

- Anthropic Claude (3.5, 4, Opus)
- OpenAI GPT-4, GPT-4o
- Google Gemini Pro, Ultra
- Local: Llama, Mistral, Mixtral
- IDEs: Cursor, Windsurf, Continue

---

## Integrations (WHERE to deploy)

**Third dimension:** Specialties = WHAT, Profiles = HOW, **Integrations = WHERE**

Harmony adapts to different LLMs/IDEs through the integrations system:

```
┌─────────────────────────────────────────────────────────────────┐
│                      HARMONY INTEGRATIONS                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌───────────┬───────────┬───────────┬───────────┬───────────┐ │
│  │  CLAUDE   │  CURSOR   │ WINDSURF  │ CONTINUE  │   CODY    │ │
│  │   CODE    │           │           │           │           │ │
│  │    ✓✓✓    │    ✓✓     │    ✓✓     │    ✓✓     │    ✓      │ │
│  └───────────┴───────────┴───────────┴───────────┴───────────┘ │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              HARMONY CORE (Universal)                    │   │
│  │  Agents + Profiles + Specialties + Knowledge             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Comparison of Integrations

| Feature | Claude Code | Cursor | Windsurf | Continue | Cody |
|---------|:-----------:|:------:|:--------:|:--------:|:----:|
| **Hooks** | ✓ pre/post | ✗ | ✗ | ✗ | ✗ |
| **Memory** | ✓ persistant | ✗ | ✗ | ✗ | Code Graph |
| **MCP** | ✓ complet | ✗ | ✗ | ✗ | ✗ |
| **Rules** | CLAUDE.md | .mdc files | .windsurfrules | config.yaml | Prompts |
| **Agents** | Skills | Rules + personas | Rules | Assistants | Prompts |
| **Auto-detect** | ✓ | Globs | ✗ | ✗ | ✗ |

### Structure of the Integrations

```
.harmony/integrations/
├── integrations-registry.yaml    # Index + feature mapping
├── claude-code/
│   ├── manifest.yaml             # Capabilities, config
│   └── templates/
│       ├── CLAUDE.md.template    # Guardian, Sentinel, HQVF
│       └── hooks/                # pre-tool-use, post-tool-use
├── cursor/
│   ├── manifest.yaml
│   └── templates/rules/
│       ├── harmony-core.mdc      # Base rules
│       ├── harmony-guardian.mdc  # Intent routing
│       └── harmony-agents.mdc    # Agent personas
├── windsurf/
│   ├── manifest.yaml
│   └── templates/
│       └── harmony.windsurfrules # Combined rules
├── continue/
│   ├── manifest.yaml
│   └── templates/
│       ├── config.yaml.template
│       └── assistants/*.yaml     # One per agent
└── cody/
    ├── manifest.yaml
    └── templates/prompts/
        └── harmony-*.md          # Shareable prompts
```

### Support Levels

| Level | Description | Integrations |
|--------|-------------|--------------|
| **Full** | Hooks + Memory + MCP + Rules | Claude Code |
| **Good** | Rules + Agents/Personas | Cursor, Windsurf, Continue |
| **Partial** | Prompts only | Cody |

### Feature Mapping

How each Harmony feature is implemented:

| Harmony Feature | Claude Code | Cursor | Windsurf | Continue |
|-----------------|-------------|--------|----------|----------|
| **Guardian** | hooks/guardian-checkpoint.sh | harmony-guardian.mdc | .windsurfrules section | config.yaml rules |
| **Sentinel** | memory/*.json + hooks | N/A (no persistence) | N/A | N/A |
| **HQVF** | CLAUDE.md section | harmony-core.mdc | .windsurfrules section | config.yaml rules |
| **Agents** | Skills (slash commands) | Rule files + globs | Cascade instructions | Assistants YAML |
| **Tech Profiles** | CLAUDE.md includes | .mdc with globs | .windsurfrules | Context providers |

### /harmony install

Deploys Harmony to a specific LLM/IDE:

```bash
# Installer pour Cursor
/harmony install cursor

# Installer pour Windsurf
/harmony install windsurf

# Installer pour Continue
/harmony install continue

# Installer pour Cody
/harmony install cody
```

**Actions performed:**
1. Detects the active profiles/specialties
2. Generates IDE-specific config files
3. Copies templates into the correct folders
4. Configures rules with the detected tech stack
5. Displays post-installation instructions

### Migration Claude Code → Another IDE

If you switch from Claude Code to another IDE, some features are lost:

| Lost Feature | Alternative |
|--------------|-------------|
| **Hooks** (Guardian) | Manual discipline (rules in prompt) |
| **Memory** (Sentinel) | Manual error tracking |
| **MCP** | Built-in tools of target IDE |
| **Slash commands** | Inline prompts or assistants |

**Recommendation:** Keep Claude Code as the "source of truth" and use the other IDEs as a complement.

---

## See Also

- [Concepts](concepts.md) - Philosophy
- [Getting Started](getting-started.md) - Getting started
- [Profiles Registry](../profiles/profiles-registry.yaml)
- [Gaming Specialty](../specialties/developer/branchs/gaming.md)
- [/harmony learn](../workflows/harmony-learn.md)
- [Integrations Registry](../integrations/integrations-registry.yaml)
