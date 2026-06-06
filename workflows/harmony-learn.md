# /harmony learn - Knowledge Acquisition Workflow

> Enrichit les profiles et specialties avec des sources web actuelles (2025+).

---

## Usage

```bash
# Apprendre depuis une URL
/harmony learn <url>

# Apprendre avec profile explicite
/harmony learn <url> --profile nestjs

# Apprendre avec specialty explicite
/harmony learn <url> --specialty gaming

# Refresh un topic existant
/harmony learn --refresh nestjs/guards

# Recherche et apprentissage
/harmony learn --search "NestJS 2025 best practices"
```

---

## Workflow Complet

```
┌─────────────────────────────────────────────────────────────────┐
│                    /harmony learn <url>                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: FETCH CONTENT                                          │
│  ─────────────────────                                          │
│  Tools:                                                         │
│    - WebFetch (URL directe)                                     │
│    - Context7 (documentation officielle)                        │
│    - Brave Search (recherche generale)                          │
│                                                                  │
│  Output: Markdown content + metadata                            │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 2: DETECT CONTEXT                                         │
│  ──────────────────────                                         │
│  Analyze content for:                                           │
│    - Technology keywords (nestjs, angular, typescript)          │
│    - Domain keywords (game, medical, fintech)                   │
│    - Topic classification (guards, components, mechanics)       │
│                                                                  │
│  If ambiguous: ASK user to confirm profile/specialty            │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 3: EXTRACT KNOWLEDGE                                      │
│  ────────────────────────                                       │
│  Extract:                                                       │
│    - Best practices                                             │
│    - Code patterns                                              │
│    - Anti-patterns                                              │
│    - Configuration examples                                     │
│    - Common errors and solutions                                │
│                                                                  │
│  Format: Markdown with code blocks                              │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 4: VALIDATE                                               │
│  ───────────────                                                │
│  Checks:                                                        │
│    - No duplicates with existing knowledge                      │
│    - File size limits (200-500 lines ideal, 1000 max)           │
│    - Cross-references valid                                     │
│    - No conflicts with other profiles                           │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 5: SAVE                                                   │
│  ─────────                                                      │
│  Actions:                                                       │
│    - Create/update knowledge file                               │
│    - Update manifest.yaml (last_updated, sources)               │
│    - Add cross-references if needed                             │
│    - Git commit with source URL                                 │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 6: REPORT                                                 │
│  ──────────                                                     │
│  Output:                                                        │
│    - Profile/specialty updated                                  │
│    - Topics learned                                             │
│    - Files created/modified                                     │
│    - Cross-references added                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Detection Automatique

### Keywords par Profile

| Profile | Keywords |
|---------|----------|
| **javascript** | js, javascript, es2024, ecmascript |
| **typescript** | ts, typescript, tsconfig, type, interface |
| **nodejs** | node, nodejs, npm, express, fs, stream |
| **nestjs** | nestjs, @Module, @Controller, @Injectable |
| **angular** | angular, @Component, signal, NgModule |
| **react** | react, jsx, useState, useEffect, component |
| **prisma** | prisma, PrismaClient, schema.prisma |

### Keywords par Specialty

| Specialty | Keywords |
|-----------|----------|
| **gaming** | game, player, score, level, achievement, mechanics |
| **medical** | health, patient, HIPAA, HL7, FHIR, diagnostic |
| **fintech** | payment, transaction, PCI-DSS, banking, ledger |
| **education** | course, student, LMS, SCORM, learning |

---

## Format Knowledge File

```markdown
# {Topic} - {Profile}

> Source: {url}
> Fetched: {date}
> Version: {detected version}

---

## Overview

Brief description of the topic.

---

## Best Practices

### Practice 1: Title

Description and explanation.

```{language}
// Code example
```

### Practice 2: Title

...

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Name | What goes wrong | How to fix |

---

## Common Errors

### Error: {error message}

**Cause**: Why this happens
**Solution**: How to fix

---

## Cross-References

- [[profile/related-topic]]
- [[other-profile/related-topic]]
```

---

## Exemples

### Exemple 1: Documentation NestJS

```bash
/harmony learn https://docs.nestjs.com/guards
```

```
Fetching: https://docs.nestjs.com/guards
Detected: profile=nestjs, topic=guards
Extracting: best practices, patterns, examples...

Created: profiles/backend/nestjs/knowledge/guards.md
- 45 lines, 3 code examples
- Cross-refs: [[typescript/decorators]]

Updated: profiles/backend/nestjs/manifest.yaml
- last_updated: 2025-12-30
- Added source URL
```

### Exemple 2: Recherche Best Practices

```bash
/harmony learn --search "Angular signals 2025 best practices"
```

```
Searching: "Angular signals 2025 best practices"
Found: 5 relevant sources
  1. angular.dev/guide/signals (priority)
  2. blog.angular.io/signals-deep-dive
  3. ...

Fetching top 2 sources...
Detected: profile=angular, topic=signals
Extracting...

Created: profiles/frontend/angular/knowledge/signals.md
- 120 lines, 8 code examples
- Cross-refs: [[typescript/types]]
```

### Exemple 3: Gaming Specialty

```bash
/harmony learn https://www.gamedeveloper.com/design/progression-systems
```

```
Fetching: https://www.gamedeveloper.com/design/progression-systems
Detected: specialty=gaming, topic=progression
Extracting: XP curves, level scaling, unlock systems...

Created: specialties/gaming/knowledge/progression.md
- 85 lines, diagrams, formulas

Updated: specialties/gaming/manifest.yaml
```

---

## Options

| Option | Description |
|--------|-------------|
| `--profile <id>` | Force profile target |
| `--specialty <id>` | Force specialty target |
| `--topic <name>` | Force topic name |
| `--refresh` | Re-fetch and update existing |
| `--search <query>` | Search web then learn |
| `--dry-run` | Preview without saving |
| `--verbose` | Show extraction details |

---

## Integration Tools

### Context7 (Documentation)

Pour les docs officielles, utiliser Context7:

```javascript
// Resolve library ID
mcp__context7__resolve-library-id({
  libraryName: "nestjs",
  query: "guards authentication"
})

// Query docs
mcp__context7__query-docs({
  libraryId: "/nestjs/docs",
  query: "how to implement guards"
})
```

### Brave Search (Research)

Pour recherches generales:

```javascript
mcp__brave-search__brave_web_search({
  query: "NestJS guards best practices 2025",
  freshness: "py",  // Past year
  count: 5
})
```

### WebFetch (Direct URL)

Pour URLs specifiques:

```javascript
WebFetch({
  url: "https://docs.nestjs.com/guards",
  prompt: "Extract best practices, patterns, and code examples"
})
```

---

## Limites

| Limite | Valeur | Raison |
|--------|--------|--------|
| Lignes par fichier | 200-500 ideal | LLM comprehension |
| Max absolu | 1000 lignes | Split obligatoire |
| Sources par topic | 3 max | Avoid contradictions |
| Refresh cooldown | 24h | Avoid spam |

---

## Voir Aussi

- [Architecture](../docs/architecture.md)
- [Profiles Registry](../profiles/profiles-registry.yaml)
- [Specialties](../specialties/)
