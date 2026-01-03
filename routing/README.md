# Routing Configuration

> **Purpose**: Agent detection, routing, orchestration, and handoff protocols
> **Version**: 1.0.0
> **Status**: Active

---

## Overview

The routing module provides centralized configuration for intelligent agent selection using a **hybrid 3-phase approach**:

1. **Rule-based Scoring** - Fast keyword/regex matching (~10ms)
2. **Confidence Evaluation** - Determine if result is confident or ambiguous
3. **LLM Classification** - Use haiku for ambiguous cases (~500ms)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROUTING DECISION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  USER MESSAGE                                                   │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────────────────────────────────┐                    │
│  │ PHASE 1: RULE-BASED SCORING (~10ms)     │                    │
│  │                                          │                    │
│  │  For each agent:                        │                    │
│  │  score = 0.5*keyword + 0.3*context      │                    │
│  │        + 0.2*regex                      │                    │
│  └────────────────────┬────────────────────┘                    │
│                       │                                          │
│                       ▼                                          │
│  ┌─────────────────────────────────────────┐                    │
│  │ PHASE 2: CONFIDENCE CHECK               │                    │
│  │                                          │                    │
│  │  top_score > 0.85 AND delta > 0.30?     │                    │
│  │    YES → Route to top agent (FAST PATH) │                    │
│  │    NO  → Continue to Phase 3            │                    │
│  └────────────────────┬────────────────────┘                    │
│                       │                                          │
│                       ▼ (Ambiguous)                              │
│  ┌─────────────────────────────────────────┐                    │
│  │ PHASE 3: LLM CLASSIFICATION (~500ms)    │                    │
│  │                                          │                    │
│  │  Haiku analyzes context + intent        │                    │
│  │                                          │                    │
│  │  confidence > 0.70? → Route to agent    │                    │
│  │  confidence < 0.70? → ASK USER          │                    │
│  └─────────────────────────────────────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Files

| File | Description |
|------|-------------|
| `detection-patterns.yaml` | Keywords, regex, context conditions with scores |
| `routing-algorithm.yaml` | Thresholds and scoring weights |
| `disambiguation-prompt.yaml` | Template for LLM classification |
| `parallel-groups.yaml` | Pipeline phase groups for concurrent execution |
| `handoff-protocol.yaml` | Structured handoff format between agents |
| `contextual-routing.yaml` | Specialty agent selection |

---

## Example: Ambiguity Resolution

**User message**: "developper une interface dashboard admin"

### Phase 1: Rule-based Scoring

| Agent | Keyword Score | Context Score | Regex Score | **Total** |
|-------|---------------|---------------|-------------|-----------|
| developer | 0.9 (developper) | 0.5 | 0.2 | **0.64** |
| ux-designer | 0.8 (interface) | 0.7 | 0.6 | **0.73** |

### Phase 2: Confidence Check

- Top score: 0.73
- Delta: 0.73 - 0.64 = 0.09
- **0.09 < 0.30** → AMBIGUOUS → Continue to Phase 3

### Phase 3: LLM Classification

Haiku analyzes: "developper" in technical context typically means "code"
- Result: `developer`
- Confidence: 0.85
- **0.85 > 0.70** → Route to Developer

---

## Scoring Formula

```
score(agent) =
  KEYWORD_WEIGHT * max(keyword_scores) +
  CONTEXT_WEIGHT * context_score +
  REGEX_WEIGHT * max(regex_scores)

Default weights:
  KEYWORD_WEIGHT = 0.50
  CONTEXT_WEIGHT = 0.30
  REGEX_WEIGHT   = 0.20
```

---

## Context Conditions

Context conditions modify agent scores based on project state:

| Condition | Description | Score Modifier |
|-----------|-------------|----------------|
| `is_game` | Gaming-related context | +0.2 for gaming agents |
| `is_admin` | Admin dashboard context | neutral |
| `has_ui` | UI/frontend work | +0.1 for ux-designer |
| `has_db_schema` | Database changes | +0.1 for architect |
| `requires_story` | Story must exist | -1.0 if no story (blocks) |
| `requires_ucv` | UCV must be approved | -1.0 if no UCV (blocks) |
| `phase_match` | Current phase matches agent | +0.2 if match |

---

## Contextual Routing (Specialties)

When a specialty context is detected, specialized agents are preferred:

```yaml
gaming:
  conditions: [is_game: true]
  agent_mapping:
    architect: specialties/gaming/agents/game-architect
    developer: specialties/gaming/agents/game-developer
    scrum-master: specialties/gaming/agents/game-scrum-master
```

---

## Integration with Guardian

The Guardian agent orchestrates this routing:

1. Receives user message
2. Loads `detection-patterns.yaml`
3. Calculates scores per `routing-algorithm.yaml`
4. If ambiguous, calls haiku with `disambiguation-prompt.yaml`
5. Routes to selected agent or asks user

---

## Performance

| Scenario | Latency | Frequency |
|----------|---------|-----------|
| Clear intent (Phase 1+2) | ~10ms | ~80% |
| Ambiguous (Phase 3) | ~500ms | ~15% |
| User clarification | Variable | ~5% |

---

## Agent Commands

### Phase 3: Solutioning

```bash
# Story creation
/scrum-master create-story EPIC-XXX

# UCV generation
/ucv-writer STORY-XXX
```

### Phase 4: Implementation

```bash
# Implementation
/developer STORY-XXX

# Automated testing
/tester STORY-XXX

# UCV QA validation (manual browser testing)
/ucv-qa STORY-XXX
/ucv-qa STORY-XXX --uc UC-002    # Specific use case only
/ucv-qa STORY-XXX --verbose      # With all screenshots
/ucv-qa STORY-XXX --dry-run      # Preview only

# Exploratory QA (MANDATORY before closure)
/exploratory-qa [module]
/exploratory-qa --smoke          # Quick smoke test
/exploratory-qa --session 90     # Timed session

# Final verification
/ucv-validator STORY-XXX
/ucv-validator STORY-XXX --strict  # Fail on any gap
```

### Compliance Agents

```bash
# Accessibility audit
/accessibility [module]
/accessibility --wcag AA         # WCAG 2.1 AA level
/accessibility --rgaa            # RGAA (French standard)
/accessibility --full            # Complete audit

# Security audit
/security [module]
/security --owasp                # OWASP Top 10 check

# GDPR/RGPD compliance
/rgpd [module]
/rgpd --audit                    # Full privacy audit
```

---

## Agent Invocation Context

### When to Invoke Each Agent

| Agent | Trigger | Prerequisites | Output |
|-------|---------|---------------|--------|
| **ucv-qa** | After [dev] and [test] complete | Story + UCV approved | [qa] checkmarks |
| **exploratory-qa** | After ucv-qa complete | All [qa] marked | Go/No-Go |
| **accessibility** | When UI changes | Has frontend | A11y report |
| **security** | Before release | Endpoints exposed | Security report |
| **rgpd** | When handling PII | Personal data | Compliance report |

### Invocation Order (Story Lifecycle)

```
1. scrum-master   → Creates story
2. ucv-writer     → Creates UCVs
3. [USER GATE]    → Approves UCVs
4. developer      → Implements [dev]
5. tester         → Tests [test]
6. ucv-qa         → Validates [qa] in browser
7. exploratory-qa → Free exploration (MANDATORY)
8. ucv-validator  → Confirms 100%
9. scrum-master   → Closes story
```

---

## Related

- [Guardian Agent](../agents/guardian.md) - Intent detection
- [Supervisor Agent](../agents/supervisor.md) - Multi-agent coordination
- [Rules](../rules/) - Enforcement rules
- [Workflows](../workflows/) - Pipeline phases
- [Specialties](../specialties/) - Domain-specific agents
