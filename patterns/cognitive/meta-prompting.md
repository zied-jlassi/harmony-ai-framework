# Meta-Prompting Pattern

> **ID**: cognitive/meta-prompting
> **Category**: Cognitive Enhancement
> **Version**: 1.0.0

## Overview

Meta-Prompting generates or refines prompts dynamically based on task characteristics, complexity, and previous attempts. This enables adaptive prompt engineering that improves with context.

## Core Concept

```
┌─────────────────────────────────────────────────┐
│              META-PROMPTING FLOW                │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. ANALYZE TASK                                │
│     ↓                                           │
│  2. SELECT TEMPLATE                             │
│     ↓                                           │
│  3. ADAPT TO CONTEXT                            │
│     ↓                                           │
│  4. INJECT LEARNING                             │
│     ↓                                           │
│  5. GENERATE FINAL PROMPT                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Template Categories

### 1. Complexity-Based Templates

#### Simple Task Template
```markdown
## Task
{task_description}

## Expected Output
{output_format}
```

#### Medium Complexity Template
```markdown
## Context
{relevant_context}

## Task
{task_description}

## Constraints
{constraints}

## Expected Output
{output_format}
```

#### High Complexity Template
```markdown
## Background
{domain_context}

## Problem Statement
{problem_description}

## Requirements
{requirements_list}

## Constraints
{constraints}

## Approach Guidelines
{suggested_approach}

## Expected Output
{output_format}

## Validation Criteria
{success_criteria}
```

### 2. Domain-Based Templates

#### Code Generation
```markdown
## Language/Framework
{tech_stack}

## Existing Code Context
{code_context}

## Feature Request
{feature_description}

## Requirements
- Functionality: {functional_req}
- Performance: {perf_req}
- Security: {security_req}

## Output Format
{code_format}
```

#### Code Review
```markdown
## Code Under Review
{code_snippet}

## Review Focus
- [ ] Security vulnerabilities
- [ ] Performance issues
- [ ] Code style
- [ ] Best practices

## Context
{project_context}
```

#### Architecture Design
```markdown
## System Context
{system_description}

## Requirements
{requirements}

## Constraints
- Budget: {budget}
- Timeline: {timeline}
- Tech Stack: {tech_stack}

## Expected Deliverables
- Architecture diagram
- Component descriptions
- Trade-off analysis
```

## Adaptation Rules

### Context Injection

```bash
adapt_prompt_to_context() {
    local base_prompt="$1"
    local context="$2"

    # Extract context signals
    local has_errors=$(echo "$context" | grep -c "error\|fail\|exception")
    local has_code=$(echo "$context" | grep -c "function\|class\|def ")
    local complexity=$(calculate_complexity "$context")

    # Adapt prompt
    if (( has_errors > 0 )); then
        base_prompt+="

PREVIOUS ERRORS:
Pay special attention to avoiding these issues:
$(extract_errors "$context")
"
    fi

    if (( complexity > 7 )); then
        base_prompt+="

COMPLEXITY NOTE:
This is a complex task. Break it into steps.
Consider edge cases carefully.
"
    fi

    echo "$base_prompt"
}
```

### Learning Injection

```bash
inject_learned_patterns() {
    local prompt="$1"
    local agent="$2"

    # Get successful patterns for this agent
    local patterns=$(get_successful_patterns "$agent")

    if [[ -n "$patterns" ]]; then
        prompt+="

LEARNED PATTERNS:
Based on previous successful completions:
$patterns
"
    fi

    echo "$prompt"
}
```

## Dynamic Prompt Generation

### Algorithm

```
ALGORITHM: generate_meta_prompt(task, context, history)

1. CLASSIFY task complexity (low/medium/high)
2. IDENTIFY domain (code/design/review/etc.)
3. SELECT base template from complexity + domain
4. EXTRACT relevant context chunks (using FILCO)
5. INJECT context into template
6. CHECK history for similar tasks
   IF found: ADD learned patterns
7. APPLY emotional prompting techniques
8. VALIDATE prompt size within token budget
9. RETURN final prompt
```

### Implementation

```bash
generate_meta_prompt() {
    local task="$1"
    local context="$2"
    local history="${3:-}"

    # Step 1: Classify complexity
    local complexity=$(classify_complexity "$task" "$context")

    # Step 2: Identify domain
    local domain=$(identify_domain "$task")

    # Step 3: Select template
    local template=$(select_template "$complexity" "$domain")

    # Step 4: Extract relevant context
    local filtered_context=$(filco_filter "$context" "$task")

    # Step 5: Fill template
    local prompt=$(fill_template "$template" "$task" "$filtered_context")

    # Step 6: Add learned patterns
    if [[ -n "$history" ]]; then
        prompt=$(inject_learned_patterns "$prompt" "$history")
    fi

    # Step 7: Apply emotional prompting
    prompt=$(enhance_prompt_emotional "$prompt" "$complexity")

    # Step 8: Validate size
    local tokens=$(estimate_tokens "$prompt")
    if (( tokens > MAX_PROMPT_TOKENS )); then
        prompt=$(compact_prompt "$prompt" "$MAX_PROMPT_TOKENS")
    fi

    echo "$prompt"
}
```

## Template Storage

### File Structure

```
framework/
└── local/
    └── meta-prompts/
        ├── templates/
        │   ├── simple.md
        │   ├── medium.md
        │   └── complex.md
        ├── domains/
        │   ├── code-gen.md
        │   ├── code-review.md
        │   └── architecture.md
        └── adaptations/
            ├── error-context.md
            ├── learning-injection.md
            └── emotional-boost.md
```

### JSON Configuration

```json
{
  "templates": {
    "simple": {
      "file": "templates/simple.md",
      "max_tokens": 500,
      "domains": ["quick-fix", "simple-query"]
    },
    "medium": {
      "file": "templates/medium.md",
      "max_tokens": 1500,
      "domains": ["feature", "bugfix", "refactor"]
    },
    "complex": {
      "file": "templates/complex.md",
      "max_tokens": 3000,
      "domains": ["architecture", "security", "migration"]
    }
  },
  "adaptation_rules": {
    "error_context": {
      "trigger": "previous_errors > 0",
      "injection": "adaptations/error-context.md"
    },
    "high_stakes": {
      "trigger": "domain in [security, production, database]",
      "injection": "adaptations/emotional-boost.md"
    }
  }
}
```

## Integration Points

### With Guardian Protocol

Meta-prompting integrates at Guardian Step 3 (Context Loading):

```
Guardian Step 3: Load Context
  ↓
Meta-Prompt Generation
  ↓
Context Injection
  ↓
Final Prompt Assembly
  ↓
Guardian Step 4: Agent Invocation
```

### With Self-Evolving Loop

```
Self-Evolving Loop:
  1. Execute with meta-prompt
  2. Evaluate output
  3. IF score < threshold:
     - Analyze failure
     - Adapt meta-prompt
     - Retry with new prompt
```

## Metrics

Track meta-prompting effectiveness:

| Metric | Description |
|--------|-------------|
| Template Hit Rate | % of tasks matched to optimal template |
| Adaptation Success | % improvement after adaptation |
| Token Efficiency | Avg tokens saved by FILCO filtering |
| First-Try Success | % tasks completed without retry |

## Related Patterns

- `cognitive/self-evolving.md` - Uses meta-prompts in improvement loop
- `cognitive/emotional-prompting.md` - Emotional enhancement layer
- `P-003-jit-context.md` - Just-in-time context loading
- `lib/context-filter.sh` - FILCO implementation
