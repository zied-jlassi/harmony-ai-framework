# Pattern P-021: Meta-Prompting System

> **ID**: P-021-meta-prompting
> **Category**: Context & Routing
> **Priority**: High
> **Version**: 1.0.0

## Problem

Static prompts don't adapt to task complexity, domain context, or previous failures. This leads to suboptimal agent performance and increased iteration cycles.

## Solution

Implement a meta-prompting system that dynamically generates or refines prompts based on:
- Task characteristics and complexity
- Domain-specific requirements
- Previous attempt failures
- Learned patterns from successful completions

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   META-PROMPTING PIPELINE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Task Input                                                │
│       │                                                     │
│       ▼                                                     │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│   │  CLASSIFY   │───►│   SELECT    │───►│   ADAPT     │    │
│   │  Complexity │    │  Template   │    │  Context    │    │
│   └─────────────┘    └─────────────┘    └─────────────┘    │
│                                               │             │
│                                               ▼             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│   │   OUTPUT    │◄───│  VALIDATE   │◄───│   INJECT    │    │
│   │   Prompt    │    │   Size      │    │  Learning   │    │
│   └─────────────┘    └─────────────┘    └─────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Implementation

### Template Selection

```bash
# Complexity-based template selection
select_template() {
    local complexity="$1"
    local domain="$2"

    case "$complexity" in
        "low")   echo "templates/simple.md" ;;
        "medium") echo "templates/medium.md" ;;
        "high")  echo "templates/complex.md" ;;
    esac
}
```

### Context Adaptation

```bash
# Adapt prompt with context
adapt_prompt() {
    local template="$1"
    local context="$2"
    local history="$3"

    # Apply FILCO filtering
    local filtered_context=$(filco_filter "$context" "$task")

    # Inject learned patterns
    local patterns=$(get_successful_patterns "$agent")

    # Fill template
    fill_template "$template" "$filtered_context" "$patterns"
}
```

## Integration Points

1. **Guardian Protocol Step 3**: Invoked during context loading
2. **Self-Evolving Loop**: Updates prompts after failed iterations
3. **Sentinel System**: Retrieves learned patterns for injection

## Configuration

```json
{
  "templates": {
    "simple": {"max_tokens": 500},
    "medium": {"max_tokens": 1500},
    "complex": {"max_tokens": 3000}
  },
  "complexity_thresholds": {
    "low": 3,
    "medium": 7
  }
}
```

## Related Patterns

- `P-003-jit-context` - Just-in-time context loading
- `P-024-context-filtering` - FILCO implementation
- `cognitive/meta-prompting.md` - Detailed techniques

## Metrics

| Metric | Target |
|--------|--------|
| First-Try Success Rate | > 70% |
| Avg Iterations to Success | < 1.5 |
| Token Efficiency | > 80% |
