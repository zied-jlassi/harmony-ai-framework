<div align="center">

# 🛡️ Harmony Framework

### A self-improving AI dev framework for Claude Code, Cursor & more

**Smart agent routing · Error memory · Verifiable quality gates**

[![npm version](https://img.shields.io/npm/v/harmony-ai.svg?style=for-the-badge)](https://www.npmjs.com/package/harmony-ai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-18%2B-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![GitHub stars](https://img.shields.io/github/stars/zied-jlassi/harmony-ai-framework?style=for-the-badge)](https://github.com/zied-jlassi/harmony-ai-framework/stargazers)

[🚀 Quick Start](#-quick-start) • [📚 Docs](docs/INDEX.md) • [🧠 How it works](docs/how-it-works.md) • [🧩 Patterns](patterns/INDEX.md)

</div>

---

Harmony is an AI development framework that makes your AI assistant **route the right
agent, remember every bug it has seen, and prove quality instead of assuming it** —
across Claude Code, Cursor, Windsurf and more. It lives inside *your* project and adapts
to *your* code: load only what's needed, when it's needed.

> **"Other frameworks help you build fast. Harmony helps you build right."**

---

## 🏆 The Three Pillars

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                      THE THREE PILLARS OF HARMONY                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   🔒 GUARDIAN           🛡️ SENTINEL           ✅ HQVF                         ║
║   ─────────────        ───────────           ──────────                       ║
║   Intent Detection     Error Memory          Quality Gates                    ║
║   Agent Routing        Circuit Breaker       Use Case Verifiables             ║
║   Workflow Protection  Pattern Learning      Triple Validation                ║
║                                                                               ║
║   "Right agent,        "Never repeat         "Quality you can                 ║
║    right time"          the same bug"         prove, not assume"              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

…but Harmony is **more than three pillars**: 50+ specialized agents, domain
specialties, tech-stack profiles, multi-IDE support, security guards and JIT context
loading. 👉 **[See the full picture → docs/how-it-works.md](docs/how-it-works.md)**

---

## 🚀 Quick Start

```bash
# Install (requires jq + yq)
npx harmony-ai --full

# Start coding
/go                    # Session kickoff
/harmony               # Interactive menu (30 commands)
/harmony sentinel      # Error memory dashboard
```

**30 seconds to install. A lifetime of saved debugging time.**

📖 [Full installation guide →](docs/installation.md) · [All 30 commands →](docs/commands.md)

---

## 🤖 The Self-Improving Loop

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    🔄 THE SELF-IMPROVING LOOP                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║      ┌─────────┐         ┌─────────┐         ┌─────────┐                     ║
║      │   AI    │ ──────► │ HARMONY │ ──────► │   AI    │                     ║
║      │  Makes  │         │ Learns  │         │ Better  │                     ║
║      │ Mistake │         │ Pattern │         │  Next   │                     ║
║      └─────────┘         └─────────┘         └─────────┘                     ║
║                                                                               ║
║   💡 Feed the framework with errors → It feeds you with solutions            ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

Harmony lives in *your* project, learns *your* patterns, adapts to *your* style.
The contribution cycle, zero-context-loss across sessions (UCVs), and JIT context
loading are all detailed here 👉 **[docs/how-it-works.md](docs/how-it-works.md)**

---

## 📊 What Makes Us Different

| Feature | 🏛️ Traditional | 🛡️ Harmony |
|---------|:--------------:|:----------:|
| 🧠 Error Memory | ❌ Start fresh every time | ✅ Learns from mistakes |
| 🔄 Circuit Breaker | ❌ Repeat failures endlessly | ✅ Stops after 3 failures |
| 🎯 Intent Detection | ❌ Manual agent selection | ✅ Auto-routing |
| ✅ Quality Gates | ❌ "It works" = done | ✅ Triple validation (DEV+TEST+QA) |
| 💾 Context Persistence | ❌ Lost between sessions | ✅ 3-tier memory |
| 📈 Pattern Learning | ❌ No learning | ✅ Gets smarter over time |
| 🛡️ Security Guards | ❌ Blind trust | ✅ Supply-chain + injection filtering |

---

## 🔌 Works Everywhere

| Any IDE | Any Stack | Any Team Size |
|---------|-----------|---------------|
| Claude Code 🟢 · Cursor · Windsurf · Continue · Cody | TypeScript · Python · Go · Rust · React · Node · Django | Solo → Enterprise (500+) |

🎯 **Auto-detection**: profiles & specialties activate from your project context — and
they're **portable** (not tied to Harmony, not IDE-locked).
👉 [IDE support, profiles & specialties →](docs/how-it-works.md#-works-everywhere)

---

## 🛡️ Security Guards

Two optional hooks that screen what enters and what gets installed:

| Guard | Protects against |
|-------|------------------|
| **supply-chain-guard** | Vulnerable / typosquatted packages, unpinned MCP servers, cooling-period packages, missing lock files |
| **llm-output-sanitizer** | Prompt injection, data exfiltration, hidden Unicode, leaked secrets in **external** content |

```bash
/hf:security:guards status     # See current state
/hf:security:guards off        # Disable all (zero perf impact)
```

> ⚠️ **Defense-in-depth, not a silver bullet.** Pattern-based detection — keep it updated
> and always combine with human review. 📖 [Security Guards docs →](docs/security-guards.md)

---

## 📋 Prerequisites

| Tool | Version | Required? |
|------|---------|-----------|
| **Node.js** | v18+ | ✅ Runtime (npx) |
| **Bash** | 4.0+ | ✅ (macOS: `brew install bash`) |
| **jq** | 1.6+ | ✅ JSON processing |
| **yq** | v4+ (mikefarah) | ✅ YAML processing |
| **Bun** / **Python 3.8+** | latest / 3.8+ | ⚪ Optional (speed / Prompt Monitor) |

📖 [Detailed setup & verification →](docs/installation.md)

---

## 📚 Documentation

| 📖 Guide | Description |
|----------|-------------|
| [🚀 Getting Started](docs/getting-started.md) | 5-minute tutorial |
| [🧠 How It Works](docs/how-it-works.md) | The full picture — diagrams, flows, JIT, UCVs |
| [💡 Core Concepts](docs/concepts.md) | The three pillars explained |
| [🏗️ Architecture](docs/architecture.md) | Technical deep-dive |
| [⌨️ Commands](docs/commands.md) | All 30 commands |
| [🤖 Agents](docs/agents.md) | The agent ecosystem |
| [📈 Impact & ROI](docs/enterprise.md) | Estimated gains (from real experience) |

---

## 💬 What We Experienced Dogfooding Harmony

> *These are our own observations building Harmony with Harmony — your mileage will vary.*

- **Recurring bugs dropped sharply** once Sentinel started remembering past errors.
- **Debug time on known issues** went from ~10 min to under a minute.
- **"Works on my machine"** stopped being a thing thanks to triple validation (DEV+TEST+QA).
- **Agent confusion** disappeared with Guardian auto-routing.

📈 Detailed estimates (token savings, time/cost projections) — clearly labeled as
experience-based estimates — live in **[docs/enterprise.md](docs/enterprise.md)**.

---

## 🤝 Community

[Report bugs](https://github.com/zied-jlassi/harmony-ai-framework/issues) ·
[Ideas & help](https://github.com/zied-jlassi/harmony-ai-framework/discussions)

## 📄 License

MIT — Use it anywhere, contribute back if you can.

## 🏢 Enterprise & AI Consulting

Need production deployment with **data security as top priority**? Secure multi-env
integration, LLM cost optimization, custom agents, data-security hardening.
📬 [Details & contact →](docs/enterprise.md)

---

<div align="center">

### 🛡️ Stop repeating bugs. Start building right.

[Get Started](docs/getting-started.md) • [How it works](docs/how-it-works.md) • [Docs](docs/INDEX.md)

⭐ **Star us if Harmony saves you time!**

</div>
