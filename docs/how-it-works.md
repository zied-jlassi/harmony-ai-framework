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

## 🧠 Knowledge Flow

Harmony turns everything you do into reusable knowledge:

| Source | → Harmony Learns | → AI Applies |
|--------|:----------------:|:------------:|
| 🐛 Your bugs | Patterns documented | Never repeated |
| 📚 Web articles | `/harmony learn <url>` | Context-aware suggestions |
| 🏢 Team decisions | ADRs stored | Consistent architecture |
| 🎯 Project rules | Profiles activated | Auto-enforced |

---

## 🎭 Your Style + Your Errors = Your Framework

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🎭 YOUR STYLE + YOUR ERRORS = YOUR FRAMEWORK                  ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🧠 LOCAL AI ARCHITECTURE                                                    ║
║   ────────────────────────                                                    ║
║   Harmony lives in YOUR project, learns YOUR patterns, adapts to YOUR style  ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐    ║
║   │                                                                     │    ║
║   │   👨‍💻 Your coding style    →  Profiles auto-generated              │    ║
║   │   ❌ Your errors          →  Patterns auto-created                 │    ║
║   │   ✅ Your fixes           →  Solutions auto-documented             │    ║
║   │   🎯 Your context         →  AI reacts appropriately               │    ║
║   │                                                                     │    ║
║   │   Every developer has a UNIQUE perspective.                        │    ║
║   │   Every mistake is a LEARNING opportunity.                         │    ║
║   │   Every fix enriches the COLLECTIVE knowledge.                     │    ║
║   │                                                                     │    ║
║   └─────────────────────────────────────────────────────────────────────┘    ║
║                                                                               ║
║   💡 No senior needed. No documentation to write. Just code naturally.       ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

## 🔄 The Contribution Cycle

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 FROM YOUR TERMINAL TO THE WORLD                    ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║       ┌───────────────┐                                                       ║
║       │   YOU CODE    │                                                       ║
║       │   YOUR WAY    │                                                       ║
║       └───────┬───────┘                                                       ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐          ║
║       │  ❌ Error     │────►│  🛡️ Harmony   │────►│  📦 Pattern   │          ║
║       │   Happens     │     │    Learns     │     │   Created     │          ║
║       └───────────────┘     └───────────────┘     └───────┬───────┘          ║
║                                                           │                   ║
║               ┌───────────────────────────────────────────┘                   ║
║               │                                                               ║
║               ▼                                                               ║
║       ┌───────────────┐     ┌───────────────┐     ┌───────────────┐          ║
║       │  📤 Export    │────►│  🌍 Community │────►│  🚀 Published │          ║
║       │   Pattern     │     │    Reviews    │     │   to npm      │          ║
║       └───────────────┘     └───────────────┘     └───────────────┘          ║
║                                                                               ║
║   🎯 Result: Your unique experience helps thousands of developers            ║
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

## 🔄 Continuous Work, Zero Context Loss

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                 🔄 WORK FOR DAYS WITHOUT STOPPING                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ❌ TRADITIONAL AI                 ✅ HARMONY + UCVs                         ║
║   ─────────────────                 ──────────────────                        ║
║   Session 1: Starts fresh           Session 1: Creates UCVs                   ║
║   Session 2: Lost context           Session 2: Resumes from V-003-2           ║
║   Session 3: Re-explain everything  Session 3: Knows exactly where we were   ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐    ║
║   │                     📋 USE CASE VERIFIABLES                         │    ║
║   ├─────────────────────────────────────────────────────────────────────┤    ║
║   │                                                                     │    ║
║   │   UC-001: Login Form                                                │    ║
║   │   ├── V-001-1: Email validation ✅ DEV ✅ TEST ✅ QA               │    ║
║   │   ├── V-001-2: Password strength ✅ DEV ✅ TEST ⏳ QA              │    ║
║   │   └── V-001-3: Remember me      ⏳ DEV                             │    ║
║   │                                                                     │    ║
║   │   📍 Context: "Resume from V-001-3, Remember me checkbox"          │    ║
║   │   🎯 AI knows: What's done, what's pending, what's next            │    ║
║   │                                                                     │    ║
║   └─────────────────────────────────────────────────────────────────────┘    ║
║                                                                               ║
║   💡 Chain work across sessions, days, or weeks - NOTHING is lost.           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

| Without UCVs | With UCVs |
|:------------:|:---------:|
| 🔄 Re-explain context every session | ✅ Auto-resume from checkpoint |
| ❓ "Where were we?" | ✅ "Continue V-003-2" |
| 🤷 Subjective "done" | ✅ 100% verifiable coverage |
| 😤 "Works on my machine" | ✅ Triple validation (DEV+TEST+QA) |

---

## ⚡ JIT Context Loading

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ⚡ JIT CONTEXT LOADING                                      ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Traditional:              Harmony:                                          ║
║   ────────────              ─────────                                         ║
║   Load ALL context          Load ONLY what's needed                           ║
║   Every session             When needed                                       ║
║   ~50K tokens               ~5K tokens                                        ║
║                                                                               ║
║   ┌─────────────────────────────────────────────────────────────────────┐    ║
║   │  User: "fix the login bug"                                          │    ║
║   │                    ↓                                                 │    ║
║   │  Harmony detects: Intent=FIX, Module=Auth, File=login.ts            │    ║
║   │                    ↓                                                 │    ║
║   │  Loads ONLY:                                                        │    ║
║   │  ├── 🔐 Auth patterns (2K tokens)                                   │    ║
║   │  ├── 🐛 Past login errors (1K tokens)                               │    ║
║   │  └── 📄 login.ts context (2K tokens)                                │    ║
║   │                    ↓                                                 │    ║
║   │  Total: 5K tokens instead of 50K = 90% savings                      │    ║
║   └─────────────────────────────────────────────────────────────────────┘    ║
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

## 🔌 Works Everywhere

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🔄 ADAPTS TO YOUR WORLD                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔌 ANY IDE              🛠️ ANY STACK             🏢 ANY TEAM SIZE          ║
║   ─────────              ───────────              ──────────────              ║
║   Claude Code            TypeScript               Solo dev                    ║
║   Cursor                 Python                   Startup (5)                 ║
║   Windsurf               Go, Rust                 Scale-up (50)               ║
║   Continue               React, Vue               Enterprise (500+)           ║
║   Cody                   Node, Django             Remote teams                ║
║                                                                               ║
║   🎯 AUTO-DETECTION: Profiles activate based on your project context         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### IDE Support

| IDE | Status | Features |
|-----|:------:|----------|
| 🟣 **Claude Code** | 🟢 Full | Hooks, Memory, MCP, Skills |
| 🔵 **Cursor** | 🟡 Good | Rules, Personas |
| 🟢 **Windsurf** | 🟡 Good | Rules |
| 🟠 **Continue** | 🟡 Good | Assistants, Context |
| 🔴 **Cody** | 🟠 Partial | Prompts |

### Tech Stack Profiles (Framework-Agnostic)

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

### Specialties (Domain Knowledge)

| Specialty | Focus Areas | Portable? |
|-----------|-------------|:---------:|
| 🎮 Gaming | Game mechanics, leaderboards, progression | ✅ |
| 🏥 Healthcare | HIPAA, patient data, compliance | ✅ |
| 💳 FinTech | PCI-DSS, transactions, audit trails | ✅ |
| 🛒 E-commerce | Cart, payments, inventory | ✅ |

> **💡 Your profiles travel with you** — switch IDE, switch project, keep your knowledge.

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
