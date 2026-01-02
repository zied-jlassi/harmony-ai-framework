# How Harmony Works

> Technical explanation of Harmony's three pillars in action.

---

## 1. Guardian Protocol - Intelligent Routing

```
User: "develop the scoring system"
         ↓
┌─────────────────────────────────┐
│    GUARDIAN INTENT DETECTION     │
├─────────────────────────────────┤
│  Keywords: "develop", "scoring" │
│  Intent: IMPLEMENT              │
│  Context: Gaming                │
│  Story Required: Yes            │
└─────────────────────────────────┘
         ↓
  [Route to Developer Agent]
         ↓
  [Developer: Developer activated]
```

---

## 2. Sentinel System - Error Memory

```
┌─────────────────────────────────────────┐
│         CIRCUIT BREAKER STATE            │
├─────────────────────────────────────────┤
│  State: 🟢 CLOSED                       │
│  Failures: 0/3                          │
│                                         │
│  Error Journal:                         │
│  ├── 45 errors documented               │
│  ├── 42 resolved (93%)                  │
│  └── 0 recurring ✓                      │
│                                         │
│  Learned Patterns: 12                   │
│  Applied: 34 times                      │
└─────────────────────────────────────────┘
```

**Result**: -82% recurring bugs.

---

## 3. HQVF - Quality Verification

```yaml
# STORY-042-UCV.md
story: "User Profile Update"
status: APPROVED

use_cases:
  - id: UC-001
    title: "Open edit modal"
    verifications:
      - id: V-001-1
        description: "Modal centered on screen"
        dev: ✅    # Developer confirms
        test: ✅   # Tester validates
        qa: ✅     # QA approves

coverage: 100% → Story DONE ✓
```

**Result**: Zero "works on my machine".

---

## Feature Comparison

| Feature | LangChain | CrewAI | AutoGen | Semantic Kernel | **Harmony** |
|---------|:---------:|:------:|:-------:|:---------------:|:-----------:|
| **Error Memory** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Circuit Breaker** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Intent Detection** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Quality Gates (UCV)** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **3-Tier Memory** | ❌ | ❌ | Partial | ❌ | ✅ |
| **Story-Based Dev** | ❌ | ❌ | ❌ | ❌ | ✅ |
| **Multi-IDE** | ❌ | ❌ | ❌ | ❌ | ✅ |
| Multi-Agent | ✅ | ✅ | ✅ | ✅ | ✅ |
| Workflow Control | Partial | Partial | Partial | ✅ | ✅ |
| Production Ready | ✅ | ✅ | ✅ | ✅ | ✅ |

> **Note**: LangChain/CrewAI are code orchestration libraries. Harmony is an SDLC methodology framework. Different categories, complementary usage.

---

## Architecture: Core vs Local

> **Key principle**: Separate framework (shareable) from project data (local).

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE HARMONY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   .harmony/                    CORE FRAMEWORK (Read-Only)       │
│   ├── agents/                  Agent definitions                │
│   ├── workflows/               Workflow definitions             │
│   ├── templates/               Reusable templates               │
│   ├── patterns/                Documented patterns              │
│   ├── rules/                   Framework rules                  │
│   └── docs/                    Documentation                    │
│                                                                  │
│   .claude/                     PROJECT DATA (Local)             │
│   ├── memory/                  ← Project-specific data          │
│   │   ├── working.json         Sprint/Story tracking            │
│   │   ├── workflow-state.json  Workflow state                   │
│   │   ├── error-journal.json   Project errors                   │
│   │   └── learned-patterns.json Discovered patterns             │
│   ├── commands/                                                  │
│   │   └── harmony.md           /harmony skill                   │
│   └── settings.json            Hooks configuration              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Why This Separation?

| Aspect | Benefit |
|--------|---------|
| **Immutable core** | Update Harmony without losing your data |
| **Isolated data** | Your sprints/errors don't pollute the framework |
| **Clean PRs** | Contribute to core without project data |
| **Multi-project** | Same Harmony version, independent data |

---

## Related

- [Core Concepts](concepts.md)
- [Architecture](architecture.md)
- [Getting Started](getting-started.md)
