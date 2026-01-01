# Nova's Sub-Agents

> **Specialized AI Architects under Nova's Leadership**

---

## Overview

Nova leads a team of six specialized sub-agents, each an expert in a specific domain of AI/LLM architecture. When Nova encounters a specialized request, she delegates to the appropriate sub-agent.

---

## Sub-Agent Roster

| Agent | Persona | Specialty | File |
|-------|---------|-----------|------|
| **Riley** | Riley | RAG Pipelines, Vector DBs, Embeddings, Chunking | [riley.md](riley.md) |
| **Milo** | Milo | Memory Systems, Context Engineering, Cognitive Architecture | [milo.md](milo.md) |
| **Oscar** | Oscar | Multi-Agent Orchestration, Supervisor, Handoff | [oscar.md](oscar.md) |
| **Olivia** | Olivia | Observability, Tracing, Evaluation, Cost Monitoring | [olivia.md](olivia.md) |
| **Grace** | Grace | GraphRAG, Knowledge Graphs, Entity Extraction | [grace.md](grace.md) |
| **Sage** | Sage | AI Safety, Guardrails, Hallucination Prevention | [sage.md](sage.md) |

---

## Delegation Matrix

When Nova receives a request, she routes to the appropriate sub-agent:

| Topic | Sub-Agent |
|-------|-----------|
| Vector databases, embeddings | **Riley** |
| Chunking strategies | **Riley** |
| Re-ranking, retrieval | **Riley** |
| Memory architecture | **Milo** |
| Context window optimization | **Milo** |
| Session/long-term memory | **Milo** |
| Multi-agent patterns | **Oscar** |
| Agent handoff | **Oscar** |
| Supervisor design | **Oscar** |
| Tracing, logging | **Olivia** |
| Evaluation metrics | **Olivia** |
| Cost tracking | **Olivia** |
| Knowledge graphs | **Grace** |
| Entity extraction | **Grace** |
| Graph-based reasoning | **Grace** |
| Prompt injection defense | **Sage** |
| Hallucination prevention | **Sage** |
| Content filtering | **Sage** |

---

## Invocation

Sub-agents can be invoked directly or through Nova:

```
# Through Nova (recommended)
"Nova, design the RAG pipeline"
  → Nova delegates to Riley

# Direct invocation
"Riley, what chunking strategy for legal documents?"
```

---

## Collaboration

Sub-agents often collaborate:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUB-AGENT COLLABORATION                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Example: "Design a complete RAG system with safety"            │
│                                                                  │
│  Nova receives request                                          │
│       │                                                         │
│       ├── Riley: RAG pipeline design                            │
│       ├── Milo: Memory for conversation context                 │
│       ├── Sage: Input/output guardrails                         │
│       └── Olivia: Tracing and evaluation                        │
│                                                                  │
│  Nova integrates all designs                                    │
│       │                                                         │
│       └── Final architecture document                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Knowledge Sources

Each sub-agent is trained on extensive documentation:

| Agent | Key Knowledge Sources |
|-------|----------------------|
| **Riley** | LangChain, LlamaIndex, Pinecone, Weaviate docs |
| **Milo** | Mem0, Anthropic context engineering, Letta |
| **Oscar** | LangGraph, CrewAI, AutoGen, OpenAI Swarm |
| **Olivia** | LangSmith, Arize, Weights & Biases, OpenTelemetry |
| **Grace** | Neo4j, Microsoft GraphRAG, knowledge graph papers |
| **Sage** | Anthropic safety, NeMo Guardrails, OWASP LLM |

---

## Best Practices

1. **Let Nova route** - She knows which sub-agent to call
2. **Be specific** - "chunking for PDFs" vs "RAG help"
3. **Combine expertise** - Complex systems need multiple agents
4. **Review designs** - Sub-agents propose, you approve

