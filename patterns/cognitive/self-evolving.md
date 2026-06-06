# Self-Evolving Agent Loop Pattern

> **ID**: cognitive/self-evolving
> **Category**: Cognitive Enhancement
> **Version**: 1.0.0

## Overview

The Self-Evolving Agent Loop implements iterative self-improvement using feedback, meta-prompting, and evaluation. Based on OpenAI's Self-Evolving Agents Cookbook, it enables autonomous agent retraining through LLM-as-judge feedback.

## Core Loop

```
┌─────────────────────────────────────────────────────────────┐
│                 SELF-EVOLVING AGENT LOOP                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐    ┌──────────┐    ┌──────────┐               │
│  │ EXECUTE │───►│ EVALUATE │───►│ FEEDBACK │               │
│  └─────────┘    └──────────┘    └──────────┘               │
│       ▲              │               │                      │
│       │              ▼               ▼                      │
│       │         Score >= T?    ┌────────────┐              │
│       │              │         │META-PROMPT │              │
│       │         YES  │  NO     │  GENERATE  │              │
│       │              │         └────────────┘              │
│       │              ▼               │                      │
│       │         ┌────────┐          │                      │
│       │         │COMPLETE│          │                      │
│       │         └────────┘          │                      │
│       │                             │                      │
│       └─────────────────────────────┘                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 1. Executor

Runs the agent task and produces output.

```bash
execute_task() {
    local agent="$1"
    local task="$2"
    local prompt="$3"

    # Execute agent with current prompt
    local output=$(invoke_agent "$agent" "$prompt")

    echo "$output"
}
```

### 2. Evaluator (LLM-as-Judge)

Scores the output quality.

```bash
evaluate_output() {
    local task="$1"
    local output="$2"
    local criteria="$3"

    # Use LLM-as-Judge pattern
    local evaluation_prompt="
You are evaluating the quality of an AI agent's output.

TASK: $task

OUTPUT:
$output

CRITERIA:
$criteria

Score from 0-100 and explain your reasoning.
Format: SCORE: [number]
REASONING: [explanation]
"

    local result=$(invoke_judge "$evaluation_prompt")

    # Extract score
    local score=$(echo "$result" | grep "SCORE:" | sed 's/SCORE: //')
    echo "$score"
}
```

### 3. Feedback Generator

Analyzes failures and generates improvement suggestions.

```bash
generate_feedback() {
    local task="$1"
    local output="$2"
    local evaluation="$3"

    local feedback_prompt="
Analyze this task execution and suggest improvements.

TASK: $task

OUTPUT:
$output

EVALUATION:
$evaluation

Provide specific, actionable feedback for improvement.
Focus on:
1. What went wrong
2. What patterns to avoid
3. What approaches to try instead
"

    invoke_feedback_agent "$feedback_prompt"
}
```

### 4. Meta-Prompt Evolver

Updates prompts based on feedback.

```bash
evolve_prompt() {
    local original_prompt="$1"
    local feedback="$2"
    local iteration="$3"

    local evolution_prompt="
Improve this prompt based on the feedback.

ORIGINAL PROMPT:
$original_prompt

FEEDBACK:
$feedback

ITERATION: $iteration

Create an improved version that addresses the feedback.
Keep successful elements, fix problematic ones.
"

    invoke_prompt_evolver "$evolution_prompt"
}
```

## Algorithm

```
ALGORITHM: self_evolving_loop(agent, task, max_iterations, threshold)

INPUTS:
  - agent: The agent to evolve
  - task: The task to complete
  - max_iterations: Maximum retry attempts (default: 3)
  - threshold: Quality score threshold (default: 80)

1. INITIALIZE
   prompt = generate_initial_prompt(task)
   iteration = 0
   history = []

2. EXECUTE
   output = execute_task(agent, task, prompt)

3. EVALUATE
   score = evaluate_output(task, output, criteria)
   history.append({iteration, prompt, output, score})

4. CHECK COMPLETION
   IF score >= threshold:
     RECORD success in evolution-log
     RETURN {success: true, output, iterations: iteration}

5. CHECK MAX ITERATIONS
   IF iteration >= max_iterations:
     RECORD failure with best attempt
     RETURN {success: false, best_output: highest_scored, iterations: iteration}

6. GENERATE FEEDBACK
   feedback = generate_feedback(task, output, evaluation)

7. EVOLVE PROMPT
   prompt = evolve_prompt(prompt, feedback, iteration)
   iteration += 1

8. GOTO STEP 2
```

## Implementation

```bash
#!/bin/bash
# Self-Evolving Loop Implementation

self_evolve() {
    local agent="$1"
    local task="$2"
    local max_iterations="${3:-3}"
    local threshold="${4:-80}"

    local prompt
    prompt=$(generate_initial_prompt "$task")

    local iteration=0
    local best_score=0
    local best_output=""

    while (( iteration < max_iterations )); do
        echo "Iteration $((iteration + 1))/$max_iterations"

        # Execute
        local output
        output=$(execute_task "$agent" "$task" "$prompt")

        # Evaluate
        local score
        score=$(evaluate_output "$task" "$output" "$EVAL_CRITERIA")

        # Track best
        if (( score > best_score )); then
            best_score=$score
            best_output="$output"
        fi

        # Check success
        if (( score >= threshold )); then
            record_evolution_success "$agent" "$task" "$iteration" "$score"
            echo "$output"
            return 0
        fi

        # Generate feedback and evolve
        local feedback
        feedback=$(generate_feedback "$task" "$output" "$score")

        prompt=$(evolve_prompt "$prompt" "$feedback" "$iteration")

        ((iteration++))
    done

    # Return best attempt
    record_evolution_partial "$agent" "$task" "$max_iterations" "$best_score"
    echo "$best_output"
    return 1
}
```

## Integration with Sentinel

The Self-Evolving Loop integrates with Sentinel for error memory:

```bash
# Record failed iterations in Sentinel
record_evolution_failure() {
    local agent="$1"
    local task="$2"
    local output="$3"
    local feedback="$4"

    # Add to error journal for future learning
    sentinel_record_error \
        --agent "$agent" \
        --task "$task" \
        --output "$output" \
        --feedback "$feedback" \
        --type "evolution_failure"
}

# Learn from past evolution attempts
get_evolution_patterns() {
    local agent="$1"
    local task_type="$2"

    # Query Sentinel for relevant patterns
    sentinel_query_patterns \
        --agent "$agent" \
        --type "evolution_failure" \
        --similar_to "$task_type"
}
```

## Configuration

### evolution-config.json

```json
{
  "max_iterations": 3,
  "score_threshold": 80,
  "evaluation_criteria": {
    "correctness": 40,
    "completeness": 30,
    "code_quality": 20,
    "efficiency": 10
  },
  "evolution_strategies": {
    "low_score": "major_revision",
    "medium_score": "targeted_improvement",
    "high_score": "minor_polish"
  },
  "circuit_breaker": {
    "max_total_iterations": 10,
    "min_improvement_rate": 0.05
  }
}
```

## Metrics

Track evolution effectiveness:

| Metric | Description |
|--------|-------------|
| First-Try Success Rate | % tasks completed on first attempt |
| Avg Iterations | Mean iterations to success |
| Evolution Success Rate | % improved after evolution |
| Score Improvement | Avg score gain per iteration |
| Prompt Stability | How much prompts change per iteration |

## Safety Guardrails

### Circuit Breaker Integration

```bash
check_evolution_circuit() {
    local agent="$1"
    local total_iterations="$2"
    local improvement_rate="$3"

    # Stop if too many total iterations
    if (( total_iterations > MAX_TOTAL_ITERATIONS )); then
        echo "CIRCUIT_OPEN: Max iterations exceeded"
        return 1
    fi

    # Stop if not improving
    if (( $(echo "$improvement_rate < $MIN_IMPROVEMENT_RATE" | bc -l) )); then
        echo "CIRCUIT_OPEN: Insufficient improvement"
        return 1
    fi

    return 0
}
```

### Human Escalation

```bash
escalate_evolution() {
    local agent="$1"
    local task="$2"
    local history="$3"

    echo "ESCALATION: Evolution loop unable to complete task"
    echo "Agent: $agent"
    echo "Task: $task"
    echo "Attempts: $(echo "$history" | jq length)"
    echo "Best Score: $(echo "$history" | jq 'max_by(.score) | .score')"

    # Create escalation record
    create_escalation_record "$agent" "$task" "$history"
}
```

## Related Patterns

- `cognitive/meta-prompting.md` - Dynamic prompt generation
- `cognitive/emotional-prompting.md` - Emotional enhancement
- `P-004-circuit-breaker.md` - Safety limits
- `knowledge/domains/ai/evaluation-patterns.md` - LLM-as-Judge
