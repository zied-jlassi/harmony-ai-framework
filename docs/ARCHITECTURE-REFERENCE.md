# Harmony Framework - Architecture Reference

> **🌐 Language:** English · [Français](fr/ARCHITECTURE-REFERENCE.md)

> **Version**: 2.0.0
> **Date**: 2026-01-06
> **Status**: AUTHORITATIVE
> **Purpose**: Definitive reference document for the Harmony architecture
> **Audience**: Claude in future sessions - visual diagrams of relationships

---

## 🎯 Overview - Main Flow

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

## 🏛️ The Three Pillars - Detailed Diagrams

### Pillar 1: GUARDIAN Protocol

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

### Pillar 2: SENTINEL System

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

### Pillar 3: HQVF Quality

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

## 🤖 Agent Ecosystem

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

## 📚 Profiles & Specialties - Relationship

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
│   Installed in: .harmony/local/memory/                                            │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  TIER 1: WORKING MEMORY (Hot - Always Loaded)               │          │
│   │  Location: .harmony/local/memory/working.json                      │          │
│   │  • Current sprint state, Active story                       │          │
│   │  • Current phase (PLANNING/DEV/TEST/REVIEW)                 │          │
│   │  • Session context, Recent errors (last 10)                 │          │
│   └───────────────────────────┬─────────────────────────────────┘          │
│                               ▼                                             │
│   ┌─────────────────────────────────────────────────────────────┐          │
│   │  TIER 2: SESSION MEMORY (Warm - Loaded on Demand)           │          │
│   │  Location: .harmony/local/memory/                                  │          │
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

## 📦 Libraries (lib/) - Assistant Toolkit

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
│   │                 ASSISTANT TOOLKIT (5 modules)                │          │
│   │                                                              │          │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │          │
│   │  │   model-    │  │    auto-    │  │   repomap   │         │          │
│   │  │  manager.sh │  │  linter.sh  │  │     .sh     │         │          │
│   │  │ Model alias │  │ Lang detect │  │ Repo struct │         │          │
│   │  │ Tier system │  │ Multi-lint  │  │ Key files   │         │          │
│   │  └─────────────┘  └─────────────┘  └─────────────┘         │          │
│   │                                                              │          │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │          │
│   │  │    file-    │  │  history-   │  │  assistant- │         │          │
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

### Model Tiers (Assistant Toolkit)

| Tier | Purpose | Models |
|------|---------|--------|
| Main | Complex reasoning | opus, gpt-4, o1 |
| Editor | Code editing | sonnet, gpt-4o |
| Weak | Simple tasks | haiku, deepseek-chat |

---

## 🎯 Final Summary

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

## Detailed Table of Contents

### Visual Diagrams (New Section v2.0)
- [Overview - Main Flow](#-overview---main-flow)
- [The Three Pillars](#️-the-three-pillars---detailed-diagrams)
- [Agent Ecosystem](#-agent-ecosystem)
- [Profiles & Specialties](#-profiles--specialties---relationship)
- [Knowledge & Patterns](#-knowledge--patterns)
- [Rules System](#️-rules-system)
- [Routing System](#-routing-system)
- [Memory System (3-Tier)](#-memory-system-3-tier)
- [Workflow Phases](#-workflow-phases)
- [Libraries (Assistant Toolkit)](#-libraries-lib---assistant-toolkit)
- [Component Relationships](#-component-relationships-summary)
- [Quick Reference Tables](#-quick-reference-tables)

### Detailed Documentation
1. [Harmony Philosophy](#1-harmony-philosophy)
2. [Architecture Rules](#2-architecture-rules)
3. [Agent Hierarchy](#3-agent-hierarchy)
4. [Specialties vs Profiles](#4-specialties-vs-profiles)
5. [Framework vs User Space](#5-framework-vs-user-space)
6. [Unique Harmony Systems](#6-unique-harmony-systems)
7. [Current Structure](#7-current-structure-post-restructure-2026-01)

---

## 1. Harmony Philosophy

### Motto
```
"Learn. Protect. Deliver."
```

### What Harmony brings

Harmony focuses on **quality**, **memory**, and **protection** — complementary layers to any workflow orchestration:

| Capability | Harmony's contribution |
|----------|----------------|
| **Focus** | Quality + Memory + Protection |
| **Memory** | Sentinel (error-journal, learned patterns, cross-session) |
| **Protection** | Guardian (intent routing, circuit breaker) |
| **Quality** | HQVF (mandatory UCVs, triple validation) |
| **Agents** | Functional descriptors (native routing by capability) |

### Complementarity with a workflow orchestrator

Harmony integrates with an external orchestration framework (Discovery → Release):
the two are **complementary** — orchestration drives the flow, Harmony adds
quality, memory, and guardrails. The goal is information sharing, not
substitution.

---

## 2. Architecture Rules

### R1: No cross-references between agents

```
❌ INTERDIT:
agents/developer.md → "voir aussi agents/tester.md"

✅ AUTORISÉ:
agents/developer.md → "voir workflows/implementation.md"
```

**Reason**: Each agent is autonomous. Workflows orchestrate, not agents.

### R2: Descriptive names (no personas)

```
❌ INTERDIT:
agents/bob-scrum-master.md
agents/amelia-developer.md

✅ AUTORISÉ:
agents/scrum-master.md
agents/developer.md
```

**Reason**: Personas live INSIDE the file, not in the name. This simplifies maintenance.

### R3: Flat structure by category

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

**Reason**: Predictable navigation. No infinite nesting. AI knowledge in specialties/.

### R4: Specialties for domain-specific content

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

**Reason**: Total isolation. A gaming project loads ONLY gaming/, not security/.

### R5: Knowledge packs instead of individual skills

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

**Reason**: JIT loading. Load the pack when needed, not 500 files.

---

## 3. Agent Hierarchy

### Overview

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

### When to use which agent

| Need | Agent | File |
|--------|-------|---------|
| Analyze requirements | Analyst | `agents/analyst.md` |
| Design architecture | Architect | `agents/architect.md` |
| Implement code | Developer | `agents/developer.md` |
| Write automated tests | Tester | `agents/tester.md` |
| Plan sprints/stories | Scrum Master | `agents/scrum-master.md` |
| Exploratory UI testing | Luna | `agents/exploratory-qa.md` |
| Create UCVs | Clara | `specialties/ucv/branchs/writer.md` |
| Validate UCVs | Victor | `specialties/ucv/branchs/validator.md` |
| Design RAG | Riley | `specialties/ai/knowledge/rag-patterns.md` |
| Design memory | Milo | `specialties/ai/knowledge/memory-patterns.md` |
| Multi-agents | Oscar | `specialties/ai/knowledge/orchestration-patterns.md` |

---

## 4. Specialties vs Profiles

### Specialties = Business domain

**Loading**: At project startup, based on `project_type`

```yaml
# .harmony/local/config/overrides.yaml
project:
  type: gaming  # → Charge specialties/gaming/

# Résultat:
# - agents/game-developer.md disponible
# - agents/game-designer.md disponible
# - knowledge/game-mechanics.md disponible
```

**Examples of Specialties**:
- `gaming/` - Games, scores, leaderboards
- `security/` - Pentest, hardening, compliance
- `creative/` - Design, UX, branding
- `medical/` - HIPAA, patient data
- `finance/` - PCI-DSS, transactions

### Profiles = Technical stack

**Loading**: JIT (Just-In-Time), on demand

```yaml
# .harmony/local/config/overrides.yaml
profiles:
  - nestjs
  - prisma
  - react

# Résultat:
# Chargé SEULEMENT quand Claude travaille sur ce stack
```

**Examples of Profiles**:
- `nestjs/` - Guards, interceptors, modules
- `prisma/` - Migrations, schema, queries
- `react/` - Hooks, components, state
- `angular/` - Services, modules, RxJS
- `docker/` - Compose, Dockerfile, networks

### Key difference

| Aspect | Specialty | Profile |
|--------|-----------|---------|
| **When** | At startup | On demand |
| **Scope** | Business domain | Technical stack |
| **Content** | Agents + Knowledge | Knowledge only |
| **Example** | "This project is a game" | "This file uses NestJS" |

---

## 5. Framework vs User Space

### P-012 Protection (Framework Guardian)

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

### Guardian Hook

The `.claude/hooks/guardian-checkpoint.sh` hook automatically blocks:
- Any write into `.harmony/agents/`
- Any write into `.harmony/workflows/`
- Framework modifications without an explicit override

### How to customize

```bash
# ❌ INTERDIT - Modifier directement
Edit .harmony/agents/developer.md

# ✅ AUTORISÉ - Créer un override
Write .harmony/local/overrides/agents/developer.md
# → L'override sera chargé EN PRIORITÉ sur le framework
```

---

## 6. Unique Harmony Systems

### Sentinel (Persistent memory)

```
.harmony/local/memory/
├── error-journal.json       # Journal des erreurs avec patterns
├── circuit-breaker.json     # État protection (3 retries max)
├── learned-patterns.json    # Patterns appris et validés
└── anti-patterns.json       # Anti-patterns à éviter
```

**Commands**:
```bash
/harmony --mode sentinel            # Dashboard
/harmony --mode sentinel --learn    # Documenter erreur
/harmony --mode sentinel --reset    # Reset circuit breaker
```

### Guardian (Intelligent routing)

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

**UCV format**:
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

## 7. Current Structure (Post-Restructure 2026-01)

### Restructuring completed ✅

The agents structure has been flattened. All agents are now at the same level in `agents/`:

| Old Path | New Path | Status |
|---------------|----------------|--------|
| `agents/specialists/*.md` | `agents/*.md` | ✅ Moved |
| `agents/compliance/*.md` | `agents/*.md` | ✅ Moved |
| `agents/specialists/sub-agents/*.md` | `specialties/ai/knowledge/*-patterns.md` | ✅ Moved |

### AI Knowledge (not agents)

The AI sub-agents have been renamed to **knowledge files** in `specialties/ai/knowledge/`:

| Old | New | Command |
|--------|---------|----------|
| `rag-architect.md` | `rag-patterns.md` | `/ai:riley` |
| `memory-architect.md` | `memory-patterns.md` | `/ai:milo` |
| `orchestration-architect.md` | `orchestration-patterns.md` | `/ai:oscar` |
| `observability-architect.md` | `observability-patterns.md` | `/ai:olivia` |
| `graphrag-architect.md` | `graphrag-patterns.md` | `/ai:grace` |
| `safety-architect.md` | `safety-patterns.md` | `/ai:sage` |

### Rule for the future

```
AVANT de créer un nouvel agent:
1. Vérifier qu'il n'existe pas déjà dans agents/
2. Placer DIRECTEMENT dans agents/ (pas de sous-dossier)
3. Patterns de raisonnement → patterns/cognitive/
4. Suivre R1-R5
5. Mettre à jour ce document
```

---

## Appendix: Key Files

| File | Description |
|---------|-------------|
| `framework/docs/ARCHITECTURE-REFERENCE.md` | This document |
| `patterns/P-012-framework-guardian.md` | Framework protection pattern |
| `patterns/P-013-test-environment.md` | Test isolation pattern |

---

*Document v2.0 - Visual diagrams added. Last update: 2026-01-06*
