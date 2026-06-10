# Profile Loader - Architecture

> **🌐 Language:** English · [Français](../fr/architecture/PROFILE-LOADER.md)

**Version:** 1.0.0
**Status:** Implemented
**Date:** 2026-01-04

---

## Overview

The Profile Loader is a component that loads technical profile sections conditionally, based on the intent detected by Guardian.

```
┌─────────────────────────────────────────────────────────────────┐
│                    PROFILE LOADER                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  INPUT:                                                          │
│  ├── current_intent (from workflow-state.json)                  │
│  ├── current_profile (detected from project)                    │
│  └── user_message (for keyword matching)                        │
│                                                                  │
│  OUTPUT:                                                         │
│  ├── Selected sections to load                                  │
│  ├── Concatenated knowledge content                             │
│  └── Token count estimate                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Integration with Guardian

### Full Flow

```
User Message
     │
     ▼
┌─────────────┐
│  GUARDIAN   │ ─────────────────────────────────────────┐
│             │                                          │
│ 1. Detect   │                                          │
│    intent   │                                          │
│             │                                          │
│ 2. Score    │                                          │
│    agents   │                                          │
│             │                                          │
│ 3. Store    │──→ workflow-state.json                   │
│    intent   │    { "current_intent": "TEST" }          │
│             │                                          │
│ 4. Route    │                                          │
└─────────────┘                                          │
     │                                                   │
     ▼                                                   │
┌─────────────┐                                          │
│   AGENT     │                                          │
│  (loaded)   │                                          │
└─────────────┘                                          │
     │                                                   │
     ▼                                                   │
┌─────────────┐      ┌──────────────────┐               │
│  PROFILE    │◀─────│ workflow-state   │◀──────────────┘
│   LOADER    │      │ (read intent)    │
│             │      └──────────────────┘
│ 5. Read     │
│    intent   │
│             │
│ 6. Read     │──→ profiles/{category}/{name}/manifest.yaml
│    manifest │
│             │
│ 7. Select   │──→ Sections based on intent + keywords
│    sections │
│             │
│ 8. Load     │──→ knowledge/{section}/*.md
│    files    │
│             │
│ 9. Return   │──→ Concatenated content + token estimate
│    content  │
└─────────────┘
```

### No Conflict with Routing

| Aspect | Guardian | Profile Loader |
|--------|----------|----------------|
| **When** | First | After agent selection |
| **Intent** | Detected | Reused (read-only) |
| **Output** | Routed agent | Knowledge sections |
| **State** | Writes | Reads + adds sections_loaded |

---

## Section Types

### 1. Core (Always Loaded)

```yaml
core:
  load: always
  description: "Concepts essentiels, toujours necessaires"
  example: modules, controllers, providers
```

### 2. On-Intent (Intent-Based)

```yaml
testing:
  load: on_intent
  intents: [TEST, TDD, COVERAGE, SPEC]
  description: "Charge quand l'intent correspond"
```

### 3. On-Keyword (Message Scanning)

```yaml
advanced:
  load: on_keyword
  keywords: [guard, interceptor, pipe, filter]
  description: "Charge si mot-cle detecte dans message"
```

---

## Manifest Format

```yaml
# profiles/backend/nestjs/manifest.yaml

profile:
  id: nestjs
  name: "NestJS"

knowledge:
  sections:
    core:
      load: always
      files: [knowledge/core/*.md]
      max_tokens: 2000

    advanced:
      load: on_keyword
      keywords: [guard, interceptor, pipe, filter, middleware]
      files: [knowledge/advanced/*.md]
      max_files: 2
      max_tokens: 3000

    testing:
      load: on_intent
      intents: [TEST, TDD, COVERAGE]
      files: [knowledge/testing/*.md]
      max_tokens: 2000

    security:
      load: on_intent
      intents: [SECURITY, AUTH, AUDIT]
      files: [knowledge/security/*.md]
      max_tokens: 1500

loading:
  strategy: conditional
  fallback: core
  max_sections: 2
  max_total_tokens: 5000
```

---

## Algorithm

```
PROFILE_LOADER(intent, message, profile_id):

  1. LOAD manifest from profiles/{category}/{profile_id}/manifest.yaml

  2. INIT sections_to_load = []

  3. FOR EACH section IN manifest.knowledge.sections:

     IF section.load == "always":
        ADD section TO sections_to_load

     ELSE IF section.load == "on_intent":
        IF intent IN section.intents:
           ADD section TO sections_to_load

     ELSE IF section.load == "on_keyword":
        FOR EACH keyword IN section.keywords:
           IF keyword IN lowercase(message):
              ADD section TO sections_to_load
              BREAK

  4. LIMIT sections_to_load TO manifest.loading.max_sections

  5. LOAD files from each section

  6. ESTIMATE tokens (chars / 4)

  7. IF total_tokens > manifest.loading.max_total_tokens:
        TRUNCATE to fit budget

  8. RETURN {
       sections: sections_to_load,
       content: concatenated_content,
       tokens: estimated_tokens
     }
```

---

## Hook Implementation

### Location

```
framework/hooks/profile-loader.sh
```

### Usage

```bash
# Load profile sections based on current state
bash framework/hooks/profile-loader.sh load nestjs

# Check what would be loaded (dry-run)
bash framework/hooks/profile-loader.sh preview nestjs

# Force specific sections
bash framework/hooks/profile-loader.sh load nestjs --sections core,testing

# Show available sections for a profile
bash framework/hooks/profile-loader.sh sections nestjs
```

### Integration Point

The hook can be called:
1. **Manually** by the user
2. **By Guardian** after routing (optional)
3. **By a pre-tool hook** (future)

---

## Token Budget

### Per Section (Limits)

| Section | Max Tokens | Rationale |
|---------|------------|---------------|
| core | 2,000 | Essential, always loaded |
| advanced | 3,000 | Complex patterns |
| testing | 2,000 | Jest + E2E |
| security | 1,500 | Auth patterns |

### Per Session (Hard Limit)

```yaml
loading:
  max_total_tokens: 5000  # Hard limit par profile
```

### Comparison

| Scenario | Without Loader | With Loader | Savings |
|----------|-------------|-------------|----------|
| DEV standard | 13K | 2-3K | -77% |
| DEV + testing | 13K | 4-5K | -62% |
| SECURITY audit | 13K | 3.5K | -73% |

---

## State Management

### Read (Input)

```json
// .harmony/local/memory/workflow-state.json
{
  "active_context": {
    "current_intent": "TEST",
    "current_profile": "nestjs"
  }
}
```

### Write (Output)

```json
// .harmony/local/memory/workflow-state.json (apres loading)
{
  "active_context": {
    "current_intent": "TEST",
    "current_profile": "nestjs"
  },
  "profile_loader": {
    "sections_loaded": ["core", "testing"],
    "tokens_used": 4200,
    "loaded_at": "2026-01-04T15:30:00Z"
  }
}
```

---

## Error Handling

| Error | Behavior |
|--------|--------------|
| Manifest not found | Fallback to no sections (warning) |
| Section files missing | Skip section, continue |
| Token budget exceeded | Truncate content |
| Invalid YAML | Log error, use defaults |
| No intent detected | Load core only |

---

## Files

| File | Description |
|------|-------------|
| `hooks/profile-loader.sh` | Main loader script |
| `profiles/{cat}/{name}/manifest.yaml` | Profile configuration |
| `profiles/{cat}/{name}/knowledge/{section}/*.md` | Knowledge files |
| `.harmony/local/memory/workflow-state.json` | State (read intent, write sections) |

---

## See Also

- [Guardian Routing](../../routing/README.md)
- [Profiles Registry](../../profiles/profiles-registry.yaml)
