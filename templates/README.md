# Harmony Templates

> **Standardized templates for consistent project artifacts.**

---

## Overview

Templates provide consistent structure for all project artifacts.
They ensure nothing is forgotten and standardize communication.

---

## Available Templates

| Template | Purpose | Created By |
|----------|---------|------------|
| `story.md` | User story definition | SM |
| `epic.md` | Epic/feature grouping | SM |
| `ucv.md` | Use Case Verifications | Clara |
| `adr.md` | Architecture Decision Record | Architect |
| `task.md` | Technical subtask | Developer |
| `handoff.md` | Session handoff | Any agent |
| `brief.md` | Product brief | Analyst |
| `prd.md` | Product Requirements Document | Analyst |
| `retrospective.md` | Sprint/epic retrospective | SM |
| `charter.md` | Exploratory test session | Luna |

---

## Template Structure

```
templates/
├── README.md           # This file
├── story.md           # User story
├── epic.md            # Epic/feature
├── ucv.md             # Use Case Verifications
├── adr.md             # Architecture Decision Record
├── task.md            # Technical task
├── handoff.md         # Session handoff
├── brief.md           # Product brief
├── prd.md             # PRD
├── retrospective.md   # Retrospective (REX)
└── charter.md         # Exploratory test charter
```

---

## Usage

### In Claude Code

```bash
# Create a new story from template
"create story from template for user authentication"

# Create ADR from template
"create ADR for database selection"
```

### Programmatically

```typescript
function createFromTemplate(
  templateName: string,
  variables: Record<string, string>
): string {
  const template = readTemplate(templateName);
  return interpolate(template, variables);
}
```

---

## Template Variables

Templates use `{variable}` syntax for interpolation:

```markdown
# STORY-{story_id}: {title}

## Metadata
- **Epic**: EPIC-{epic_id}
- **Status**: {status}
- **Created**: {date}
```

---

## Best Practices

1. **Use templates consistently** - Don't create ad-hoc formats
2. **Fill all required fields** - Templates have required vs optional sections
3. **Keep templates updated** - Evolve templates as needs change
4. **Version templates** - Track template changes over time

---

## Related

- [SM Agent](../agents/specialists/sm.md)
- [Clara Agent](../agents/specialists/clara.md)
- [Architect Agent](../agents/architect.md)

