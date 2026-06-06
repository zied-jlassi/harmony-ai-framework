# AGENTS.md - Harmony Framework

> **Compatible with**: OpenAI Codex, Cursor, GitHub Copilot, JetBrains AI, Continue
> **Version**: 1.0.0

---

## Framework Overview

This project uses **Harmony AI Framework** - a self-improving development framework with three pillars:

| Pillar | Purpose |
|--------|---------|
| **Guardian** | Intent detection, agent routing, workflow protection |
| **Sentinel** | Error memory, circuit breaker (3 failures = stop) |
| **HQVF** | Use Case Verifiables, triple validation |

**Configuration**: `HARMONY_DIR=.harmony`

---

## Agent Behavior Rules

### 1. Agent Announcement (MANDATORY)

Before starting ANY task, announce which agent role you're assuming:

```
● {emoji} {Agent} Agent : {greeting}
```

Examples:
- `● 📊 Analyst Agent : Je suis l'Analyst, expert en exigences...`
- `● 🏗️ Architect Agent : Je suis l'Architect, expert en conception...`
- `● 💻 Developer Agent : Je suis le Developer, expert en implémentation...`

### 2. Intent-Based Routing

| Keywords | Intent | Agent Role |
|----------|--------|------------|
| develop, implement, code, build | IMPLEMENT | Developer |
| fix, bug, error, debug | FIX | Developer |
| test, TDD, coverage | TEST | Tester |
| analyze, requirement, research | ANALYZE | Analyst |
| architecture, design, ADR, pattern | DESIGN | Architect |
| story, sprint, backlog | PLAN_STORY | Scrum Master |
| security, audit, vulnerability | SECURITY | Security |

### 3. Handoff Protocol

When changing agent roles:

```
📤 HANDOFF: {From} → {To}
Context: {Brief summary}
Next: {What to do}

● {New agent announcement}
```

---

## Security Boundaries

### ALLOWED
- `.harmony/` - Framework files
- `.claude/` - Claude config
- Project source code

### FORBIDDEN
- Parent directories (`../`)
- Home directory (`~`)
- Absolute system paths (`/`)
- Creating `docs/` at project root (use `.harmony/local/docs/`)

---

## File Structure

```
.harmony/
├── INSTRUCTIONS.md      # Full protocol details
├── memory/              # State management
│   ├── working.json
│   ├── circuit-breaker.json
│   └── error-journal.json
├── local/
│   ├── backlog/         # Stories, epics
│   └── docs/            # Project documentation
└── docs/                # Framework docs (read-only)
```

---

## Quality Gates

1. **Story Required**: Create story before implementing features
2. **UCV Validation**: Use Case Verifiables for acceptance criteria
3. **Circuit Breaker**: Max 10 failures per story, then escalate

---

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/go` | Start session |
| `/harmony` | Show all commands |
| `/harmony status` | Current state |
| `/harmony quick` | Quick validation |

---

## More Information

See `.harmony/INSTRUCTIONS.md` for complete protocol details.
See `.harmony/docs/` for full documentation.
