# P-006: Intent Detection & Routing

> **Analyze natural language to detect intent and route to appropriate agent.**

---

## Classification

| Property | Value |
|----------|-------|
| **Pattern ID** | P-006 |
| **Category** | Orchestration |
| **Complexity** | Medium |
| **Applicability** | Multi-agent systems |

---

## Problem

Users speak naturally, not in commands:
- "Fix the login bug" vs "/agent:developer fix-bug auth"
- Need to understand intent, not parse commands
- Wrong agent selection wastes time

---

## Solution

Natural language intent detection with keyword mapping and context awareness:

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTENT DETECTION FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT: "développe le système de scoring pour le jeu"          │
│                                                                  │
│  STEP 1: LANGUAGE DETECTION                                     │
│          └── French detected                                    │
│                                                                  │
│  STEP 2: KEYWORD EXTRACTION                                     │
│          ├── "développe" → Intent keyword                       │
│          ├── "système" → System/Feature                         │
│          ├── "scoring" → Domain: Gaming                         │
│          └── "jeu" → Context: Game                              │
│                                                                  │
│  STEP 3: INTENT CLASSIFICATION                                  │
│          ├── Primary: IMPLEMENT                                 │
│          ├── Confidence: 95%                                    │
│          └── Domain: Gaming                                     │
│                                                                  │
│  STEP 4: AGENT SELECTION                                        │
│          └── Route to: Developer (Developer)                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Intent Types

| Intent | Description | Target Agent |
|--------|-------------|--------------|
| **IMPLEMENT** | Build new feature | Developer |
| **FIX** | Repair bug | Developer |
| **TEST** | Write/run tests | Tester |
| **ANALYZE** | Requirements analysis | Analyst |
| **DESIGN** | Architecture design | Architect |
| **PLAN_STORY** | Create stories | SM |
| **CREATE_UCV** | Generate UCVs | UCV Writer |
| **VALIDATE_UCV** | Check coverage | UCV Validator |
| **EXPLORE_QA** | Exploratory testing | Exploratory QA |
| **SECURITY** | Security audit | Security |
| **COMPLIANCE** | Privacy/legal | RGPD |
| **ACCESSIBILITY** | A11y audit | Accessibility |

---

## Keyword Mapping

### English Keywords

```typescript
const INTENT_KEYWORDS = {
  IMPLEMENT: ['develop', 'implement', 'code', 'build', 'create', 'add'],
  FIX: ['fix', 'bug', 'error', 'debug', 'repair', 'patch'],
  TEST: ['test', 'TDD', 'coverage', 'unit', 'integration'],
  ANALYZE: ['analyze', 'requirement', 'need', 'understand'],
  DESIGN: ['architecture', 'design', 'ADR', 'pattern'],
  PLAN_STORY: ['story', 'sprint', 'backlog', 'plan'],
  CREATE_UCV: ['UCV', 'use case', 'verification'],
  VALIDATE_UCV: ['validate', 'verify', 'coverage', 'check'],
  EXPLORE_QA: ['explore', 'QA', 'UX', 'smoke', 'Exploratory QA'],
};
```

### French Keywords

```typescript
const INTENT_KEYWORDS_FR = {
  IMPLEMENT: ['développe', 'implémente', 'code', 'construit', 'crée'],
  FIX: ['corrige', 'bug', 'erreur', 'répare', 'patch'],
  TEST: ['teste', 'TDD', 'couverture', 'test unitaire'],
  ANALYZE: ['analyse', 'besoin', 'comprend'],
  DESIGN: ['architecture', 'conception', 'ADR'],
  PLAN_STORY: ['story', 'sprint', 'backlog', 'planifie'],
  CREATE_UCV: ['UCV', 'cas d\'usage', 'vérification'],
  VALIDATE_UCV: ['valide', 'vérifie', 'couverture'],
  EXPLORE_QA: ['explore', 'QA', 'test exploratoire'],
};
```

---

## Implementation

```typescript
interface IntentResult {
  intent: string;
  confidence: number;
  language: string;
  keywords: string[];
  domain?: string;
}

function detectIntent(message: string): IntentResult {
  // Step 1: Detect language
  const language = detectLanguage(message);
  const keywords = language === 'fr' ? INTENT_KEYWORDS_FR : INTENT_KEYWORDS;

  // Step 2: Extract keywords
  const words = message.toLowerCase().split(/\s+/);
  const matches: Record<string, number> = {};

  for (const [intent, intentKeywords] of Object.entries(keywords)) {
    matches[intent] = words.filter(w =>
      intentKeywords.some(k => w.includes(k))
    ).length;
  }

  // Step 3: Find best match
  const [bestIntent, score] = Object.entries(matches)
    .sort((a, b) => b[1] - a[1])[0];

  // Step 4: Calculate confidence
  const confidence = score > 0 ? Math.min(score * 30, 100) : 0;

  return {
    intent: bestIntent,
    confidence,
    language,
    keywords: extractKeywords(message),
    domain: detectDomain(message)
  };
}

function routeToAgent(intent: string): Agent {
  const routing: Record<string, Agent> = {
    IMPLEMENT: agents.developer,
    FIX: agents.developer,
    TEST: agents.tester,
    ANALYZE: agents.analyst,
    DESIGN: agents.architect,
    PLAN_STORY: agents.sm,
    CREATE_UCV: agents.ucv_writer,
    VALIDATE_UCV: agents.ucv_validator,
    EXPLORE_QA: agents.exploratory_qa,
    SECURITY: agents.security,
    COMPLIANCE: agents.rgpd,
    ACCESSIBILITY: agents.accessibility,
  };

  return routing[intent] || agents.guardian;
}
```

---

## Prerequisite Checking

After intent detection, check prerequisites:

```typescript
interface Prerequisites {
  IMPLEMENT: {
    story_exists: true,
    ucv_approved: true,
    phase: [4]
  },
  FIX: {
    story_exists: true  // Or create hotfix story
  },
  DESIGN: {
    phase: [2, 3],
    prd_exists: true
  }
}

function checkPrerequisites(intent: string): PrerequisiteResult {
  const reqs = Prerequisites[intent];
  const violations: string[] = [];

  if (reqs.story_exists && !hasActiveStory()) {
    violations.push('No active story');
  }

  if (reqs.ucv_approved && !isUCVApproved()) {
    violations.push('UCV not approved');
  }

  if (reqs.phase && !reqs.phase.includes(currentPhase)) {
    violations.push(`Wrong phase (current: ${currentPhase})`);
  }

  return {
    passed: violations.length === 0,
    violations
  };
}
```

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Natural interaction** | Users speak naturally |
| **Multilingual** | Works in any language |
| **Context-aware** | Considers domain and phase |
| **Prerequisite enforcement** | Catches missing requirements |

---

## Related Patterns

- [P-001: Hybrid Orchestration](P-001-hybrid-orchestration.md)
- [P-007: Story-Based Development](P-007-story-based.md)

