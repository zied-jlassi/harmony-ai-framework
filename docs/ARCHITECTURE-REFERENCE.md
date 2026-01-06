# Harmony Framework - Architecture Reference

> **Version**: 2.0.0
> **Date**: 2026-01-06
> **Status**: AUTHORITATIVE
> **Purpose**: Document de référence définitif pour l'architecture Harmony
> **Audience**: Claude dans futures sessions - schémas visuels des relations

---

## 🎯 Vue d'Ensemble - Flux Principal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HARMONY FRAMEWORK                                    │
│                    "Self-Improving AI Development"                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │  GUARDIAN   │    │  SENTINEL   │    │    HQVF     │                    │
│   │  Protocol   │    │   System    │    │   Quality   │                    │
│   │             │    │             │    │             │                    │
│   │  Detection  │    │   Memory    │    │    UCVs     │                    │
│   │  Routing    │    │  Learning   │    │ Validation  │                    │
│   │  Protection │    │  Recovery   │    │   Gates     │                    │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘                    │
│          │                  │                  │                            │
│          └──────────────────┼──────────────────┘                            │
│                             │                                               │
│                    ┌────────▼────────┐                                      │
│                    │   ORCHESTRATOR  │                                      │
│                    │  sprint-tracker │                                      │
│                    └────────┬────────┘                                      │
│                             │                                               │
│          ┌──────────────────┼──────────────────┐                            │
│          ▼                  ▼                  ▼                            │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │   AGENTS    │    │  WORKFLOWS  │    │   MEMORY    │                    │
│   │  Specialized│    │   Phases    │    │  3-Tier     │                    │
│   └─────────────┘    └─────────────┘    └─────────────┘                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏛️ Les Trois Piliers - Schémas Détaillés

### Pilier 1: GUARDIAN Protocol

```
┌─────────────────────────────────────────────────────────────────┐
│                     GUARDIAN PROTOCOL                            │
│              "Intent Detection & Agent Routing"                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   REQUEST ──► DETECTION ──► SCORING ──► ROUTING ──► AGENT      │
│                                                                 │
│   ┌─────────────────┐     ┌─────────────────┐                   │
│   │ detection-      │     │ routing-        │                   │
│   │ patterns.yaml   │     │ algorithm.yaml  │                   │
│   │                 │     │                 │                   │
│   │ • Keywords      │────►│ • Score calc    │                   │
│   │ • Patterns      │     │ • Thresholds    │                   │
│   │ • Context       │     │ • Fallbacks     │                   │
│   └─────────────────┘     └─────────────────┘                   │
│                                   │                             │
│                                   ▼                             │
│                          ┌─────────────────┐                    │
│                          │  AGENT ROUTER   │                    │
│                          │                 │                    │
│                          │ Score ≥ 80 ──► Specialist           │
│                          │ Score 50-79 ─► General              │
│                          │ Score < 50 ──► Harmony              │
│                          └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pilier 2: SENTINEL System

```
┌─────────────────────────────────────────────────────────────────┐
│                      SENTINEL SYSTEM                             │
│               "Memory, Learning & Recovery"                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ERROR ──► CAPTURE ──► ANALYZE ──► LEARN ──► PREVENT          │
│                                                                 │
│   ┌─────────────────┐     ┌─────────────────┐                   │
│   │ error-journal   │     │ circuit-breaker │                   │
│   │                 │     │                 │                   │
│   │ • Pattern match │     │ • Failure count │                   │
│   │ • Root cause    │     │ • State machine │                   │
│   │ • Solution map  │     │ • Auto-recovery │                   │
│   └────────┬────────┘     └────────┬────────┘                   │
│            │                       │                            │
│            ▼                       ▼                            │
│   ┌─────────────────────────────────────────┐                   │
│   │           ERROR LIBRARY                  │                   │
│   │        (JIT Loading - AutoLearning)      │                   │
│   │                                          │                   │
│   │  BASH-001 ─► Solution A                  │                   │
│   │  JS-001   ─► Solution B                  │                   │
│   │  PY-001   ─► Solution C                  │                   │
│   └─────────────────────────────────────────┘                   │
│                                                                 │
│   Circuit Breaker States:                                       │
│   ┌────────┐    ┌───────────┐    ┌────────┐                    │
│   │ CLOSED │───►│ HALF_OPEN │───►│  OPEN  │                    │
│   │  (OK)  │◄───│ (Testing) │◄───│(Blocked)│                    │
│   └────────┘    └───────────┘    └────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Pilier 3: HQVF Quality

```
┌─────────────────────────────────────────────────────────────────┐
│                         HQVF                                     │
│          "Harmony Quality Verification Framework"                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   STORY ──► UCV ──► VALIDATION ──► GATES ──► COMPLETION        │
│                                                                 │
│   ┌─────────────────────────────────────────┐                   │
│   │              UCV (Use Case Verifiable)   │                   │
│   │                                          │                   │
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │                   │
│   │  │  Given  │─►│  When   │─►│  Then   │  │                   │
│   │  │ Context │  │ Action  │  │ Result  │  │                   │
│   │  └─────────┘  └─────────┘  └─────────┘  │                   │
│   │                                          │                   │
│   │  Triple Validation:                      │                   │
│   │  1. Writer creates UCV                   │                   │
│   │  2. QA executes in browser               │                   │
│   │  3. Validator confirms 100%              │                   │
│   └─────────────────────────────────────────┘                   │
│                                                                 │
│   Quality Gates:                                                │
│   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │
│   │  LINT   │►│  TEST   │►│  BUILD  │►│ DEPLOY  │              │
│   │  Gate   │ │  Gate   │ │  Gate   │ │  Gate   │              │
│   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🤖 Écosystème des Agents

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AGENTS ECOSYSTEM                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                         ┌─────────────────┐                                 │
│                         │    HARMONY      │  ← Agent Principal              │
│                         │   (Orchestrator)│                                 │
│                         └────────┬────────┘                                 │
│                                  │                                          │
│           ┌──────────────────────┼──────────────────────┐                   │
│           │                      │                      │                   │
│           ▼                      ▼                      ▼                   │
│   ┌───────────────┐      ┌───────────────┐      ┌───────────────┐          │
│   │   GUARDIAN    │      │   SENTINEL    │      │   DEVELOPER   │          │
│   │   Protocol    │      │    Memory     │      │    Agent      │          │
│   │               │      │               │      │               │          │
│   │ • Detection   │      │ • Errors      │      │ • Coding      │          │
│   │ • Routing     │      │ • Learning    │      │ • Review      │          │
│   │ • Protection  │      │ • Recovery    │      │ • Debug       │          │
│   └───────────────┘      └───────────────┘      └───────────────┘          │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │                    SPECIALIST AGENTS                         │          │
│   │                                                              │          │
│   │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │          │
│   │  │ UCV-QA  │ │UCV-Write│ │UCV-Valid│ │Explorat.│           │          │
│   │  │         │ │         │ │         │ │   QA    │           │          │
│   │  └─────────┘ └─────────┘ └─────────┘ └─────────┘           │          │
│   │                                                              │          │
│   │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │          │
│   │  │Accessib.│ │Security │ │  RGPD   │ │Architect│           │          │
│   │  │ WCAG    │ │ Audit   │ │ GDPR    │ │         │           │          │
│   │  └─────────┘ └─────────┘ └─────────┘ └─────────┘           │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
│   Agent Location: framework/agents/*.md                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Profiles & Specialties - Relation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     PROFILES & SPECIALTIES                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   PROFILES (Language-specific knowledge) - JIT Loaded                       │
│   Location: framework/profiles/                                             │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │          │
│   │  │typescript│  │  python  │  │   rust   │  │    go    │    │          │
│   │  │• Patterns│  │• Patterns│  │• Patterns│  │• Patterns│    │          │
│   │  │• Linters │  │• Linters │  │• Linters │  │• Linters │    │          │
│   │  │• Testing │  │• Testing │  │• Testing │  │• Testing │    │          │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                  │                                          │
│                                  │ extends                                  │
│                                  ▼                                          │
│   SPECIALTIES (Domain-specific expertise) - Loaded at startup              │
│   Location: framework/specialties/                                          │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  ┌─────────────────────────────────────────────────────┐    │          │
│   │  │                    AI SPECIALTY                      │    │          │
│   │  │              framework/specialties/ai/               │    │          │
│   │  │                                                      │    │          │
│   │  │  manifest.yaml ─► Detection & Config                 │    │          │
│   │  │                                                      │    │          │
│   │  │  knowledge/                                          │    │          │
│   │  │  ├── rag-patterns.md      (RAG architectures)       │    │          │
│   │  │  ├── memory-systems.md    (Short/Long term)         │    │          │
│   │  │  ├── orchestration.md     (Multi-agent)             │    │          │
│   │  │  └── evaluation.md        (LLM eval methods)        │    │          │
│   │  └─────────────────────────────────────────────────────┘    │          │
│   │                                                              │          │
│   │  Future: web/, mobile/, devops/, data/                      │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
│   Relation: Profile = Language, Specialty = Domain                          │
│   Un agent peut utiliser: 1 Profile + N Specialties                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📖 Knowledge & Patterns

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      KNOWLEDGE & PATTERNS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   KNOWLEDGE (Framework-specific docs) - JIT loaded                          │
│   Location: framework/knowledge/                                            │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  frameworks/          languages/          tools/             │          │
│   │  ├── react.md         ├── typescript.md   ├── docker.md     │          │
│   │  ├── nextjs.md        ├── python.md       ├── kubernetes.md │          │
│   │  ├── vue.md           ├── rust.md         └── terraform.md  │          │
│   │  └── angular.md       └── go.md                              │          │
│   │                                                              │          │
│   │  Usage: JIT loaded by agents when relevant                   │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                  │                                          │
│                                  │ applied via                              │
│                                  ▼                                          │
│   PATTERNS (Reusable solutions)                                             │
│   Location: framework/patterns/                                             │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  Format: P-XXX-name.md                                       │          │
│   │                                                              │          │
│   │  ┌─────────────────────────────────────────────────────┐    │          │
│   │  │ P-001 Circuit Breaker    │ P-007 Feature Flags      │    │          │
│   │  │ P-002 Retry with Backoff │ P-008 Event Sourcing     │    │          │
│   │  │ P-003 Rate Limiting      │ P-009 CQRS               │    │          │
│   │  │ P-004 Bulkhead           │ P-010 Saga Pattern       │    │          │
│   │  │ P-005 Cache Aside        │ P-011 Strangler Fig      │    │          │
│   │  │ P-006 Sidecar            │ P-012 Ambassador         │    │          │
│   │  │                          │ P-013 Anti-Corruption    │    │          │
│   │  └─────────────────────────────────────────────────────┘    │          │
│   │                                                              │          │
│   │  7 patterns auto-détectables par Sentinel                   │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ⚖️ Rules System

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          RULES SYSTEM                                        │
│                    "Enforcement & Compliance"                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Location: framework/rules/   Format: R-XXX-name.yaml                      │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  ┌──────────────────────────────────────────────────────┐   │          │
│   │  │                    RULE STRUCTURE                     │   │          │
│   │  ├──────────────────────────────────────────────────────┤   │          │
│   │  │  id: R-001                                            │   │          │
│   │  │  name: "No Direct Commits to Main"                    │   │          │
│   │  │  enforcement: BLOCK | WARN | LOG                      │   │          │
│   │  │  phases: [commit, push, pr]                           │   │          │
│   │  │  conditions:                                          │   │          │
│   │  │    - branch: main                                     │   │          │
│   │  │    - action: direct_commit                            │   │          │
│   │  │  message: "Use feature branches"                      │   │          │
│   │  └──────────────────────────────────────────────────────┘   │          │
│   │                                                              │          │
│   │  Available Rules:                                            │          │
│   │  ┌────────────────────────────────────────────────────┐     │          │
│   │  │ R-001 Branch Protection    │ R-005 Code Coverage   │     │          │
│   │  │ R-002 Commit Message       │ R-006 Security Scan   │     │          │
│   │  │ R-003 PR Review Required   │ R-007 License Check   │     │          │
│   │  │ R-004 Test Required        │ R-008 Dependency Audit│     │          │
│   │  └────────────────────────────────────────────────────┘     │          │
│   │                                                              │          │
│   │  Enforcement: BLOCK → Stop | WARN → Log warning | LOG       │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔀 Routing System

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          ROUTING SYSTEM                                      │
│                    "Request → Agent Matching"                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Location: framework/routing/                                              │
│                                                                             │
│            USER REQUEST                                                     │
│                 │                                                           │
│                 ▼                                                           │
│   ┌─────────────────────────┐                                              │
│   │   detection-patterns    │  ← Keywords & Context Analysis               │
│   │        .yaml            │                                              │
│   └───────────┬─────────────┘                                              │
│               │                                                             │
│               ▼                                                             │
│   ┌─────────────────────────┐                                              │
│   │   routing-algorithm     │  ← Score Calculation                         │
│   │        .yaml            │                                              │
│   │                         │                                              │
│   │  score = Σ(keyword_weight × match_count)                               │
│   │        + context_bonus + specialty_boost                                │
│   └───────────┬─────────────┘                                              │
│               │                                                             │
│               ▼                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │                    AGENT SELECTION                           │          │
│   │                                                              │          │
│   │    Score ≥ 80    ───────►  Specialist Agent                 │          │
│   │    Score 50-79   ───────►  Domain Agent                     │          │
│   │    Score < 50    ───────►  Harmony (Default)                │          │
│   │                                                              │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 💾 Memory System (3-Tier)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       MEMORY SYSTEM (3-Tier)                                 │
│                 "JIT Loading - Load only what's needed"                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Installed in: .harmony/memory/                                            │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  TIER 1: WORKING MEMORY (Hot - Always Loaded)               │          │
│   │  Location: .harmony/memory/working.json                      │          │
│   │  • Current sprint state, Active story                       │          │
│   │  • Current phase (PLANNING/DEV/TEST/REVIEW)                 │          │
│   │  • Session context, Recent errors (last 10)                 │          │
│   └───────────────────────────┬─────────────────────────────────┘          │
│                               ▼                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  TIER 2: SESSION MEMORY (Warm - Loaded on Demand)           │          │
│   │  Location: .harmony/memory/                                  │          │
│   │  • circuit-breaker.json, error-journal.json                 │          │
│   │  • sprint-history.json, story-cache.json                    │          │
│   └───────────────────────────┬─────────────────────────────────┘          │
│                               ▼                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  TIER 3: PERSISTENT MEMORY (Cold - JIT Loaded)              │          │
│   │  Location: framework/error-library/                          │          │
│   │  • Global error solutions (BASH-001, JS-001, etc.)          │          │
│   │  • Pattern library, Knowledge base                          │          │
│   │  • Sync: MCP Memory ◄──► error-library                      │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
│   JIT Loading Flow:                                                         │
│   Error occurs → Check Tier1 → Check Tier2 → Load from Tier3 → Cache       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Workflow Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        WORKFLOW PHASES                                       │
│                   "Sprint → Story → Phase Flow"                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   SPRINT_START ──► STORIES ──► SPRINT_END ──► RETROSPECTIVE               │
│                                                                             │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐               │
│   │ PLANNING │──►│   DEV    │──►│   TEST   │──►│  REVIEW  │               │
│   │          │   │          │   │          │   │          │               │
│   │• Analyze │   │• Code    │   │• Unit    │   │• PR      │               │
│   │• Design  │   │• Impl    │   │• E2E     │   │• Approve │               │
│   │• UCVs    │   │• Refactor│   │• UCVs    │   │• Merge   │               │
│   └──────────┘   └──────────┘   └──────────┘   └──────────┘               │
│        │              │              │              │                       │
│   ┌────▼──────────────▼──────────────▼──────────────▼────┐                 │
│   │                  CIRCUIT BREAKER                      │                 │
│   │  Per-Story: Max 10 failures | Per-Phase: Max 5        │                 │
│   │  If exceeded → CB OPEN → Story BLOCKED               │                 │
│   └──────────────────────────────────────────────────────┘                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Libraries (lib/) - Aider Toolkit

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CORE LIBRARIES                                        │
│                   Location: framework/lib/                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │                   SPRINT TRACKER (1400+ lines)               │          │
│   │  Core orchestrator - Sprint/Story state machine              │          │
│   │  • init_sprint(), end_sprint()                              │          │
│   │  • Circuit breaker, Rate limiter, Response analyzer         │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │                   AIDER TOOLKIT (5 modules)                  │          │
│   │                                                              │          │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │          │
│   │  │   model-    │  │    auto-    │  │   repomap   │         │          │
│   │  │  manager.sh │  │  linter.sh  │  │     .sh     │         │          │
│   │  │ Model alias │  │ Lang detect │  │ Repo struct │         │          │
│   │  │ Tier system │  │ Multi-lint  │  │ Key files   │         │          │
│   │  └─────────────┘  └─────────────┘  └─────────────┘         │          │
│   │                                                              │          │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │          │
│   │  │    file-    │  │  history-   │  │    aider-   │         │          │
│   │  │  watcher.sh │  │summarizer.sh│  │  toolkit.sh │         │          │
│   │  │ Change det. │  │ Session log │  │ Orchestrator│         │          │
│   │  │ Hook system │  │ Compression │  │ Unified API │         │          │
│   │  └─────────────┘  └─────────────┘  └─────────────┘         │          │
│   └─────────────────────────────────────────────────────────────┘          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Component Relationships Summary

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    COMPONENT RELATIONSHIPS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   PROFILES ──────► Define language patterns, linters, testing              │
│       └──────────► Used by AUTO-LINTER to detect & lint files              │
│                                                                             │
│   SPECIALTIES ───► Domain expertise (AI, Web, DevOps)                      │
│       └──────────► Loaded by AGENTS when domain matches                    │
│                                                                             │
│   KNOWLEDGE ─────► Framework/language specific docs                        │
│       └──────────► JIT loaded by AGENTS for context                        │
│                                                                             │
│   PATTERNS ──────► Reusable architectural solutions                        │
│       └──────────► Applied by SENTINEL for error recovery                  │
│       └──────────► Recommended by DEVELOPER for implementation             │
│                                                                             │
│   RULES ─────────► Enforcement policies                                    │
│       └──────────► Checked by GUARDIAN at gates                            │
│       └──────────► Enforced in WORKFLOW phases                             │
│                                                                             │
│   ROUTING ───────► Request → Agent matching                                │
│       └──────────► Used by GUARDIAN for agent selection                    │
│                                                                             │
│   AGENTS ────────► Specialized task handlers                               │
│       └──────────► Load PROFILES + SPECIALTIES + KNOWLEDGE                 │
│       └──────────► Follow RULES during execution                           │
│       └──────────► Report to SENTINEL for learning                         │
│                                                                             │
│   MEMORY ────────► State persistence (3-tier)                              │
│       └──────────► Used by all components                                  │
│       └──────────► JIT loading for performance                             │
│                                                                             │
│   HQVF ──────────► Quality gates with UCVs                                 │
│       └──────────► Validates at WORKFLOW phase transitions                 │
│       └──────────► Uses specialist AGENTS (UCV-QA, Validator)              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Quick Reference Tables

### Commands (30 total)

| Category | Commands |
|----------|----------|
| Sprint | `/sprint start`, `/sprint end`, `/sprint status` |
| Story | `/story start`, `/story complete`, `/story status` |
| Phase | `/phase dev`, `/phase test`, `/phase review` |
| UCV | `/ucv create`, `/ucv run`, `/ucv validate` |
| Safety | `/halt`, `/resume`, `/circuit-status` |

### File Locations

| Component | Location |
|-----------|----------|
| Agents | `framework/agents/*.md` |
| Commands | `framework/commands/*.md` |
| Patterns | `framework/patterns/P-*.md` |
| Rules | `framework/rules/R-*.yaml` |
| Knowledge | `framework/knowledge/` |
| Profiles | `framework/profiles/` |
| Specialties | `framework/specialties/` |
| Routing | `framework/routing/` |
| Libraries | `framework/lib/*.sh` |
| Error Library | `framework/error-library/` |

### Model Tiers (Aider Toolkit)

| Tier | Purpose | Models |
|------|---------|--------|
| Main | Complex reasoning | opus, gpt-4, o1 |
| Editor | Code editing | sonnet, gpt-4o |
| Weak | Simple tasks | haiku, deepseek-chat |

---

## 🎯 Résumé Final

```
HARMONY = GUARDIAN + SENTINEL + HQVF

        ┌─────────────────────────────────────────┐
        │  Guardian: WHO should handle this?       │
        │  Sentinel: WHAT did we learn?           │
        │  HQVF: IS IT done correctly?            │
        └─────────────────────────────────────────┘

Memory: JIT loaded (CV analogy - only what's needed)
Agents: Specialized, routed by score
Rules: Enforced at gates
Patterns: Applied for solutions
```

---

## Table des Matières Détaillée

### Schémas Visuels (Nouvelle Section v2.0)
- [Vue d'Ensemble - Flux Principal](#-vue-densemble---flux-principal)
- [Les Trois Piliers](#️-les-trois-piliers---schémas-détaillés)
- [Écosystème des Agents](#-écosystème-des-agents)
- [Profiles & Specialties](#-profiles--specialties---relation)
- [Knowledge & Patterns](#-knowledge--patterns)
- [Rules System](#️-rules-system)
- [Routing System](#-routing-system)
- [Memory System (3-Tier)](#-memory-system-3-tier)
- [Workflow Phases](#-workflow-phases)
- [Libraries (Aider Toolkit)](#-libraries-lib---aider-toolkit)
- [Component Relationships](#-component-relationships-summary)
- [Quick Reference Tables](#-quick-reference-tables)

### Documentation Détaillée
1. [Philosophie Harmony](#1-philosophie-harmony)
2. [Règles d'Architecture](#2-règles-darchitecture)
3. [Hiérarchie des Agents](#3-hiérarchie-des-agents)
4. [Specialties vs Profiles](#4-specialties-vs-profiles)
5. [Framework vs User Space](#5-framework-vs-user-space)
6. [Systèmes Uniques Harmony](#6-systèmes-uniques-harmony)
7. [Duplications et Résolutions](#7-duplications-et-résolutions)

---

## 1. Philosophie Harmony

### Motto
```
"Learn. Protect. Deliver."
```

### Différence avec BMAD

| Aspect | BMAD | Harmony |
|--------|------|---------|
| **Focus** | Workflow orchestration | Quality + Memory |
| **Mémoire** | Aucune persistante | Sentinel (error-journal, patterns) |
| **Protection** | Aucune | Guardian (intent routing, circuit breaker) |
| **Qualité** | Tests classiques | HQVF (UCVs obligatoires) |
| **Agents** | Personas avec noms | Descriptifs fonctionnels |

### Coexistence BMAD + Harmony

```
BMAD → Orchestration des workflows (Discovery → Release)
Harmony → Qualité + Mémoire + Protection

Résultat combiné: 97% completion stories (benchmark interne)
```

---

## 2. Règles d'Architecture

### R1: Pas de références croisées entre agents

```
❌ INTERDIT:
agents/developer.md → "voir aussi agents/tester.md"

✅ AUTORISÉ:
agents/developer.md → "voir workflows/implementation.md"
```

**Raison**: Chaque agent est autonome. Les workflows orchestrent, pas les agents.

### R2: Noms descriptifs (pas de personas)

```
❌ INTERDIT:
agents/bob-scrum-master.md
agents/amelia-developer.md

✅ AUTORISÉ:
agents/scrum-master.md
agents/developer.md
```

**Raison**: Les personas sont DANS le fichier, pas dans le nom. Facilite la maintenance.

### R3: Structure plate par catégorie

```
agents/                     # Structure PLATE - tous les agents au même niveau
├── [core agents]           # analyst, architect, developer, etc.
├── [specialists]           # ai-architect, exploratory-qa, ucv-*, etc.
└── [compliance]            # security, rgpd, pentest, accessibility

patterns/cognitive/         # Patterns de raisonnement (séparé des agents)
└── react.md, reflection.md, lats.md, etc.

specialties/ai/             # Knowledge AI (pas des agents)
├── manifest.yaml           # Detection (langchain, openai, etc.)
└── knowledge/              # Patterns RAG, Memory, Orchestration...
```

**Raison**: Navigation prévisible. Pas de nesting infini. AI knowledge dans specialties/.

### R4: Specialties pour contenu domain-specific

```
specialties/
├── gaming/
│   ├── agents/             # game-developer.md, game-designer.md
│   └── knowledge/          # game-mechanics.md, scoring-systems.md
├── security/
│   ├── agents/
│   └── knowledge/
└── creative/
    ├── agents/
    └── knowledge/
```

**Raison**: Isolation totale. Un projet gaming charge SEULEMENT gaming/, pas security/.

### R5: Knowledge packs au lieu de skills individuels

```
❌ INTERDIT:
skills/
├── nestjs-setup.md
├── nestjs-guards.md
├── nestjs-interceptors.md
└── ... (500 fichiers)

✅ AUTORISÉ:
profiles/
└── nestjs/
    └── nestjs-knowledge.md  # Un fichier consolidé, chargeable à la demande
```

**Raison**: JIT loading. Charge le pack quand nécessaire, pas 500 fichiers.

---

## 3. Hiérarchie des Agents

### Vue d'ensemble

```
framework/agents/
│
├── [CORE AGENTS - 18 agents]
│   ├── analyst.md           # Business Analyst (Mary)
│   ├── architect.md         # Technical Architect (Winston)
│   ├── developer.md         # Developer (Amelia)
│   ├── tester.md            # QA Engineer (Emma)
│   ├── scrum-master.md      # Scrum Master (Bob) ← VERSION RICHE
│   ├── product-manager.md   # Product Manager (Olivia)
│   ├── tech-writer.md       # Technical Writer
│   ├── ux-designer.md       # UX Designer (Evan)
│   ├── guardian.md          # Intent Router + Circuit Breaker
│   ├── harmony.md           # Framework Orchestrator
│   ├── sentinel.md          # Memory Manager (error-journal)
│   ├── atlas.md             # Clean Architecture Validator
│   ├── quick-flow.md        # Rapid Development Mode
│   ├── quick-flow-solo.md   # Solo Dev Mode
│   ├── backlog.md           # Backlog Dashboard
│   ├── review.md            # Code Review
│   ├── supervisor.md        # Multi-Agent Supervisor
│   └── party.md             # Multi-Agent Brainstorming
│
├── [SPECIALISTS - au même niveau, pas de sous-dossier]
│   ├── exploratory-qa.md    # Luna - QA Exploratoire
│   ├── ai-architect.md      # Nova - AI/LLM Systems
│   ├── ucv-writer.md        # Clara - UCV Writer v2.0
│   ├── ucv-validator.md     # Victor - UCV Validator v2.0
│   └── ucv-qa.md            # UCV QA - Browser validation
│
└── [COMPLIANCE - au même niveau, pas de sous-dossier]
    ├── security.md          # Security Auditor
    ├── accessibility.md     # WCAG/RGAA/EAA
    ├── rgpd.md              # RGPD/Privacy Expert
    └── pentest.md           # Penetration Tester

patterns/
└── cognitive/               # [5 modules cognitifs]
    ├── react.md             # ReAct Pattern
    ├── reflection.md        # Self-Reflection
    ├── self-consistency.md  # Multi-Path Verification
    ├── lats.md              # Language Agent Tree Search
    └── graph-of-thoughts.md # Graph-based Reasoning
```

### Quand utiliser quel agent

| Besoin | Agent | Fichier |
|--------|-------|---------|
| Analyser requirements | Analyst | `agents/analyst.md` |
| Designer architecture | Architect | `agents/architect.md` |
| Implémenter code | Developer | `agents/developer.md` |
| Écrire tests automatisés | Tester | `agents/tester.md` |
| Planifier sprints/stories | Scrum Master | `agents/scrum-master.md` |
| Tests exploratoires UI | Luna | `agents/exploratory-qa.md` |
| Créer UCVs | Clara | `specialties/ucv/branchs/writer.md` |
| Valider UCVs | Victor | `specialties/ucv/branchs/validator.md` |
| Concevoir RAG | Riley | `specialties/ai/knowledge/rag-patterns.md` |
| Concevoir mémoire | Milo | `specialties/ai/knowledge/memory-patterns.md` |
| Multi-agents | Oscar | `specialties/ai/knowledge/orchestration-patterns.md` |

---

## 4. Specialties vs Profiles

### Specialties = Domaine métier

**Chargement**: Au démarrage projet, basé sur `project_type`

```yaml
# .harmony/local/config.yaml
project:
  type: gaming  # → Charge specialties/gaming/

# Résultat:
# - agents/game-developer.md disponible
# - agents/game-designer.md disponible
# - knowledge/game-mechanics.md disponible
```

**Exemples de Specialties**:
- `gaming/` - Jeux, scores, leaderboards
- `security/` - Pentest, hardening, compliance
- `creative/` - Design, UX, branding
- `medical/` - HIPAA, données patients
- `finance/` - PCI-DSS, transactions

### Profiles = Stack technique

**Chargement**: JIT (Just-In-Time), à la demande

```yaml
# .harmony/local/config.yaml
profiles:
  - nestjs
  - prisma
  - react

# Résultat:
# Chargé SEULEMENT quand Claude travaille sur ce stack
```

**Exemples de Profiles**:
- `nestjs/` - Guards, interceptors, modules
- `prisma/` - Migrations, schema, queries
- `react/` - Hooks, components, state
- `angular/` - Services, modules, RxJS
- `docker/` - Compose, Dockerfile, networks

### Différence clé

| Aspect | Specialty | Profile |
|--------|-----------|---------|
| **Quand** | Au démarrage | À la demande |
| **Scope** | Domaine métier | Stack technique |
| **Contenu** | Agents + Knowledge | Knowledge only |
| **Exemple** | "Ce projet est un jeu" | "Ce fichier utilise NestJS" |

---

## 5. Framework vs User Space

### Protection P-012 (Framework Guardian)

```
.harmony/
│
├── [FRAMEWORK - IMMUTABLE AFTER INSTALL]
│   ├── agents/              # ❌ Écriture interdite
│   ├── workflows/           # ❌ Écriture interdite
│   ├── patterns/            # ❌ Écriture interdite
│   ├── templates/           # ❌ Écriture interdite
│   ├── docs/                # ❌ Écriture interdite (framework docs)
│   └── bin/                 # ❌ Écriture interdite
│
└── local/                   # ✅ USER SPACE (mutable)
    ├── overrides/
    │   ├── agents/          # Custom agents
    │   └── hooks/           # Custom hooks
    ├── project/
    │   ├── backlog/         # Stories, epics
    │   ├── prd/             # PRD documents
    │   ├── architecture/    # ADRs
    │   └── rex/             # Retrospectives
    └── config.yaml          # Project config
```

### Hook Guardian

Le hook `.claude/hooks/guardian-checkpoint.sh` bloque automatiquement:
- Toute écriture dans `.harmony/agents/`
- Toute écriture dans `.harmony/workflows/`
- Modifications framework sans override explicite

### Comment customiser

```bash
# ❌ INTERDIT - Modifier directement
Edit .harmony/agents/developer.md

# ✅ AUTORISÉ - Créer un override
Write .harmony/local/overrides/agents/developer.md
# → L'override sera chargé EN PRIORITÉ sur le framework
```

---

## 6. Systèmes Uniques Harmony

### Sentinel (Mémoire persistante)

```
.claude/memory/
├── error-journal.json       # Journal des erreurs avec patterns
├── circuit-breaker.json     # État protection (3 retries max)
├── learned-patterns.json    # Patterns appris et validés
└── anti-patterns.json       # Anti-patterns à éviter
```

**Commandes**:
```bash
/harmony --mode sentinel            # Dashboard
/harmony --mode sentinel --learn    # Documenter erreur
/harmony --mode sentinel --reset    # Reset circuit breaker
```

### Guardian (Routage intelligent)

```
┌─────────────────────────────────────────┐
│         GUARDIAN PROTOCOL               │
├─────────────────────────────────────────┤
│                                         │
│  USER MESSAGE                           │
│       ↓                                 │
│  [Intent Detection]                     │
│  "corriger bug" → Intent: FIX           │
│       ↓                                 │
│  [Context Detection]                    │
│  "leaderboard" → Context: GAMING        │
│       ↓                                 │
│  [Story Check]                          │
│  Existe-t-il une story?                 │
│       ↓                                 │
│  [Route to Agent]                       │
│  Developer (gaming context)             │
│                                         │
└─────────────────────────────────────────┘
```

### HQVF (Quality Verification Framework)

```
STORY-XXX.md
     ↓
UCV Writer (Clara) crée STORY-XXX-UCV.md
     ↓
User APPROUVE les UCVs (Gate bloquant)
     ↓
Developer implémente + coche [dev]
     ↓
Tester teste + coche [test]
     ↓
Luna valide + coche [qa]
     ↓
UCV Validator vérifie 100%
     ↓
Story DONE
```

**Format UCV**:
```yaml
use_cases:
  - id: UC-001
    title: "Ouvrir formulaire modification"
    verifications:
      - id: V-001-1
        description: "Popin visible centrée"
        dev: false   # ☐ à cocher par DEV
        test: false  # ☐ à cocher par TEA
        qa: false    # ☐ à cocher par Luna
```

---

## 7. Structure Actuelle (Post-Restructure 2026-01)

### Restructuration effectuée ✅

La structure agents a été aplatie. Tous les agents sont maintenant au même niveau dans `agents/`:

| Ancien Chemin | Nouveau Chemin | Status |
|---------------|----------------|--------|
| `agents/specialists/*.md` | `agents/*.md` | ✅ Déplacé |
| `agents/compliance/*.md` | `agents/*.md` | ✅ Déplacé |
| `agents/specialists/sub-agents/*.md` | `specialties/ai/knowledge/*-patterns.md` | ✅ Déplacé |

### AI Knowledge (pas des agents)

Les sous-agents AI ont été renommés en **knowledge files** dans `specialties/ai/knowledge/`:

| Ancien | Nouveau | Commande |
|--------|---------|----------|
| `rag-architect.md` | `rag-patterns.md` | `/ai:riley` |
| `memory-architect.md` | `memory-patterns.md` | `/ai:milo` |
| `orchestration-architect.md` | `orchestration-patterns.md` | `/ai:oscar` |
| `observability-architect.md` | `observability-patterns.md` | `/ai:olivia` |
| `graphrag-architect.md` | `graphrag-patterns.md` | `/ai:grace` |
| `safety-architect.md` | `safety-patterns.md` | `/ai:sage` |

### Règle pour le futur

```
AVANT de créer un nouvel agent:
1. Vérifier qu'il n'existe pas déjà dans agents/
2. Placer DIRECTEMENT dans agents/ (pas de sous-dossier)
3. Patterns de raisonnement → patterns/cognitive/
4. Suivre R1-R5
5. Mettre à jour ce document
```

---

## Annexe: Fichiers Clés

| Fichier | Description |
|---------|-------------|
| `framework/docs/ARCHITECTURE-REFERENCE.md` | Ce document |
| `patterns/P-012-framework-guardian.md` | Pattern protection framework |
| `patterns/P-013-test-environment.md` | Pattern isolation tests |

---

*Document v2.0 - Schémas visuels ajoutés. Dernière mise à jour: 2026-01-06*
