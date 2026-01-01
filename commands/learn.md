# Harmony Learn - Knowledge Acquisition

> **"Up-to-date knowledge from 2025 sources, loaded just-in-time."**
>
> Learn command enriches profiles and specialties with current web sources.

---

## Why Learn?

| Without Learn | With Learn |
|---------------|------------|
| Static knowledge | Dynamic, current |
| Outdated patterns | 2025 best practices |
| Generic advice | Specific to your stack |
| Manual research | Automated extraction |

---

## Commands

### Learn from URL

```bash
harmony learn <url>
harmony learn https://docs.nestjs.com/guards
```

### Learn from Search

```bash
harmony learn --search "query"
harmony learn --search "NestJS 2025 best practices"
```

### Learn with Target

```bash
harmony learn <url> --profile <id>
harmony learn https://... --profile nestjs

harmony learn <url> --specialty <id>
harmony learn https://... --specialty gaming
```

### Refresh Existing

```bash
harmony learn --refresh <topic>
harmony learn --refresh nestjs/guards
```

---

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    HARMONY LEARN WORKFLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 1: FETCH CONTENT                                          │
│  ─────────────────────                                          │
│  Tools:                                                         │
│    • WebFetch (direct URL)                                      │
│    • Context7 (official docs)                                   │
│    • Brave Search (general research)                            │
│                                                                  │
│  Output: Markdown content + metadata                            │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 2: DETECT CONTEXT                                         │
│  ──────────────────────                                         │
│  Analyze content for:                                           │
│    • Technology keywords (nestjs, angular, typescript)          │
│    • Domain keywords (game, medical, fintech)                   │
│    • Topic classification (guards, components, mechanics)       │
│                                                                  │
│  If ambiguous: ASK user to confirm                              │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 3: EXTRACT KNOWLEDGE                                      │
│  ────────────────────────                                       │
│  Extract:                                                       │
│    • Best practices                                             │
│    • Code patterns                                              │
│    • Anti-patterns                                              │
│    • Configuration examples                                     │
│    • Common errors and solutions                                │
│                                                                  │
│  Format: Markdown with code blocks                              │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 4: VALIDATE                                               │
│  ───────────────                                                │
│  Checks:                                                        │
│    • No duplicates with existing knowledge                      │
│    • File size (200-500 lines ideal, 1000 max)                  │
│    • Cross-references valid                                     │
│    • No conflicts with other profiles                           │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 5: SAVE                                                   │
│  ─────────                                                      │
│  Actions:                                                       │
│    • Create/update knowledge file                               │
│    • Update manifest.yaml (last_updated, sources)               │
│    • Add cross-references if needed                             │
│    • Git commit with source URL                                 │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  STEP 6: REPORT                                                 │
│  ──────────                                                     │
│  Output:                                                        │
│    • Profile/specialty updated                                  │
│    • Topics learned                                             │
│    • Files created/modified                                     │
│    • Cross-references added                                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Auto-Detection

### Profile Keywords

| Profile | Keywords |
|---------|----------|
| javascript | js, javascript, es2024, ecmascript |
| typescript | ts, typescript, tsconfig, type, interface |
| nodejs | node, nodejs, npm, express, fs, stream |
| nestjs | nestjs, @Module, @Controller, @Injectable |
| angular | angular, @Component, signal, NgModule |
| react | react, jsx, useState, useEffect, component |
| prisma | prisma, PrismaClient, schema.prisma |

### Specialty Keywords

| Specialty | Keywords |
|-----------|----------|
| gaming | game, player, score, level, achievement, mechanics |
| medical | health, patient, HIPAA, HL7, FHIR, diagnostic |
| fintech | payment, transaction, PCI-DSS, banking, ledger |
| education | course, student, LMS, SCORM, learning |

---

## Knowledge File Format

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

## Examples

### Example 1: NestJS Documentation

```bash
harmony learn https://docs.nestjs.com/guards
```

**Output:**
```
Fetching: https://docs.nestjs.com/guards
Detected: profile=nestjs, topic=guards
Extracting: best practices, patterns, examples...

Created: profiles/backend/nestjs/knowledge/guards.md
├── 45 lines, 3 code examples
└── Cross-refs: [[typescript/decorators]]

Updated: profiles/backend/nestjs/manifest.yaml
├── last_updated: 2025-01-15
└── Added source URL
```

### Example 2: Web Search

```bash
harmony learn --search "Angular signals 2025 best practices"
```

**Output:**
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
├── 120 lines, 8 code examples
└── Cross-refs: [[typescript/types]]
```

### Example 3: Gaming Specialty

```bash
harmony learn https://www.gamedeveloper.com/design/progression-systems
```

**Output:**
```
Fetching: https://www.gamedeveloper.com/design/progression-systems
Detected: specialty=gaming, topic=progression
Extracting: XP curves, level scaling, unlock systems...

Created: specialties/gaming/knowledge/progression.md
├── 85 lines, diagrams, formulas

Updated: specialties/gaming/manifest.yaml
```

---

## Source Tools

| Tool | When to Use | Example |
|------|-------------|---------|
| **Context7** | Official docs | docs.nestjs.com |
| **Brave Search** | Research queries | "best practices 2025" |
| **WebFetch** | Direct URLs | blog posts, articles |

### Context7 Integration

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

---

## Limits

| Limit | Value | Reason |
|-------|-------|--------|
| Lines per file | 200-500 ideal | LLM comprehension |
| Max absolute | 1000 lines | Split required |
| Sources per topic | 3 max | Avoid contradictions |
| Refresh cooldown | 24h | Avoid spam |

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

## JIT Loading Benefit

Without Learn:
```
Context: 50,000 tokens (everything)
Result: Slow, unfocused, hallucinations
```

With Learn:
```
Context: 2,000 tokens (relevant only)
Result: Fast, focused, accurate
```

**This is the power of curated, JIT-loaded knowledge.**
