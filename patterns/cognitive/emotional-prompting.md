# Emotional Prompting Pattern

> **ID**: cognitive/emotional-prompting
> **Category**: Cognitive Enhancement
> **Version**: 1.0.0

## Overview

Emotional Prompting incorporates psychological principles and emotional context to enhance model engagement and output quality. Research shows that emotionally-aware prompts can improve task completion and response quality.

## Techniques

### 1. Positive Framing

Frame instructions positively rather than negatively.

**Instead of:**
```
Don't write insecure code.
Don't forget error handling.
```

**Use:**
```
Write secure, robust code.
Include comprehensive error handling.
```

### 2. Stake Communication

Communicate the importance and impact of the task.

**Pattern:**
```
This [feature/fix] will affect [N] users daily.
This is critical for [business goal].
Users depend on this working correctly.
```

**Example:**
```
Implement authentication carefully - this protects 10,000 daily users.
```

### 3. Empathy Injection

Connect the task to user experience and feelings.

**Pattern:**
```
Users will be [emotion] if [condition].
Think about how users feel when [scenario].
```

**Example:**
```
Users will be frustrated if the login fails silently.
Consider how a user feels when their data isn't saved.
```

### 4. Motivational Anchoring

Anchor to expert behavior and best practices.

**Pattern:**
```
As an expert [role] would...
Following industry best practices...
A senior [role] would approach this by...
```

**Example:**
```
As an expert security engineer would, review all input validation.
```

### 5. Confidence Building

Build confidence while maintaining accuracy.

**Pattern:**
```
You have the knowledge to [task].
Based on your training, you can [capability].
```

## Implementation

### Prompt Template

```markdown
## Context
[Stake communication: why this matters]

## Task
[Positive framing: what to do, not what to avoid]

## Approach
[Motivational anchoring: expert perspective]

## User Impact
[Empathy injection: how users are affected]
```

### Integration with Agents

```bash
# In agent prompts, include emotional context
EMOTIONAL_CONTEXT="
This implementation directly impacts user experience.
Users trust this system with their data.
Quality here reflects on the entire team.
"

# Add to task context
enhance_prompt_emotional() {
    local task="$1"
    local stakes="${2:-medium}"

    case "$stakes" in
        high)
            echo "CRITICAL: $task - This affects production users directly."
            ;;
        medium)
            echo "IMPORTANT: $task - Users rely on this functionality."
            ;;
        low)
            echo "$task"
            ;;
    esac
}
```

## When to Use

| Scenario | Technique | Example |
|----------|-----------|---------|
| Security code | Stakes + Expert | "Security experts would validate all inputs. 1000s of users depend on this." |
| Bug fixes | Empathy | "Users are frustrated by this issue. Help them by fixing it properly." |
| New features | Positive + Motivation | "Create an elegant solution that users will love." |
| Refactoring | Expert + Stakes | "As a senior architect would, improve the structure while maintaining stability." |

## Anti-Patterns

### Avoid

- **Excessive negativity**: "Don't mess this up" → Creates anxiety
- **Vague stakes**: "This is important" → Not specific enough
- **Manipulation**: Using emotional pressure unethically
- **Over-dramatization**: Every task is "critical" → Loses meaning

### Better Alternatives

- **Balanced stakes**: Be honest about actual importance
- **Specific impact**: Quantify when possible (N users, $X impact)
- **Authentic empathy**: Genuine user consideration, not manufactured

## Metrics

Track effectiveness with:

- Task completion quality scores
- Error rates before/after
- User satisfaction (if applicable)
- Agent confidence scores

## Research References

- "Emotional Prompting for Large Language Models" (2025)
- "Psychological Principles in AI Interaction" (2024)
- "User-Centric AI Design Patterns" (2025)

## Related Patterns

- `cognitive/meta-prompting.md` - Dynamic prompt generation
- `cognitive/self-evolving.md` - Continuous improvement
- `P-003-jit-context.md` - Just-in-time context loading
