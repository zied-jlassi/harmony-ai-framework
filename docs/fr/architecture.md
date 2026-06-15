# Architecture Harmony Framework

> **🌐 Langue :** [English](../architecture.md) · Français

> **Improvement through Prompts and Memory, not model weight modification.**

---

## Vue d'Ensemble

Harmony est un framework de developpement AI-assiste qui fonctionne avec **tous les LLMs** sans modification. Il structure les connaissances et les workflows pour maximiser la precision des reponses.

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

## Les Trois Piliers

### 1. Guardian Protocol (Protect)

Protege le workflow en routant vers le bon agent.

| Fonction | Description |
|----------|-------------|
| Intent Detection | Analyse mots-cles → intention |
| Agent Routing | Route vers agent appropriate |
| Phase Validation | Verifie phase du projet |
| Prerequisites | Story existe? UCV approuve? |

### 2. Sentinel System (Learn)

Garde la memoire des erreurs pour ne pas les repeter.

| Composant | Description |
|-----------|-------------|
| Error Journal | Historique erreurs + solutions |
| Circuit Breaker | 3 echecs = stop |
| Learned Patterns | Patterns valides |
| Anti-Patterns | Patterns a eviter |

### 3. HQVF (Deliver)

Garantit la qualite via Use Cases Verifiables (UCV).

| Regle | Description |
|-------|-------------|
| HQVF-1 | Jamais de dev sans UCV approuve |
| HQVF-2 | Chaque story a un fichier UCV |
| HQVF-3 | User approuve UCVs avant dev |
| HQVF-7 | Story DONE = 100% UCVs valides |

---

## Specialties vs Tech Profiles

**La distinction fondamentale:**

| Aspect | Specialties | Tech Profiles |
|--------|-------------|---------------|
| **Question** | QUOI construire? | COMMENT construire? |
| **Type** | Domaine metier | Stack technique |
| **Exemples** | gaming, medical | nestjs, angular |
| **Agents** | Ajoute des agents | Pas de nouveaux agents |
| **Activation** | Explicite | Auto-detect |

### Specialties (Packs Domaine)

Expertise metier avec agents specialises:

```
specialties/
└── gaming/
    ├── manifest.yaml        # 7 agents
    ├── agents/              # game-designer, game-ux, game-sound...
    ├── patterns/            # ECS, state-machine, progression
    └── knowledge/           # Peuple via /harmony learn
```

**Specialties disponibles:**
- `gaming` - Jeux, gamification
- `medical` - Sante, HIPAA, HL7
- `fintech` - Finance, PCI-DSS
- `education` - E-learning, LMS
- `iot` - IoT, embedded
- `ecommerce` - E-commerce, payments

### Tech Profiles (Stacks Techniques)

Connaissances techniques avec dependances:

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

## Systeme de Dependances

### Niveaux

| Level | Type | Exemples |
|-------|------|----------|
| L0 | Languages | javascript, typescript, python |
| L1 | Runtimes | nodejs, deno, bun |
| L2 | Frameworks | nestjs, angular, django |
| L3 | Meta/Tools | prisma, graphql, docker |

### Resolution

Quand on active `nestjs`:

```
nestjs (L2)
├── typescript (L0) ← required
│   └── javascript (L0) ← required by typescript
└── nodejs (L1) ← required
    └── javascript (L0) ← already loaded
```

**Ordre de chargement:** javascript → typescript → nodejs → nestjs

### Budget Token

| Niveau | % Budget | Exemple nestjs |
|--------|----------|----------------|
| Target | 60% | nestjs knowledge |
| Direct | 30% | typescript, nodejs |
| Transitive | 10% | javascript |

---

## JIT Loading (Just-In-Time)

**Principe:** Ne charger que ce qui est pertinent pour la requete.

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

### Avantages

| Sans JIT | Avec JIT |
|----------|----------|
| 50,000 tokens | 2,000 tokens |
| Context sature | 95% libre |
| Lent | Rapide |
| Hallucinations | Focus = precision |

---

## /harmony learn

**Commande pour peupler les knowledge depuis sources web 2025.**

```bash
# Depuis URL
/harmony learn https://docs.nestjs.com/guards

# Depuis recherche
/harmony learn --search "Angular signals 2025"

# Refresh existant
/harmony learn --refresh nestjs/guards
```

### Workflow

1. **FETCH** - WebFetch, Context7, ou Brave Search
2. **DETECT** - Auto-detection profile/specialty
3. **EXTRACT** - Best practices, patterns, exemples
4. **VALIDATE** - Taille, duplicates, conflicts
5. **SAVE** - Knowledge file + update manifest
6. **REPORT** - Resume de ce qui a ete appris

### Sources

| Tool | Usage |
|------|-------|
| Context7 | Documentation officielle |
| Brave Search | Recherche generale |
| WebFetch | URL directe |

---

## Structure Fichiers

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

Un projet peut activer plusieurs specialties ET plusieurs profiles:

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

## Compatibilite LLM

Harmony fonctionne avec **tous les LLMs** car:

| Raison | Explication |
|--------|-------------|
| Markdown | Lingua franca des LLMs |
| Prompt-based | Pas de fine-tuning |
| Context optimise | JIT = pertinent uniquement |
| Universal | Claude, GPT, Gemini, local |

### LLMs Testes

- Anthropic Claude (3.5, 4, Opus)
- OpenAI GPT-4, GPT-4o
- Google Gemini Pro, Ultra
- Local: Llama, Mistral, Mixtral
- IDEs: Cursor, Windsurf, Continue

---

## Integrations (OU deployer)

**Troisieme dimension:** Specialties = QUOI, Profiles = COMMENT, **Integrations = OU**

Harmony s'adapte a differents LLM/IDEs via le systeme d'integrations:

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

### Comparaison des Integrations

| Feature | Claude Code | Cursor | Windsurf | Continue | Cody |
|---------|:-----------:|:------:|:--------:|:--------:|:----:|
| **Hooks** | ✓ pre/post | ✗ | ✗ | ✗ | ✗ |
| **Memory** | ✓ persistant | ✗ | ✗ | ✗ | Code Graph |
| **MCP** | ✓ complet | ✗ | ✗ | ✗ | ✗ |
| **Rules** | CLAUDE.md | .mdc files | .windsurfrules | config.yaml | Prompts |
| **Agents** | Skills | Rules + personas | Rules | Assistants | Prompts |
| **Auto-detect** | ✓ | Globs | ✗ | ✗ | ✗ |

### Structure des Integrations

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

### Niveaux de Support

| Niveau | Description | Integrations |
|--------|-------------|--------------|
| **Full** | Hooks + Memory + MCP + Rules | Claude Code |
| **Good** | Rules + Agents/Personas | Cursor, Windsurf, Continue |
| **Partial** | Prompts only | Cody |

### Feature Mapping

Comment chaque feature Harmony est implementee:

| Harmony Feature | Claude Code | Cursor | Windsurf | Continue |
|-----------------|-------------|--------|----------|----------|
| **Guardian** | hooks/guardian-checkpoint.sh | harmony-guardian.mdc | .windsurfrules section | config.yaml rules |
| **Sentinel** | memory/*.json + hooks | N/A (no persistence) | N/A | N/A |
| **HQVF** | CLAUDE.md section | harmony-core.mdc | .windsurfrules section | config.yaml rules |
| **Agents** | Skills (slash commands) | Rule files + globs | Cascade instructions | Assistants YAML |
| **Tech Profiles** | CLAUDE.md includes | .mdc with globs | .windsurfrules | Context providers |

### /harmony install

Deploie Harmony vers un LLM/IDE specifique:

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

**Actions executees:**
1. Detecte les profiles/specialties actifs
2. Genere fichiers de config specifiques a l'IDE
3. Copie templates dans les bons dossiers
4. Configure rules avec tech stack detecte
5. Affiche instructions post-installation

### Migration Claude Code → Autre IDE

Si vous passez de Claude Code a un autre IDE, certaines fonctionnalites sont perdues:

| Lost Feature | Alternative |
|--------------|-------------|
| **Hooks** (Guardian) | Manual discipline (rules in prompt) |
| **Memory** (Sentinel) | Manual error tracking |
| **MCP** | Built-in tools of target IDE |
| **Slash commands** | Inline prompts or assistants |

**Recommendation:** Garder Claude Code comme "source of truth" et utiliser les autres IDEs en complement.

---

## Voir Aussi

- [Concepts](concepts.md) - Philosophie
- [Getting Started](getting-started.md) - Demarrage
- [Profiles Registry](../../profiles/profiles-registry.yaml)
- [Gaming Specialty](../../specialties/developer/branchs/gaming.md)
- [/harmony learn](../../workflows/harmony-learn.md)
- [Integrations Registry](../../integrations/integrations-registry.yaml)
