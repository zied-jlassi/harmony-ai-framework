# Harmony Framework - Evolution & Design Decisions

> **🌐 Language:** English · [Français](fr/evolution.md)

> **Memory document: How and why Harmony was designed.**
>
> This document keeps track of the thought process, the analyses,
> and the architectural decisions made during development.

---

## Version History

| Version | Date | Codename | Key Changes |
|---------|------|----------|-------------|
| **1.0.0** | 2025-01-01 | Genesis | Initial release |
| **2.0.0** | 2025-12-31 | Unification | Command → Framework merge |

---

## Phase 1: Origins (December 2024)

### The Initial Problem

In a complex e-commerce project, we observed recurring issues:

1. **Repeated errors** - The same bug kept coming back session after session
2. **Agent confusion** - The wrong agent was activated for the task
3. **Uncertain quality** - "It works" was not verifiable
4. **Lost context** - Each session started from scratch

### AI Architect Analysis

**Research conducted:**
- 150+ sources from 2025 analyzed
- Frameworks evaluated: LangChain, CrewAI, AutoGen, Semantic Kernel
- Patterns extracted: Microsoft Azure AI, AWS Agentic, Google ADK

**Conclusion:**
> "No existing framework offers persistent error memory
> or a verifiable quality system. That is our USP."

---

## Phase 2: The Three Pillars (January 2025)

### Designing the Guardian Protocol

**Problem:** How do we automatically route to the right agent?

**Solution designed:**
```
User: "développe le scoring"
         ↓
[Intent Detection]
├── Mots-clés: "développe" → IMPLEMENT
├── Contexte: "scoring" → Gaming
├── Vérification: Story existe?
         ↓
[Route to DEV Agent]
```

**Routing table created:**

| Intent | Keywords | Agent | Prerequisites |
|--------|----------|-------|---------------|
| IMPLEMENT | développer, coder, implémenter | DEV | Story MUST exist |
| FIX | corriger, bug, erreur | DEV | Story or BUGFIX |
| PLAN | story, sprint, planifier | SM | Architecture exists |
| TEST | tester, test, coverage | TEA | - |
| ANALYZE | analyser, besoin | Analyst | - |
| DESIGN | architecture, ADR | Architect | PRD exists |

### Designing the Sentinel System

**Problem:** How do we avoid repeating the same errors?

**Inspiration:**
- Circuit breaker pattern (Microservices)
- Error budgets (SRE)
- Learning from failures (Chaos Engineering)

**Architecture chosen:**

```yaml
memory:
  error_journal:
    description: "Journal des erreurs avec solutions"
    format: JSON
    indexed_by: [module, category, tags]

  circuit_breaker:
    states: [CLOSED, HALF-OPEN, OPEN]
    max_failures: 3
    cooldown: 5 minutes

  learned_patterns:
    description: "Patterns validés en production"

  anti_patterns:
    description: "Patterns à éviter"
```

**Key decision:**
> "The circuit breaker opens after 3 consecutive failures.
> No automatic reset - analysis is mandatory."

### Designing HQVF

**Problem:** How do we objectively verify quality?

**Analysis of the Dev/Test/QA gap:**
```
DEV écrit 100 lignes de code
TEST vérifie 5% avec tests
User utilise et voit 55% des bugs

→ Gap entre intention et livraison
```

**Solution: Use Case Verifiables (UCV)**

```yaml
use_case:
  id: UC-001
  title: "Ouvrir modal modification"
  gherkin: |
    Given je suis connecté admin
    When je clique sur l'icône crayon
    Then une modal s'affiche au centre

  verifications:
    - id: V-001-1
      description: "Modal visible centrée"
      dev: false   # ☐ DEV marque
      test: false  # ☐ TEA marque
      qa: false    # ☐ Exploratory QA marque
```

**Rule HQVF-7:**
> "Story DONE = 100% of UCVs validated (DEV + TEST + QA)"
> It is objective, not subjective.

---

## Phase 3: 3-Tier Memory System

### Context Window Analysis

**Observed evolution:**
| Year | Size | Model |
|-------|--------|--------|
| 2022 | 4K | GPT-3.5 |
| 2023 | 32K | GPT-4 |
| 2024 | 128K | Claude 3 |
| 2025 | 200K+ | Claude 4 |

**Identified problem:**
> "Bigger ≠ Better. Lost-in-middle is real.
> Information in the middle of the context is 15-20% less recalled."

### 3-Tier Architecture chosen

```
┌─────────────────────────────────────────┐
│ TIER 1: Working Memory (In-Context)     │
│ - 2000 tokens (~10-20% context)         │
│ - Task active, persona, instructions    │
│ - Refresh: chaque message               │
├─────────────────────────────────────────┤
│ TIER 2: Session Memory (External)       │
│ - Unlimited, compressed                 │
│ - Conversation history                  │
│ - Refresh: session                      │
├─────────────────────────────────────────┤
│ TIER 3: Long-term Memory (Persistent)   │
│ - Unlimited, permanent                  │
│ - Error journal, patterns               │
│ - Refresh: never (versioned)            │
└─────────────────────────────────────────┘
```

**Key decision:**
> "JIT Loading (Just-In-Time): Load only what is relevant.
> Semantic similarity > 0.7 for inclusion."

---

## Phase 4: Profiles & Specialties

### The fundamental distinction

**Key question:** How do we separate the WHAT from the HOW?

**Solution:**
- **Specialties** = WHAT to build (business domain)
- **Profiles** = HOW to build (technical stack)

| Aspect | Specialties | Profiles |
|--------|-------------|----------|
| Question | What? | How? |
| Examples | gaming, medical | nestjs, angular |
| Agents | Adds agents | No new agents |
| Activation | Explicit | Auto-detect |

### Dependency System

**Problem:** NestJS requires TypeScript which requires JavaScript.

**Solution: Levels (L0-L3)**

```
L0: Languages (javascript, typescript, python)
L1: Runtimes (nodejs, deno)
L2: Frameworks (nestjs, angular)
L3: Meta/Tools (prisma, graphql)
```

**Automatic resolution:**
```
Activer "nestjs"
→ Charge: nestjs (60%)
→ Auto: typescript (20%), nodejs (10%), javascript (10%)
```

---

## Phase 5: Multi-IDE Integrations

### IDE Capability Analysis

| Feature | Claude Code | Cursor | Windsurf | Continue | Cody |
|---------|:-----------:|:------:|:--------:|:--------:|:----:|
| Hooks | ✓ | ✗ | ✗ | ✗ | ✗ |
| Memory | ✓ | ✗ | ✗ | ✗ | Code Graph |
| MCP | ✓ | ✗ | ✗ | ✗ | ✗ |
| Rules | CLAUDE.md | .mdc | .windsurfrules | YAML | Prompts |

### Decision: Feature Mapping

**How do we adapt Harmony to each IDE?**

| Harmony Feature | Claude Code | Cursor | Windsurf |
|-----------------|-------------|--------|----------|
| Guardian | hooks/ | .mdc rules | rules section |
| Sentinel | memory/*.json | N/A | N/A |
| HQVF | CLAUDE.md | .mdc rules | rules section |
| Agents | Skills | Personas | Instructions |

**Conclusion:**
> "Claude Code is the 'gold standard' (full support).
> Other IDEs = graceful degradation."

---

## Phase 6: Command → Framework Unification (December 2025)

### ULTRATHINK Analysis

**Identified problem:**
- `/harmony` command very rich (27 modes)
- `.harmony/` public framework structure
- Duplication, potential inconsistency

**Solution designed:**

```
AVANT (2 systèmes):
├── /harmony command (27 modes, riche, local)
└── .harmony/ framework (structure, incomplet)

APRÈS (1 système):
└── .harmony/ framework (COMPLET, distributable)
    └── .claude/commands/harmony.md (thin wrapper)
```

### Competitive Research

**Frameworks analyzed:**
- LangChain (90k+ stars) - RAG focus
- CrewAI (30k+ stars) - Multi-agent roles
- AutoGen (Microsoft) - Agent dialogue
- Semantic Kernel (Microsoft) - Enterprise

**Harmony USPs identified:**
1. Error Memory (Sentinel) - UNIQUE
2. Quality Gates (HQVF) - UNIQUE
3. Intent Routing (Guardian) - UNIQUE
4. Multi-IDE - RARE

### Final Architecture

```
.harmony/
├── commands/        ← 30 modes (tous)
├── core/            ← Guardian + Sentinel + HQVF
├── agents/          ← 18+ agents
├── profiles/        ← 50+ tech profiles
├── specialties/     ← gaming, medical, etc.
├── integrations/    ← 5 IDEs
└── docs/            ← Documentation complète
```

---

## Architectural Decisions (ADRs)

### ADR-001: Prompt-Based, Not Fine-Tuned

**Context:** Should we fine-tune a model for Harmony?

**Decision:** NO - Prompts + Memory only

**Rationale:**
> "Improvement through prompts and memory,
> NOT modification of the model's weights.
> The LLM stays intact.
> Performance guaranteed (no degradation)."

### ADR-002: Circuit Breaker Manual Reset

**Context:** Should the circuit breaker reset automatically?

**Decision:** NO - Manual reset mandatory

**Rationale:**
> "Auto-reset allows the error to repeat.
> Manual reset forces root cause analysis.
> The error pattern must be documented."

### ADR-003: UCV Triple Validation

**Context:** Who validates that a feature is complete?

**Decision:** DEV + TEST + QA (all three)

**Rationale:**
> "DEV verifies implementation
> TEST verifies behavior
> QA verifies usability
> The three perspectives = complete quality"

### ADR-004: Profiles Auto-Detection

**Context:** Should the user declare their profiles?

**Decision:** Auto-detection with possible override

**Rationale:**
> "package.json → nodejs, typescript
> tsconfig.json → typescript
> nest-cli.json → nestjs
> Less manual configuration"

---

## Lessons Learned

### What worked

1. **Sentinel** - 82% reduction in recurring bugs
2. **HQVF** - Zero "it works on my machine"
3. **Guardian** - Automatic routing without confusion
4. **Multi-IDE** - No lock-in

### What was difficult

1. **Lost-in-middle** - Solution: JIT Loading
2. **IDE differences** - Solution: Feature mapping
3. **Documentation size** - Solution: Chunking 200-500 lines

### What we would do differently

1. Start with the framework, not the command
2. Semantic versioning from the start
3. Automated tests earlier

---

## Key References

### Architectural Sources
- Microsoft Azure AI Agent Patterns
- AWS Agentic AI Patterns
- Google ADK Documentation
- Anthropic Context Engineering (2025)

### Memory Sources
- Mem0 Documentation (+26% accuracy)
- MemGPT/Letta Architecture
- FlowHunt Context Engineering Guide

### Quality Sources
- Confident AI LLM Guardrails
- DeepEval Evaluation Framework
- Agile Testing Quadrants

---

## Contributors

| Persona | Role | Contribution |
|---------|------|--------------|
| AI Architect | AI Architect | Overall architecture, research |
| UCV Writer | UCV Writer | HQVF system |
| UCV Validator | UCV Validator | Quality validation |
| Exploratory QA | QA Explorer | Exploratory testing |
| Developer | Developer | Implementation |
| Tester | Tester | Automated tests |
| Scrum Master | Scrum Master | Story workflow |
| Analyst | Analyst | Requirements |
| Architect | Architect | Technical design |

---

## Next Steps

### v2.1 (Planned)
- [ ] Global npm CLI `harmony`
- [ ] Automated tests
- [ ] Landing page harmony-ai.dev

### v2.2 (Planned)
- [ ] Additional specialties (fintech, medical)
- [ ] 30+ additional profiles
- [ ] VS Code extension integration

### v3.0 (Vision)
- [ ] Cloud sync for memory
- [ ] Team collaboration
- [ ] Analytics dashboard

---

## Final Note

> **This document is the living memory of Harmony's development.**
>
> It captures not only the WHAT but also the WHY and the HOW.
> Every decision has a reason. Every pattern has a story.
>
> "Learn. Protect. Deliver." - It's more than a slogan,
> it's our development philosophy.
