# P-009: Task Progress Visualization

> **Persistent context header showing story and task progress.**

---

## Purpose

This pattern ensures:
1. **Context visibility** - Always know which story you're working on
2. **Progress tracking** - Visual task completion status
3. **Crash recovery** - Searchable format to find where you left off
4. **Action clarity** - Current task highlighted

---

## Format Specification

### Task ID Format

```
T-XXX[x]  = Task completed
T-XXX[]   = Task pending/in progress
```

Where XXX is a 3-digit number (001, 002, etc.)

### Full Progress Header

```
┌─────────────────────────────────────────────────────────────────┐
│ STORY-{id}: {title}                                              │
├─────────────────────────────────────────────────────────────────┤
│ T-001[x]: {task_1_description}                                   │
│ T-002[x]: {task_2_description}                                   │
│ T-003[]: {task_3_description}                    ← EN COURS      │
│ T-004[]: {task_4_description}                                    │
├─────────────────────────────────────────────────────────────────┤
│ Progress: ████████░░░░░░░░ {percent}% ({done}/{total})          │
└─────────────────────────────────────────────────────────────────┘
```

### Compact Format (for inline use)

```
STORY-042: Modifier utilisateur via popin
├── T-001[x]: Créer composant Modal
├── T-002[x]: Ajouter validation email
├── T-003[]: Intégrer API update        ← EN COURS
└── T-004[]: Ajouter tests E2E
    Progress: 50% (2/4)
```

---

## When to Display

| Situation | Action |
|-----------|--------|
| **Start of story work** | Show full header |
| **Each task start** | Update header with ← EN COURS marker |
| **Task completion** | Update T-XXX[] → T-XXX[x] |
| **After each tool use** | Show compact progress |
| **Story completion** | Show final 100% status |

---

## Usage Rules

### RULE 1: Always Show Context

Before ANY code modification during story implementation:
```
STORY-042: Modifier utilisateur via popin
├── T-001[x]: Créer composant Modal
├── T-002[]: Ajouter validation email   ← EN COURS
└── T-003[]: Ajouter tests E2E
```

### RULE 2: Update on Completion

When a task is done, immediately update:
```
T-002[] → T-002[x]
```

### RULE 3: Searchable Format

The format `T-XXX[]` allows:
```bash
# Find pending tasks
grep "T-.*\[\]" session.log

# Find completed tasks
grep "T-.*\[x\]" session.log

# Find specific task
grep "T-003" session.log
```

### RULE 4: Crash Recovery

If session is lost, search for last state:
```bash
# Find last task in progress
grep "EN COURS" session.log | tail -1
```

---

## Progress Bar Generation

```
Percentage | Bar
-----------|--------------------
0%         | ░░░░░░░░░░░░░░░░
25%        | ████░░░░░░░░░░░░
50%        | ████████░░░░░░░░
75%        | ████████████░░░░
100%       | ████████████████
```

Formula: `█` × (percent/100 × 16), `░` × remaining

---

## Examples

### Starting a Story

```
┌─────────────────────────────────────────────────────────────────┐
│ STORY-042: Modifier utilisateur via popin                        │
├─────────────────────────────────────────────────────────────────┤
│ T-001[]: Créer composant Modal                   ← EN COURS      │
│ T-002[]: Ajouter validation email                                │
│ T-003[]: Intégrer API update                                     │
│ T-004[]: Ajouter tests E2E                                       │
├─────────────────────────────────────────────────────────────────┤
│ Progress: ░░░░░░░░░░░░░░░░ 0% (0/4)                              │
└─────────────────────────────────────────────────────────────────┘
```

### Mid-Story Progress

```
STORY-042: Modifier utilisateur via popin
├── T-001[x]: Créer composant Modal
├── T-002[x]: Ajouter validation email
├── T-003[]: Intégrer API update        ← EN COURS
└── T-004[]: Ajouter tests E2E
    Progress: ████████░░░░░░░░ 50% (2/4)
```

### Story Completed

```
STORY-042: Modifier utilisateur via popin ✓
├── T-001[x]: Créer composant Modal
├── T-002[x]: Ajouter validation email
├── T-003[x]: Intégrer API update
└── T-004[x]: Ajouter tests E2E
    Progress: ████████████████ 100% (4/4) ✓ DONE
```

---

## Integration with Agents

### Developer Agent

When implementing a story, MUST:
1. Display progress header at start
2. Update after each task
3. Mark ← EN COURS on current task
4. Show completion when done

### SM Agent

When creating story with tasks:
1. Generate T-XXX format for each task
2. All start as T-XXX[]
3. Include in story file

---

## Template for Story Tasks

```markdown
## Tasks

| ID | Description | Status |
|----|-------------|--------|
| T-001 | {description} | [] |
| T-002 | {description} | [] |
| T-003 | {description} | [] |

<!-- Progress tracking format:
T-001[]: {description}
T-002[]: {description}
T-003[]: {description}
-->
```

---

## Memory Integration

Store current progress in workflow-state.json:

```json
{
  "active_context": {
    "current_story": "STORY-042",
    "current_story_title": "Modifier utilisateur via popin",
    "tasks": [
      {"id": "T-001", "description": "Créer composant Modal", "done": true},
      {"id": "T-002", "description": "Ajouter validation email", "done": true},
      {"id": "T-003", "description": "Intégrer API update", "done": false},
      {"id": "T-004", "description": "Ajouter tests E2E", "done": false}
    ],
    "current_task": "T-003",
    "progress_percent": 50
  }
}
```

---

## Related

- [Story Template](../templates/story.md)
- [Developer Agent](../agents/developer.md)
- [P-007: Story-Based Development](P-007-story-based.md)
