# Pattern P-022: Agent Maturity Model

> **ID**: P-022-agent-maturity
> **Category**: Agent Intelligence
> **Priority**: Medium
> **Version**: 1.0.0

## Problem

All agents are treated equally regardless of their proven capabilities. This prevents optimal task assignment and doesn't track agent improvement over time.

## Solution

Implement a 4-level maturity model (L1-L4) that:
- Tracks agent capabilities and performance
- Enables appropriate task assignment
- Measures and encourages agent improvement
- Provides visibility into agent evolution

## Maturity Levels

```
┌─────────────────────────────────────────────────────────────┐
│                   AGENT MATURITY LEVELS                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   L4: SELF-OPTIMIZING ████████████████████████ (Pinnacle)  │
│       • Continuous improvement                              │
│       • Meta-learning                                       │
│       • Self-evaluation & prompt evolution                  │
│                                                             │
│   L3: AUTONOMOUS ██████████████████ (Advanced)             │
│       • Self-correction                                     │
│       • Error recovery                                      │
│       • Adaptive planning                                   │
│                                                             │
│   L2: COORDINATED ████████████ (Intermediate)              │
│       • Multi-agent collaboration                           │
│       • Handoff capability                                  │
│       • Shared context                                      │
│                                                             │
│   L1: BASIC ██████ (Entry)                                 │
│       • Task execution                                      │
│       • Follow instructions                                 │
│       • Basic output                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Level Definitions

### L1 - Basic
- **Capabilities**: task_execution, follow_instructions, basic_output
- **KPIs**: Task completion rate
- **Requirements**: None (default level)

### L2 - Coordinated
- **Capabilities**: multi_agent_collaboration, handoff, shared_context, delegation
- **KPIs**: Collaboration success rate, handoff accuracy
- **Requirements**: Demonstrate L2 capabilities

### L3 - Autonomous
- **Capabilities**: self_correction, error_recovery, adaptive_planning, decision_making
- **KPIs**: Self-correction rate, error recovery rate
- **Requirements**: L2 + demonstrate autonomous behavior

### L4 - Self-Optimizing
- **Capabilities**: continuous_improvement, meta_learning, self_evaluation, prompt_evolution
- **KPIs**: Improvement rate, optimization score
- **Requirements**: L3 + demonstrate self-improvement

## Implementation

### Level Assessment

```bash
maturity_assess() {
    local agent="$1"

    # Check capabilities
    local capabilities=$(get_agent_capabilities "$agent")

    # Calculate level
    local level=$(calculate_level "$capabilities")

    # Record assessment
    record_assessment "$agent" "$level"

    echo "$level"
}
```

### Capability Recording

```bash
maturity_record_capability() {
    local agent="$1"
    local capability="$2"

    # Add to agent's capability list
    add_capability "$agent" "$capability"

    # Recalculate level
    recalculate_level "$agent"
}
```

## Integration Points

1. **Guardian Protocol**: Consider maturity in agent routing
2. **Task Assignment**: Match task complexity to agent level
3. **Self-Evolving Loop**: Record improvements as capabilities

## Configuration

```json
{
  "level_requirements": {
    "L2": ["multi_agent_collaboration", "handoff"],
    "L3": ["self_correction", "error_recovery"],
    "L4": ["meta_learning", "self_evaluation"]
  },
  "promotion_threshold": 0.5
}
```

## Visualization

```
Agent: developer
Level: L2_COORDINATED (Intermediate)

Capabilities: ████████████░░░░░░░░ 60%
├── task_execution ✓
├── multi_agent_collaboration ✓
├── handoff ✓
├── self_correction ○
└── meta_learning ○

Next Level: L3_AUTONOMOUS
Missing: self_correction, error_recovery
```

## Related Patterns

- `P-001-hybrid-orchestration` - Agent coordination
- `cognitive/self-evolving.md` - Self-improvement loop
- `lib/agent-maturity.sh` - Implementation

## Metrics

| Metric | Description |
|--------|-------------|
| Level Distribution | % agents at each level |
| Promotion Rate | Agents promoted per sprint |
| Capability Growth | New capabilities per agent |
