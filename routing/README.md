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

## Project Type Detection (3-Phase + Monorepo)

### 3-Phase Detection

| Phase | Latency | Description |
|-------|---------|-------------|
| **1. Fast** | ~10ms | Check dependency files (package.json, composer.json, etc.) |
| **2. Confidence** | - | Score > 0.85 AND delta > 0.30? |
| **3. LLM Fallback** | ~500ms | Haiku analyzes project if ambiguous |

### Auto-Detected Flags

| Flag | How Detected | Example |
|------|--------------|---------|
| `has_ui` | react, vue, angular in package.json | `"react": "^18.0"` |
| `has_api` | @nestjs, express, fastapi | `"@nestjs/core": "*"` |
| `is_mobile` | react-native, expo, flutter | `"expo": "~52"` |
| `is_responsive` | Default true if has_ui | Viewport testing |

### Monorepo Support

Pour projets multi-modules (frontend, backend, mobile...) :

```
/project
├── package.json (workspaces: ["apps/*"])
├── /apps
│   ├── /frontend/package.json → "react" → has_ui: true
│   ├── /mobile/package.json → "expo" → is_mobile: true
│   └── /api/package.json → "@nestjs/core" → has_api: true
```

**Logique :**
1. Détection monorepo (workspaces, lerna.json, nx.json, turbo.json)
2. Scope au **dossier courant** de l'utilisateur
3. Chaque module détecté par **son propre** package.json

### Responsive & Legacy Projects

- `is_responsive: true` par défaut pour `has_ui: true`
- Si code non-responsive détecté → Warning
- Désactiver via `.harmony/local/memory/project-config.json`:
  ```json
  { "is_responsive": false }
  ```

---

## Context Conditions

| Condition | Description | Score Modifier |
|-----------|-------------|----------------|
| `has_ui` | UI/frontend (auto-detected) | +0.1-0.2 for UI agents |
| `has_api` | Backend/API (auto-detected) | neutral |
| `is_responsive` | Responsive web (default if has_ui) | Viewport testing |
| `is_mobile` | Mobile app (auto-detected) | +0.2 for mobile agents |
| `is_game` | Gaming-related context | +0.2 for gaming agents |
| `has_db_schema` | Database changes | +0.1 for architect |
| `requires_story` | Story must exist | -1.0 if no story (blocks) |
| `requires_ucv` | UCV must be approved | -1.0 if no UCV (blocks) |
| `phase_match` | Current phase matches agent | +0.2 if match |

---

## Contextual Routing (Specialties)

When a specialty context is detected, specialized agents are preferred:

### Gaming Specialty

```yaml
gaming:
  conditions: [is_game: true]
  agent_mapping:
    architect: specialties/gaming/agents/game-architect
    developer: specialties/gaming/agents/game-developer
    scrum-master: specialties/gaming/agents/game-scrum-master
```

### Mobile Specialty (JIT Context Loading)

Pour les apps mobiles, les mêmes agents sont utilisés avec un contexte enrichi :

```yaml
mobile:
  conditions: [is_mobile: true]
  agent_mapping:
    developer: specialties/mobile/agents/mobile  # Enhanced dev
    tester: tester                               # + mobile profile
    ucv-qa: ucv-qa                               # + device viewports
    exploratory-qa: exploratory-qa              # + mobile devices
```

**Viewports de test (is_mobile: true) :**

| Device | Width | Height | Platform |
|--------|-------|--------|----------|
| iPhone SE | 375 | 667 | iOS |
| iPhone 14 Pro | 393 | 852 | iOS |
| Pixel 7 | 412 | 915 | Android |
| iPad | 820 | 1180 | iOS |

**Viewports de test (is_responsive: true) :**

| Name | Width | Height |
|------|-------|--------|
| Mobile S | 320 | 568 |
| Mobile M | 375 | 667 |
| Tablet | 768 | 1024 |
| Laptop | 1024 | 768 |
| Desktop | 1440 | 900 |

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
