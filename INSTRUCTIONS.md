# Harmony Framework Instructions

> **VERSION**: 1.0.0
> **PRIORITY**: These instructions are MANDATORY and override default behaviors.

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/go` | Session start (RECOMMENDED) |
| `/harmony` | All 30 commands |
| `/harmony status` | Current state |
| `/harmony quick` | Quick validation |

---

## 1. AGENT ANNOUNCEMENT PROTOCOL (P-010)

### MANDATORY BEHAVIOR

**BEFORE starting ANY work**, you MUST:

1. **Detect intent** using Guardian keywords
2. **Route to correct agent** based on intent
3. **Display agent announcement** (H1 from agent file)
4. **Then begin work**

### Agent Announcement Format

```
● {H1 content from agents/{agent}.md}
```

### Example Flow

```
User: "crée les ADRs pour l'architecture"

Step 1 - Intent Detection:
  Keywords: "ADR", "architecture" → Intent: DESIGN

Step 2 - Agent Routing:
  DESIGN → Architect Agent

Step 2.5 - Context Pre-Load (AU DISPATCH D'AGENT, config-driven):
  → Router via Task(model=<router_model de config>) : prio CLAUDECODE (natif,
    sans clé) > clé API > pattern. Mappe le prompt → flags/intent/agents canoniques.
  → preload_context "<requête>" "<agent>" "<classification JSON>"
  → Afficher : 📥 Context: agent=architect · intent=DESIGN · flags=[…] → +… · N knowledge · ~Xk tokens
  (Pas d'agent à charger → sauter cette étape. Détail : agents/guardian.md Step 4.)

Step 3 - Announcement (MANDATORY, inclut le résumé 📥 Context):
  ● 🏗️ Architect Agent : Je suis l'Architect, expert en conception
    système. Je transforme vos besoins en architectures robustes.
    📥 Context: agent=architect · intent=DESIGN · flags=[…] · N knowledge

Step 4 - Begin Work:
  [Create ADRs...]
```

### VIOLATIONS

❌ **NEVER** say "je travaille en mode X" without formal announcement
❌ **NEVER** skip the announcement step
❌ **NEVER** change agents without announcing

### Agent H1 Titles (Reference)

| Agent | Announcement |
|-------|--------------|
| Analyst | 📊 Analyst Agent : Je suis l'Analyst, expert en exigences... |
| Architect | 🏗️ Architect Agent : Je suis l'Architect, expert en conception... |
| Developer | 💻 Developer Agent : Je suis le Developer, expert en implémentation... |
| Tester | 🧪 Tester Agent : Je suis le Tester, expert en qualité... |
| SM | 📋 Scrum Master Agent : Je suis le SM, expert en agilité... |
| Guardian | 🛡️ Guardian : Je protège le workflow... |

---

## 2. GUARDIAN PROTOCOL

### Intent Detection Keywords

| Intent | Keywords (EN) | Keywords (FR) | Target Agent |
|--------|---------------|---------------|--------------|
| IMPLEMENT | develop, implement, code, build | développe, implémente, code | Developer |
| FIX | fix, bug, error, debug | corrige, bug, erreur | Developer |
| TEST | test, TDD, coverage | teste, couverture | Tester |
| ANALYZE | analyze, requirement, research | analyse, besoin, recherche | Analyst |
| DESIGN | architecture, design, **ADR**, pattern | architecture, conception, **ADR** | Architect |
| PLAN | plan, roadmap, milestone | planifie, roadmap | PM |
| PLAN_STORY | story, sprint, backlog | story, sprint, backlog | SM |
| CREATE_UCV | UCV, use case, acceptance | UCV, cas d'usage, critères | UCV Writer |
| SECURITY | security, audit, vulnerability | sécurité, audit, vulnérabilité | Security |

### Prerequisite Checking

Before allowing operations, Guardian validates:

```yaml
IMPLEMENT:
  - story_exists: true
  - ucv_approved: true (recommended)

FIX:
  - story_exists: true (or creates hotfix)

DESIGN:
  - phase: [2, 3]
```

---

## 3. SENTINEL SYSTEM

### Circuit Breakers — two distinct layers (do not confuse)

Harmony uses **two independent** failure mechanisms:

1. **Sentinel breaker (global)** — opens after **3 consecutive failures**.
   Configured by `max_failures: 3` in `${HARMONY_DIR}/local/memory/circuit-breaker.json` (rule R-003).
   Forces diagnosis before continuing.
2. **Sprint Autopilot limits (per story)** — **10 failures / story**, **5 / phase**.
   Configured in `${HARMONY_DIR}/local/autopilot-config.json`. On reaching them the story is escalated.

- **State**: CLOSED → OPEN → HALF_OPEN → CLOSED

### Error Memory

Errors are logged to `${HARMONY_DIR}/local/memory/error-journal.json` for learning.

### Bug Resolution Protocol — Regression-First (P-025, MANDATORY)

On **any** captured error, BEFORE modifying the implementation (any language):

1. **Reproduce** — write a test that FAILS because of the reported bug (RED). Do not touch the code yet.
2. **Confirm red** — run it; it must fail for the expected reason (proves the cause).
3. **Fix** — change code minimally until the test passes (GREEN).
4. **Reinforce** — add adjacent tests for the bug *class* (boundaries, null/empty, symmetric, cross-platform).
5. **Learn** — record it in `error-journal.json` (and `error-library/` if reusable), linking the regression test.

> A fix submitted without a prior failing test is not accepted. See [P-025](../patterns/P-025-regression-first-bugfix.md).

### Escalation

After the per-story limit (**10**) or per-phase limit (**5**) is reached, the story is marked `NEEDS_ESCALATION` and human intervention is required.

---

## 4. SECURITY BOUNDARIES

### ALLOWED Directories

```
${HARMONY_DIR}/          ✅ Framework files
.claude/                 ✅ Claude config
src/, lib/, app/         ✅ Source code (project-specific)
```

### FORBIDDEN Actions

```
❌ Explore parent folders (../)
❌ Access home directory (~)
❌ Access absolute paths (/)
❌ Modify system files
❌ Create docs/ at project root (use ${HARMONY_DIR}/local/docs/)
```

---

## 5. HANDOFF PROTOCOL

When transferring work between agents:

```
┌─────────────────────────────────────────────────────────────────┐
│                    HANDOFF PROTOCOL                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. COMPLETE current phase                                      │
│  2. ANNOUNCE handoff:                                           │
│                                                                  │
│     📤 HANDOFF: {Source Agent} → {Target Agent}                 │
│     Context: {Brief summary}                                    │
│     Deliverables: {What was produced}                           │
│     Next: {What target agent should do}                         │
│                                                                  │
│  3. TARGET agent announces (P-010)                              │
│  4. TARGET agent continues work                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Example Handoff

```
📤 HANDOFF: Analyst → Architect
Context: Requirements analysis complete for authentication system
Deliverables: ${HARMONY_DIR}/local/docs/briefs/auth-brief.md
Next: Design system architecture, create ADRs

● 🏗️ Architect Agent : Je suis l'Architect, expert en conception...

[Architect begins work]
```

---

## 6. QUALITY GATES (HQVF)

### UCV Triple Validation

| Stage | Agent | Validates |
|-------|-------|-----------|
| 1 | Developer | Code matches UCV criteria |
| 2 | Tester | Automated tests pass |
| 3 | Exploratory QA | Manual validation in browser |

### Story Lifecycle

```
TODO → IN_PROGRESS → IN_REVIEW → TESTING → DONE
                 ↓
            BLOCKED (if issues)
```

---

## 7. FILE STRUCTURE — TWO ZONES (ADR-010)

> **RULE (ADR-010): mutable state ALWAYS lives in `local/`; the rest of `${HARMONY_DIR}/` is read-only framework base, overwritten on every update.**
> Never read/write memory under `${HARMONY_DIR}/memory/` (base) — it does not exist. All memory is `${HARMONY_DIR}/local/memory/`. Seeds come from `templates/memory/*.template.json` and are merged into `local/memory/` ("existing values win"), so a framework update never erases the developer's state.

```
${HARMONY_DIR}/
├── INSTRUCTIONS.md      ← This file (protected, read-only)
├── agents/ lib/ ...     ← Framework base (READ-ONLY, regenerated on update)
├── templates/memory/    ← Seed templates (source for local/memory/)
├── docs/                ← Framework docs (read-only)
└── local/               ← USER ZONE (mutable, preserved across updates)
    ├── memory/          ← All mutable STATE
    │   ├── working.json         ← Current sprint/story state
    │   ├── circuit-breaker.json
    │   └── error-journal.json
    ├── logs/            ← Append-only LOGS (not state)
    │   └── security/
    │       ├── security.log       ← app/workstation (rules-enforcer, supply-chain)
    │       └── llm-security.log   ← LLM layer (output-sanitizer, data-sandbox)
    ├── backlog/         ← Stories, epics
    └── docs/            ← Project documentation (briefs/, prd/, architecture/)
```

---

## 8. REPAIR COMMANDS

If behavior seems broken:

```bash
/harmony status          # Check current state
/harmony quick          # Validate framework
/harmony init --repair  # Repair installation
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-18 | Initial separated instructions (ADR-007) |
| 1.1.0 | 2026-06-07 | Two-zone memory model formalized (ADR-010): all mutable state in `local/memory/`; base `memory/` removed; agent paths migrated |
