# How Harmony Works

> **🌐 Language:** English · [Français](fr/how-it-works.md)

> A guided tour of what Harmony actually does — from a single request to a
> self-improving project that never repeats its mistakes.

Harmony works as a **loop**. On every request it routes the right agent
(**Guardian**), remembers every error it has seen (**Sentinel**), and proves the
result instead of assuming it (**HQVF**). Then it *learns* from what you did — so
the next session starts smarter, loads less, and avoids past bugs.

This page walks through each piece, with the diagrams that show it in action.

## On this page

- [1 · The Three Pillars](#1--the-three-pillars) — routing, error memory, quality gates
- [2 · The Self-Improving Engine](#2--the-self-improving-engine) — how your work becomes knowledge
- [3 · Working Without Losing Context](#3--working-without-losing-context) — UCVs & JIT loading
- [4 · Runs Everywhere](#4--runs-everywhere) — IDEs, stacks, profiles, specialties
- [5 · Harmony vs Other Frameworks](#5--harmony-vs-other-frameworks)
- [6 · Architecture: Core vs Local](#6--architecture-core-vs-local)

---

## 1 · The Three Pillars

The foundation. Three systems that fire on every request.

### Guardian — intelligent routing

Every request reaches the right agent **with the right context already loaded** —
before the agent says a word. Guardian classifies intent, preloads only the
knowledge that request needs, and hands off with a line you can actually see.

```
User: "develop the scoring system"
         |
         v
+--------------------------------------------------+
|  1 . INTENT + CONTEXT  (RouteLLM, config model)  |
|      path:  Claude Code  >  API key  >  keywords |
|      result: intent=IMPLEMENT  flags=[is_game]   |
+--------------------------------------------------+
|  2 . PREREQUISITE CHECK                          |
|      story required for code changes (strict)    |
+--------------------------------------------------+
|  3 . JIT CONTEXT PRELOAD  (<= 15K tokens)        |
|      + gaming knowledge   + matching profiles    |
+--------------------------------------------------+
|  4 . VISIBLE HANDOFF                             |
|      shows the context summary, then activates   |
+--------------------------------------------------+
         |
         v
  Developer activated -- with context, not blind
```

You see the handoff every time:

```
📥 Context: agent=developer · intent=IMPLEMENT · flags=[is_game] → +tester · 2 knowledge · ~4k tokens
```

**The classifier model is configurable, and the execution path is resolved by
priority — never hardcoded:**

| Where you run | What classifies intent | API key needed? |
|---------------|------------------------|:---------------:|
| **Claude Code** | a sub-agent on your existing session (model from config) | **No** |
| CLI / standalone | direct API call (Anthropic, OpenAI, …) | Yes |
| Offline / fallback | deterministic keyword matching | No |

The router's job is to map your free-form wording onto Harmony's known
vocabulary — so the right specialty, knowledge and agents fire **without you
maintaining a dictionary of synonyms**. Pick the model in
`config/routing-rules.yaml` (`router_model`); override per project anytime.

### Sentinel — error memory

Remembers every failure, stops runaway loops with a circuit breaker, and turns
bugs into reusable patterns.

```
┌─────────────────────────────────────────┐
│         CIRCUIT BREAKER STATE           │
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

> *(Example dashboard state.)*

And you don't have to open a dashboard to know it's working — Sentinel prints its
state on every guarded action:

```
🧠 Sentinel: circuit CLOSED (0/3 failures)
```

**Result**: recurring bugs drop sharply — the same error isn't repeated twice.

### HQVF — quality verification

Every use case is broken into verifiable checks, each validated three times
(DEV + TEST + QA). 100% coverage = done. No "it works on my machine".

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

**Result**: a definition of "done" you can prove, not assume.

### Observable by design

You shouldn't have to *trust* that the framework ran — you should *see* it. Every
guard and every routing decision announces itself in the terminal, the moment it
fires:

| When | What you see |
|------|--------------|
| An agent is dispatched | `📥 Context: agent=developer · intent=IMPLEMENT · flags=[has_auth] → +security,+rgpd` |
| Before each guarded action | `🧠 Sentinel: circuit CLOSED (0/3 failures)` |
| A risky command is screened | `🛡️ Rules: clean — no interdiction` (or a block, with the reason) |
| A package install is checked | `📦 Supply-chain: clean — install screened` |

No dashboards, no guesswork — visible proof beats blind trust. Too chatty for your
taste? One switch silences it: `HARMONY_HOOK_UI=off`.

---

## 2 · The Self-Improving Engine

The pillars do the work; this is what makes Harmony get *better* over time.

### Knowledge flow

Harmony turns everything you do into reusable knowledge:

| Source | → Harmony Learns | → AI Applies |
|--------|:----------------:|:------------:|
| 🐛 Your bugs | Patterns documented | Never repeated |
| 📚 Web articles | `/harmony learn <url>` | Context-aware suggestions |
| 🏢 Team decisions | ADRs stored | Consistent architecture |
| 🎯 Project rules | Profiles activated | Auto-enforced |

### Your style + your errors = your framework

Harmony lives in *your* project, learns *your* patterns, adapts to *your* style.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🎭 YOUR STYLE + YOUR ERRORS = YOUR FRAMEWORK                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🧠 LOCAL AI ARCHITECTURE                                                    ║
║   ────────────────────────                                                    ║
║   Harmony lives in YOUR project, learns YOUR patterns, adapts to YOUR style   ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │                                                                     │     ║
║   │   👨‍💻 Your coding style    →  Profiles auto-generated                │     ║
║   │   ❌ Your errors          →  Patterns auto-created                  │     ║
║   │   ✅ Your fixes           →  Solutions auto-documented              │     ║
║   │   🎯 Your context         →  AI reacts appropriately                │     ║
║   │                                                                     │     ║
║   │   Every developer has a UNIQUE perspective.                         │     ║
║   │   Every mistake is a LEARNING opportunity.                          │     ║
║   │   Every fix enriches the COLLECTIVE knowledge.                      │     ║
║   │                                                                     │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
║   💡 No senior needed. No documentation to write. Just code naturally.        ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### The contribution cycle

A bug you fix can become a pattern others reuse — from your terminal to the world.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 FROM YOUR TERMINAL TO THE WORLD                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║       ┌───────────────┐                                                       ║
║       │   YOU CODE    │                                                       ║
║       │   YOUR WAY    │                                                       ║
║       └───────────────┘                                                       ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐           ║
║       │  ❌ Error     │────►│  🛡️ Harmony   │────►│  📦 Pattern   │           ║
║       │   Happens     │     │    Learns     │     │   Created     │           ║
║       └───────────────┘     └───────────────┘     └───────┬───────┘           ║
║                                                           │                   ║
║               ┌───────────────────────────────────────────┘                   ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐           ║
║       │  📤 Export    │────►│  🌍 Community │────►│  🚀 Published │           ║
║       │   Pattern     │     │    Reviews    │     │   to npm      │           ║
║       └───────────────┘     └───────────────┘     └───────────────┘           ║
║                                                                               ║
║   🎯 Result: Your unique experience helps thousands of developers             ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Action | Effort | Impact | Ready to Publish? |
|--------|:------:|:------:|:-----------------:|
| 🐛 Fix a bug | **0** (automatic) | Pattern created | ✅ Exportable |
| 📝 Document error | 1 command | Shared knowledge | ✅ PR-ready |
| 🔄 Share pattern | 1 PR | Help thousands | ✅ Reviewed format |
| ⬇️ Get updates | 1 command | Access all patterns | ✅ Auto-merge |

> **🚀 From your terminal to npm in 3 steps:**
> `fix bug` → `/harmony sentinel --learn` → `git push` → **Published!**

---

## 3 · Working Without Losing Context

How Harmony lets you work for days without re-explaining everything — while
keeping token usage low.

### Zero context loss (UCVs)

Use Case Verifiables checkpoint your progress so any session can resume exactly
where the last one stopped.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🔄 WORK FOR DAYS WITHOUT STOPPING                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ❌ TRADITIONAL AI                 ✅ HARMONY + UCVs                         ║
║   ─────────────────                 ──────────────────                        ║
║   Session 1: Starts fresh           Session 1: Creates UCVs                   ║
║   Session 2: Lost context           Session 2: Resumes from V-003-2           ║
║   Session 3: Re-explain everything  Session 3: Knows exactly where we were    ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │                     📋 USE CASE VERIFIABLES                         │     ║
║   ├─────────────────────────────────────────────────────────────────────┤     ║
║   │                                                                     │     ║
║   │   UC-001: Login Form                                                │     ║
║   │   ├── V-001-1: Email validation ✅ DEV ✅ TEST ✅ QA                │     ║
║   │   ├── V-001-2: Password strength ✅ DEV ✅ TEST ⏳ QA               │     ║
║   │   └── V-001-3: Remember me      ⏳ DEV                              │     ║
║   │                                                                     │     ║
║   │   📍 Context: "Resume from V-001-3, Remember me checkbox"           │     ║
║   │   🎯 AI knows: What's done, what's pending, what's next             │     ║
║   │                                                                     │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
║   💡 Chain work across sessions, days, or weeks - NOTHING is lost.            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Without UCVs | With UCVs |
|:------------:|:---------:|
| 🔄 Re-explain context every session | ✅ Auto-resume from checkpoint |
| ❓ "Where were we?" | ✅ "Continue V-003-2" |
| 🤷 Subjective "done" | ✅ 100% verifiable coverage |
| 😤 "Works on my machine" | ✅ Triple validation (DEV+TEST+QA) |

### JIT context loading

Instead of loading everything every session, Harmony loads **only what the
current request needs** — keeping prompts small and cheap.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ⚡ JIT CONTEXT LOADING                                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Traditional:              Harmony:                                          ║
║   ────────────              ─────────                                         ║
║   Load ALL context          Load ONLY what's needed                           ║
║   Every session             When needed                                       ║
║   ~50K tokens               ~5K tokens                                        ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐     ║
║   │  User: "fix the login bug"                                          │     ║
║   │                    ↓                                                │     ║
║   │  Harmony detects: Intent=FIX, Module=Auth, File=login.ts            │     ║
║   │                    ↓                                                │     ║
║   │  Loads ONLY:                                                        │     ║
║   │  ├── 🔐 Auth patterns (2K tokens)                                   │     ║
║   │  ├── 🐛 Past login errors (1K tokens)                               │     ║
║   │  └── 📄 login.ts context (2K tokens)                                │     ║
║   │                    ↓                                                │     ║
║   │  Total: 5K tokens instead of 50K = 90% savings                      │     ║
║   └─────────────────────────────────────────────────────────────────────┘     ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Context Type | When Loaded | Tokens |
|--------------|:-----------:|:------:|
| 🎯 Intent rules | On message | ~500 |
| 🔧 Module patterns | On detection | ~2K |
| 🐛 Error history | On similar error | ~1K |
| 📄 File context | On file access | ~2K |
| **Total per request** | **JIT** | **~5K** |

---

## 4 · Runs Everywhere

Harmony adapts to your IDE, your stack and your team size — and the knowledge it
builds is portable.

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 ADAPTS TO YOUR WORLD                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔌 ANY IDE              🛠️ ANY STACK             🏢 ANY TEAM SIZE           ║
║   ─────────              ───────────              ──────────────              ║
║   Claude Code            TypeScript               Solo dev                    ║
║   Cursor                 Python                   Startup (5)                 ║
║   Windsurf               Go, Rust                 Scale-up (50)               ║
║   Continue               React, Vue               Enterprise (500+)           ║
║   Cody                   Node, Django             Remote teams                ║
║                                                                               ║
║   🎯 AUTO-DETECTION: Profiles activate based on your project context          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### IDE support

| IDE | Status | Features |
|-----|:------:|----------|
| 🟣 **Claude Code** | 🟢 Full | Hooks, Memory, MCP, Skills |
| 🔵 **Cursor** | 🟡 Good | Rules, Personas |
| 🟢 **Windsurf** | 🟡 Good | Rules |
| 🟠 **Continue** | 🟡 Good | Assistants, Context |
| 🔴 **Cody** | 🟠 Partial | Prompts |

### Tech stack profiles (framework-agnostic)

Profiles & specialties are **portable knowledge** — not tied to Harmony, not
framework-specific, not IDE-locked. They travel with you across projects and editors.

| Profile | Auto-Detected | Knowledge Loaded |
|---------|:-------------:|------------------|
| 🟦 TypeScript | `.ts`, `.tsx` | Best practices, common pitfalls |
| 🐍 Python | `.py` | PEP8, async patterns |
| ⚛️ React | `react` in deps | Hooks, state management |
| 🟢 Node.js | `node` in engines | Event loop, streams |
| 🐳 Docker | `Dockerfile` | Multi-stage, security |
| 🗄️ Prisma | `schema.prisma` | Migrations, relations |

### Specialties (domain knowledge)

| Specialty | Focus Areas | Portable? |
|-----------|-------------|:---------:|
| 🎮 Gaming | Game mechanics, leaderboards, progression | ✅ |
| 🏥 Healthcare | HIPAA, patient data, compliance | ✅ |
| 💳 FinTech | PCI-DSS, transactions, audit trails | ✅ |
| 🛒 E-commerce | Cart, payments, inventory | ✅ |

> **💡 Your profiles travel with you** — switch IDE, switch project, keep your knowledge.

---

## 5 · Harmony vs Other Frameworks

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

## 6 · Architecture: Core vs Local

> **Key principle**: separate the framework (shareable) from project data (local).

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE HARMONY                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   .harmony/                    CORE FRAMEWORK (Read-Only)       │
│   ├── agents/                  Agent definitions                │
│   ├── workflows/               Workflow definitions             │
│   ├── templates/               Reusable templates               │
│   ├── patterns/                Documented patterns              │
│   ├── rules/                   Framework rules                  │
│   └── docs/                    Documentation                    │
│                                                                 │
│   .harmony/local/              PROJECT DATA (mutable, local)    │
│   └── memory/                  ← Project-specific data          │
│       ├── working.json         Sprint/Story tracking            │
│       ├── workflow-state.json  Workflow state                   │
│       ├── error-journal.json   Project errors                   │
│       └── learned-patterns.json Discovered patterns             │
│                                                                 │
│   .claude/                     IDE CONFIG (Claude Code)         │
│   ├── commands/                                                 │
│   │   └── harmony.md           /harmony skill                   │
│   └── settings.json            Hooks configuration (7 hooks)    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Why this separation?

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
