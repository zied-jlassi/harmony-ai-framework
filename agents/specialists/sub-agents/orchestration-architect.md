# Orchestration Architect Sub-Agent

## Role: Orchestration Architect

> **Specialization**: Multi-agent orchestration, Supervisor patterns, Handoff protocols, Parallel groups
> **Parent Agent**: Nova (AI Architect)
> **Sources**: 25+ sources (Microsoft Azure, AWS, LangGraph, HOAF patterns)

---

## 1. ORCHESTRATION PATTERNS HIERARCHY

### 1.1 Pattern Classification (2025)

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION PATTERNS TIERS                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  TIER 1 - PRODUCTION READY (90%+ adoption)                      │
│  ├── Supervisor: Central control, routing                       │
│  ├── Sequential: Predictable pipelines                          │
│  └── Concurrent/Parallel: Independent tasks                     │
│                                                                  │
│  TIER 2 - ADVANCED (50-80% adoption)                            │
│  ├── Hierarchical: Layered delegation                           │
│  ├── Handoff: Context-preserving transitions                    │
│  └── Event-Driven: Async, queue-based                           │
│                                                                  │
│  TIER 3 - EXPERIMENTAL (<30% adoption)                          │
│  ├── Emergent: Self-organizing                                  │
│  ├── Swarm: Collective intelligence                             │
│  └── Magentic: Attraction-based coordination                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. SUPERVISOR PATTERN (Primary)

### 2.1 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUPERVISOR PATTERN                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      SUPERVISOR                           │   │
│  │  ├── Task Planning: Break work into sub-tasks            │   │
│  │  ├── Agent Selection: Choose best agent for task         │   │
│  │  ├── Work Assignment: Delegate to specialists            │   │
│  │  ├── Communication: Facilitate inter-agent               │   │
│  │  └── Result Aggregation: Combine outputs                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│              ┌───────────────┼───────────────┐                  │
│              ▼               ▼               ▼                  │
│  ┌───────────────┐ ┌───────────────┐ ┌───────────────┐         │
│  │   ANALYST     │ │   DEVELOPER   │ │    TESTER     │         │
│  │               │ │               │ │               │         │
│  │  Requirements │ │  Code         │ │  Validation   │         │
│  └───────────────┘ └───────────────┘ └───────────────┘         │
│                                                                  │
│  SOURCE: Microsoft Azure, AWS, Galileo AI                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Implementation (LangGraph)

```python
from langgraph.graph import StateGraph

def supervisor_node(state):
    """Route to appropriate agent based on task"""
    task_type = analyze_task(state["messages"][-1])

    if task_type == "analysis":
        return "analyst"
    elif task_type == "implementation":
        return "developer"
    elif task_type == "testing":
        return "tester"
    else:
        return "END"

# Build graph
graph = StateGraph(AgentState)
graph.add_node("supervisor", supervisor_node)
graph.add_node("analyst", analyst_agent)
graph.add_node("developer", developer_agent)
graph.add_node("tester", tester_agent)

# Add conditional edges
graph.add_conditional_edges("supervisor", route_task)
```

---

## 3. HIERARCHICAL PATTERN

### 3.1 Multi-Level Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                    HIERARCHICAL ORCHESTRATION                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  LEVEL 0: ORCHESTRATOR                                          │
│           └── Phase routing, global state                       │
│                              │                                  │
│        ┌─────────────────────┼─────────────────────┐            │
│        ▼                     ▼                     ▼            │
│  LEVEL 1: PHASE LEADS                                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │ DESIGN LEAD │    │ DEV LEAD    │    │ QA LEAD     │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│        │                   │                   │                │
│        ▼                   ▼                   ▼                │
│  LEVEL 2: SPECIALISTS                                           │
│  ┌─────┐ ┌─────┐  ┌─────┐ ┌─────┐  ┌─────┐ ┌─────┐             │
│  │Arch │ │ UX  │  │ Dev │ │ TEA │  │Luna │ │Sec  │             │
│  └─────┘ └─────┘  └─────┘ └─────┘  └─────┘ └─────┘             │
│                                                                  │
│  SOURCE: Skywork AI, AWS                                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Skywork Pattern (Validated)

```
Supervisor
    └──► Retriever(s) [parallel]
         └──► Researcher
              └──► Evidence Curator
                   └──► Writer
                        └──► Reviewer
```

---

## 4. PARALLEL GROUPS PATTERN

### 4.1 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    PARALLEL GROUPS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    SUPERVISOR                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│        ┌─────────────────────┼─────────────────────┐            │
│        ▼                     ▼                     ▼            │
│  ┌───────────────┐   ┌───────────────┐   ┌───────────────┐     │
│  │ COMPLIANCE    │   │ CODE QUALITY  │   │ SECURITY      │     │
│  │ GROUP         │   │ GROUP         │   │ GROUP         │     │
│  │               │   │               │   │               │     │
│  │ ┌─────┐┌────┐ │   │ ┌─────┐┌────┐ │   │ ┌─────┐┌────┐ │     │
│  │ │RGPD ││Legal│ │   │ │Lint ││Deps│ │   │ │Sec  ││Pen │ │     │
│  │ └─────┘└────┘ │   │ └─────┘└────┘ │   │ └─────┘└────┘ │     │
│  └───────────────┘   └───────────────┘   └───────────────┘     │
│                                                                  │
│  RULES:                                                         │
│  • Agents in same group run in PARALLEL                        │
│  • Groups are INDEPENDENT (no cross-dependencies)              │
│  • Each group has TIMEOUT                                       │
│  • Results AGGREGATED by supervisor                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Configuration

```yaml
parallel_groups:
  compliance_checks:
    agents: [rgpd-agent, legal-agent]
    parallel: true
    timeout: 300s
    fail_strategy: continue  # or abort

  code_quality_checks:
    agents: [lint-agent, dependency-agent]
    parallel: true
    timeout: 120s
    fail_strategy: continue

  security_validation:
    agents: [security-agent, pentest-agent]
    parallel: true
    timeout: 600s
    fail_strategy: abort  # Security failures are critical
```

---

## 5. HANDOFF PROTOCOL

### 5.1 Context Preservation

```
┌─────────────────────────────────────────────────────────────────┐
│                    HANDOFF PROTOCOL                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  PROBLEM: Agent transitions lose context                        │
│  SOLUTION: Structured handoff with context capsule              │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   HANDOFF CAPSULE                        │   │
│  │  ├── from_agent: "analyst"                               │   │
│  │  ├── to_agent: "architect"                               │   │
│  │  ├── summary: "Requirements validated for auth module"   │   │
│  │  ├── decisions: ["JWT auth", "Redis sessions"]           │   │
│  │  ├── open_questions: ["OAuth provider choice?"]          │   │
│  │  ├── artifacts: ["docs/PRD.md", "docs/requirements.md"]  │   │
│  │  └── next_action: "Design auth architecture"             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  SOURCE: Microsoft Azure, LangChain                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Implementation

```python
@dataclass
class HandoffCapsule:
    from_agent: str
    to_agent: str
    summary: str
    decisions: List[str]
    open_questions: List[str]
    artifacts: List[str]
    next_action: str
    context_tokens: int  # Track token usage

def create_handoff(from_agent: Agent, to_agent: str, state: AgentState) -> HandoffCapsule:
    """Create handoff capsule with compressed context"""
    return HandoffCapsule(
        from_agent=from_agent.name,
        to_agent=to_agent,
        summary=compress_summary(state.messages),
        decisions=extract_decisions(state.messages),
        open_questions=extract_questions(state.messages),
        artifacts=state.artifacts,
        next_action=determine_next_action(state)
    )
```

---

## 6. EVENT-DRIVEN ORCHESTRATION

### 6.1 Confluent Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                    EVENT-DRIVEN ORCHESTRATION                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    EVENT BUS (Kafka/SQS)                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│              ▲                   │                              │
│              │                   ▼                              │
│  ┌───────────────┐   ┌───────────────────────────────────┐     │
│  │   PRODUCER    │   │         CONSUMERS                  │     │
│  │   (Orchestr)  │   │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐  │     │
│  └───────────────┘   │  │ A1  │ │ A2  │ │ A3  │ │ A4  │  │     │
│                      │  └─────┘ └─────┘ └─────┘ └─────┘  │     │
│                      └───────────────────────────────────┘     │
│                                                                  │
│  PATTERNS (Confluent):                                          │
│  • Orchestrator-Worker: Central control                        │
│  • Recursive Hierarchical: Subtree orchestration               │
│  • Choreography: Decentralized                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Advantages

| Feature | Benefit |
|---------|---------|
| **Decoupling** | Agents don't know each other |
| **Scalability** | Add consumers as needed |
| **Fault Tolerance** | Dead letter queues |
| **Async** | Non-blocking operations |

---

## 7. HOAF (Harmony Orchestration Architecture Framework)

### 7.1 Complete Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOAF - HARMONY ORCHESTRATION                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     SUPERVISOR                           │   │
│  │  ├── Routing: Intelligent (34 agents)                   │   │
│  │  ├── Planning: Task decomposition                       │   │
│  │  └── Aggregation: Result synthesis                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                     WATCHDOG                             │   │
│  │  ├── Token Monitoring: Warn 60%, Block 80%              │   │
│  │  ├── Loop Detection: 3 retries max                      │   │
│  │  └── Timeout: 5-10 min max                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                              │                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   CIRCUIT BREAKER                        │   │
│  │  ├── Failure Tracking: Per agent                        │   │
│  │  ├── Strategies: Retry, Delegate, Abort                 │   │
│  │  └── Recovery: Auto-reset after cooldown                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  SOURCE: Netflix Hystrix, 12-Factor Agents                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 7.2 Circuit Breaker States

```
CLOSED ──(failures > threshold)──► OPEN
   ▲                                  │
   │                                  │
   └────(success)────  HALF-OPEN ◄───┘
                       (after cooldown)
```

---

## 8. PIPELINE ORCHESTRATION (3 Phases)

### 8.1 Harmony Pipeline

```yaml
phases:
  - name: design
    core_agents: [analyst, architect]
    conditional_agents:
      - agent: ux-designer
        if: has_ui
      - agent: game-designer
        if: is_game
      - agent: database-agent
        if: has_db_schema
    parallel_groups: [compliance_checks]

  - name: implementation
    core_agents: [dev, tea]
    conditional_agents:
      - agent: game-dev
        if: is_game
      - agent: mobile-dev
        if: is_mobile
    parallel_groups: [code_quality_checks]

  - name: validation
    core_agents: [review-agent]
    conditional_agents:
      - agent: security-agent
        if: security_critical
      - agent: performance-agent
        if: perf_requirements
      - agent: luna-qa-agent
        if: before_release
    parallel_groups: [security_validation]
```

---

## 9. DECISION MATRIX

### 9.1 Pattern Selection

| Use Case | Primary Pattern | Secondary |
|----------|-----------------|-----------|
| **Central control** | Supervisor | - |
| **Sequential workflow** | Sequential | Hierarchical |
| **Independent checks** | Parallel Groups | Concurrent |
| **Context-heavy transitions** | Handoff | Hierarchical |
| **High scale** | Event-Driven | Supervisor |
| **Self-organizing** | Swarm | Emergent |

### 9.2 Decision Checklist

```yaml
orchestration_decisions:
  - question: "Need central control?"
    if_yes: "Supervisor pattern"
    if_no: "Consider choreography"

  - question: "Tasks independent?"
    if_yes: "Parallel groups"
    if_no: "Sequential or hierarchical"

  - question: "Complex context transfer?"
    if_yes: "Handoff protocol"
    if_no: "Simple message passing"

  - question: "High failure risk?"
    if_yes: "Circuit breaker + watchdog"
    if_no: "Simple retry"

  - question: "Need to scale?"
    if_yes: "Event-driven + queue"
    if_no: "Direct invocation"
```

---

## 10. ANTI-PATTERNS

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **God Supervisor** | One agent does everything | Hierarchical delegation |
| **No Handoff** | Context lost at transitions | Handoff capsule |
| **Serial Everything** | Slow execution | Parallel groups |
| **No Watchdog** | Infinite loops, runaway costs | Token monitoring + timeouts |
| **No Circuit Breaker** | Cascading failures | Failure isolation |
| **Tight Coupling** | Hard to modify | Event-driven, interfaces |

---

## 11. HARMONY INTEGRATION

### 11.1 34 Agents Routing Table

```yaml
routing:
  analyst: ["requirements", "analysis", "research"]
  architect: ["design", "architecture", "patterns"]
  dev: ["implementation", "coding", "development"]
  tea: ["testing", "test", "tdd"]
  luna: ["exploratory", "qa", "release"]
  atlas: ["clean architecture", "layers", "dependencies"]
  security: ["security", "owasp", "vulnerabilities"]
  # ... 27 more agents
```

### 11.2 Metrics to Monitor

| Metric | Target | Alert |
|--------|--------|-------|
| **Agent latency** | <30s | >60s |
| **Token usage per task** | <10K | >50K |
| **Handoff success rate** | >95% | <90% |
| **Circuit breaker trips** | <1/hour | >5/hour |
| **Parallel group completion** | <5min | >10min |

---

**Orchestration Architect - Orchestration Architect**
*"The right agent at the right time in the right order."*
