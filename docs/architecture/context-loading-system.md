# Context Loading System - Architecture

> **🌐 Language:** English · [Français](../fr/architecture/context-loading-system.md)

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           HARMONY CONTEXT LOADING SYSTEM                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  USER REQUEST                                                                   │
│  "Créer un système d'authentification pour mon jeu mobile"                      │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 1: ROUTER CLASSIFICATION (context-preloader.sh)         ✅ DONE      │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  Input: User request                                                       │ │
│  │  Output: {                                                                 │ │
│  │    "primary_intent": "IMPLEMENT",                                          │ │
│  │    "context_flags": ["has_auth", "is_game", "is_mobile", "personal_data"], │ │
│  │    "suggested_agent": "developer",                                         │ │
│  │    "triggered_agents": ["security", "rgpd", "database"],                   │ │
│  │    "confidence": 0.92                                                      │ │
│  │  }                                                                         │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 2: BRANCH RESOLUTION (config-loader.sh)                 ✅ DONE      │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  context_flags: [is_game, is_mobile]                                       │ │
│  │                          │                                                 │ │
│  │  ┌───────────────────────┴───────────────────────┐                         │ │
│  │  │  Check specialty manifest conditions:          │                         ││
│  │  │  • developer/gaming: is_game == true  ✓        │                         ││
│  │  │  • developer/mobile: is_mobile == true ✓       │                         ││
│  │  │  → Select: developer/gaming (priority)         │                         ││
│  │  └────────────────────────────────────────────────┘                         ││
│  │                                                                             ││
│  │  Result: specialties/developer/branchs/gaming.md                            ││
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 3: PROFILE DETECTION (profile-loader.sh)                ❌ TODO      │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  1. Read package.json, pubspec.yaml, etc.                                  │ │
│  │  2. Detect tech stack:                                                     │ │
│  │     • react-native in dependencies → mobile/react-native                   │ │
│  │     • typescript in devDependencies → languages/typescript                 │ │
│  │     • nestjs in dependencies → backend/nestjs                              │ │
│  │  3. Load profile manifests                                                 │ │
│  │                                                                             ││
│  │  Result: [mobile/react-native, languages/typescript, backend/nestjs]        ││
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 4: KNOWLEDGE JIT LOADING (knowledge-loader.sh)          ❌ TODO      │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  Sources:                                                                  │ │
│  │  1. Branch manifest → knowledge[]                                          │ │
│  │  2. Profile manifest → knowledge.on_intent[IMPLEMENT]                      │ │
│  │  3. Context flags → context_flag_triggers[has_auth].knowledge              │ │
│  │                                                                             ││
│  │  Loaded:                                                                   │ │
│  │  • gaming/unity-ecs-patterns.md (from branch)                              │ │
│  │  • react-native-architecture.md (from profile)                             │ │
│  │  • security/authentication-patterns.md (from flag)                         │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 5: CONTEXT INJECTION (memory-injector.sh)               ❌ TODO      │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  Write to .harmony/local/memory/working.json:                                    ││
│  │  {                                                                         │ │
│  │    "active_agent": "developer",                                            │ │
│  │    "active_branch": "gaming",                                              │ │
│  │    "loaded_profiles": ["mobile/react-native", "languages/typescript"],     │ │
│  │    "loaded_knowledge": ["gaming/*.md", "security/*.md"],                   │ │
│  │    "context_flags": ["has_auth", "is_game", "is_mobile"],                  │ │
│  │    "triggered_agents": ["security", "rgpd"]                                │ │
│  │  }                                                                         │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                          │                                                      │
│                          ▼                                                      │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │  STEP 6: AGENT EXECUTION (guardian.md orchestrates)           ✅ PARTIAL   │ │
│  │  ─────────────────────────────────────────────────────────────────────────│  │
│  │  Developer (gaming branch) executes with:                                  │ │
│  │  • Full gaming context                                                     │ │
│  │  • Mobile-specific patterns                                                │ │
│  │  • Security requirements pre-loaded                                        │ │
│  │  • RGPD constraints visible                                                │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Relationship Tree

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              HIERARCHY TREE                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  AGENT (Domain)                                                                 │
│  └── agents/developer.md                     # Base agent (53KB, ~13K tokens)   │
│      │                                                                          │
│      ├── SPECIALTY                                                              │
│      │   └── specialties/developer/                                             │
│      │       ├── manifest.yaml               # Config: conditions, knowledge    │
│      │       │                                                                  │
│      │       └── BRANCHES (Context-specific)                                    │
│      │           ├── branchs/software.md     # Default                          │
│      │           ├── branchs/web.md          # condition: is_web                │
│      │           ├── branchs/mobile.md       # condition: is_mobile             │
│      │           └── branchs/gaming.md       # condition: is_game               │
│      │               │                                                          │
│      │               ├── KNOWLEDGE (JIT loaded)                                 │
│      │               │   ├── gaming/unity-ecs-patterns.md                       │
│      │               │   ├── gaming/godot-gdscript-patterns.md                  │
│      │               │   └── shared/patterns/debugging-strategies.md            │
│      │               │                                                          │
│      │               └── PROFILES (Tech stack)                                  │
│      │                   ├── languages/typescript                               │
│      │                   ├── languages/csharp                                   │
│      │                   └── databases/redis                                    │
│      │                       │                                                  │
│      │                       └── PROFILE CONTENT                                │
│      │                           ├── manifest.yaml  # Versioning, detection     │
│      │                           └── knowledge/     # Profile-specific docs     │
│      │                                                                          │
│      └── PATTERNS (Reasoning)                                                   │
│          ├── patterns/P-003-jit-context.md                                      │
│          ├── patterns/P-004-circuit-breaker.md                                  │
│          └── patterns/cognitive/react.md                                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Relationships

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           LOADING RELATIONSHIPS                                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────┐         ┌──────────────┐         ┌─────────────┐               │
│  │   AGENT     │────────▶│   BRANCH     │────────▶│  KNOWLEDGE  │               │
│  │  (Domain)   │ selects │  (Context)   │  loads  │   (JIT)     │               │
│  └─────────────┘         └──────────────┘         └─────────────┘               │
│        │                        │                        ▲                      │
│        │                        │                        │                      │
│        │                        ▼                        │                      │
│        │                 ┌──────────────┐                │                      │
│        │                 │   PROFILE    │────────────────┘                      │
│        │                 │ (Tech Stack) │  also loads                           │
│        │                 └──────────────┘                                       │
│        │                        │                                               │
│        │                        ▼                                               │
│        │                 ┌──────────────┐                                       │
│        │                 │  CONTEXT7    │                                       │
│        │                 │ (Live Docs)  │                                       │
│        │                 └──────────────┘                                       │
│        │                                                                        │
│        ▼                                                                        │
│  ┌─────────────┐                                                                │
│  │  PATTERNS   │                                                                │
│  │ (Reasoning) │                                                                │
│  └─────────────┘                                                                │
│                                                                                 │
│  ═══════════════════════════════════════════════════════════════════════════    │
│                                                                                 │
│  DETECTION FLOW:                                                                │
│  ───────────────                                                                │
│  1. User request → Haiku classifies intent + flags                              │
│  2. Flags → Select branch (is_game → gaming branch)                             │
│  3. Project files → Detect profiles (package.json → react-native)               │
│  4. Branch + Profile → Load knowledge                                           │
│  5. Profile → Query context7 for live docs                                      │
│                                                                                 │
│  PRIORITY (what to load):                                                       │
│  ────────────────────────                                                       │
│  1. Branch file only (autonomous, ~7K tokens)                                   │
│  2. + Triggered agents summaries (~500 tokens each)                             │
│  3. + Critical knowledge (~2K tokens max)                                       │
│  4. Context7 on-demand (not pre-loaded)                                         │
│                                                                                 │
│  TOKEN BUDGET: ~15K max pre-loaded                                              │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Concrete Example: Gaming Mobile Auth

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│  REQUEST: "Créer authentification pour jeu mobile React Native"                 │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  HAIKU OUTPUT:                                                                  │
│  {                                                                              │
│    "intent": "IMPLEMENT",                                                       │
│    "flags": ["is_game", "is_mobile", "has_auth", "personal_data"],              │
│    "agent": "developer",                                                        │
│    "triggered": ["security", "rgpd"]                                            │
│  }                                                                              │
│                                                                                 │
│  RESOLUTION:                                                                    │
│  ┌────────────────────────────────────────────────────────────────────────────┐ │
│  │                                                                            │ │
│  │  Agent: developer                                                          │ │
│  │    │                                                                       │ │
│  │    ├─ Branch: gaming.md (is_game=true wins over is_mobile)                 │ │
│  │    │    └─ 39KB, ~10K tokens                                               │ │
│  │    │                                                                       │ │
│  │    ├─ Profiles detected (package.json):                                    │ │
│  │    │    ├─ mobile/react-native                                             │ │
│  │    │    ├─ languages/typescript                                            │ │
│  │    │    └─ backend/nestjs (if present)                                     │ │
│  │    │                                                                       │ │
│  │    ├─ Knowledge loaded:                                                    │ │
│  │    │    ├─ [branch] gaming/unity-ecs-patterns.md                           │ │
│  │    │    ├─ [profile] react-native-architecture.md                          │ │
│  │    │    ├─ [flag:has_auth] security/authentication-patterns.md             │ │
│  │    │    └─ [flag:personal_data] rgpd/data-protection.md                    │ │
│  │    │                                                                       │ │
│  │    └─ Triggered agents (summaries only):                                   │ │
│  │         ├─ security.md (first 50 lines)                                    │ │
│  │         └─ rgpd.md (first 50 lines)                                        │ │
│  │                                                                            │ │
│  └────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                 │
│  TOTAL TOKENS: ~12K (within budget)                                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Reference: Context Flags (preloader)

The preloader (`lib/context-preloader.sh`) detects **context flags** from the request, then loads the corresponding JIT knowledge and optionally triggers a parallel validation agent. Authoritative mapping: `_mock_classification()` (keywords) and `_get_knowledge_for_flag()` (knowledge).

| Flag | Trigger keywords | Knowledge loaded (JIT) | Triggered agent |
|------|------------------------|------------------------|-----------------|
| `has_auth` | auth, login, password, authentif | `knowledge/domains/security/owasp-checklists.md` | security |
| `personal_data` | user, profil, donnee, data, personal | `knowledge/domains/security/data-protection.md` | rgpd |
| `is_game` | game, jeu, gaming | `knowledge/domains/gaming/unity-ecs-patterns.md` | — |
| `is_mobile` | mobile, react-native, flutter | `knowledge/frameworks/react/react-native-architecture.md` | — |
| `is_web` | web, site, page, front | `knowledge/frameworks/react/architecture.md` | — |
| `is_python` | python, django, flask, fastapi, pip | `knowledge/languages/python/async-python-patterns.md` | — |
| `is_go` | golang, go, gin, echo, fiber | `knowledge/shared/patterns/error-handling-patterns.md` | — |
| `is_rust` | rust, cargo, tokio, actix | `knowledge/shared/patterns/error-handling-patterns.md` | — |
| `is_api` | api, endpoint, rest, graphql, backend | `knowledge/shared/patterns/api-design-principles.md` | — |
| `has_testing` | test, testing, jest, pytest, spec | `knowledge/shared/patterns/tdd-workflow.md` | — |
| `is_ai` | ai, llm, model, embed | `knowledge/domains/ai/prompt-engineering-patterns.md` | ai-specialist |

> Note: these **preloader** flags are distinct from the **Guardian routing** flags defined in `config/routing-rules.yaml` (`has_ui`, `has_db_schema`, `security_critical`, `has_minors`, `has_media`, `has_social`, `legal_compliance`…), used by the aria-detector for agent routing.

### Profile Detection (from project files)

In addition to flags, the preloader detects the tech stack via `_detect_profiles_flat()`:

| Project file | Detected profile |
|----------------|----------------|
| `package.json` (`react`) | `frontend/react` |
| `package.json` (`react-native`) | `mobile/react-native` |
| `package.json` (`@nestjs/core`) | `backend/nestjs` |
| `package.json` (`next`) | `frontend/nextjs` |
| `package.json` (devDep `typescript`) | `languages/typescript` |
| `pubspec.yaml` | `mobile/flutter`, `languages/dart` |
| `requirements.txt` | `languages/python` |
| `go.mod` | `languages/go` |
| `Cargo.toml` | `languages/rust` |

---

## System Files

```
lib/
├── config-loader.sh          ✅ DONE    # resolve_agent(), branch cache
├── context-preloader.sh      ✅ DONE    # RouteLLM classification (CLAUDECODE>API>pattern) + orchestration
├── profile-loader.sh         ❌ TODO    # Tech stack detection
├── knowledge-loader.sh       ❌ TODO    # JIT knowledge loading
└── memory-injector.sh        ❌ TODO    # Write to working.json

config/
├── routing-rules.yaml        ✅ DONE    # context_flag_triggers defined
├── overrides.yaml            ✅ DONE    # Project customization
└── model-tiers.yaml          ✅ DONE    # Haiku/Sonnet/Opus config
```
