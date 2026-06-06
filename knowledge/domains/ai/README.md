# AI Specialist Sub-Agents

> **Specialized AI Architects for LLM/AI System Design**

---

## Overview

Six specialized sub-agents, each an expert in a specific domain of AI/LLM architecture. They can be invoked directly or through the AI Architect agent for delegation.

---

## Sub-Agent Roster

| Agent | Specialty | File |
|-------|-----------|------|
| **RAG Architect** | RAG Pipelines, Vector DBs, Embeddings, Chunking | [rag-patterns.md](rag-patterns.md) |
| **Memory Architect** | Memory Systems, Context Engineering, Cognitive Architecture | [memory-patterns.md](memory-patterns.md) |
| **Orchestration Architect** | Multi-Agent Orchestration, Supervisor, Handoff | [orchestration-patterns.md](orchestration-patterns.md) |
| **Observability Architect** | Observability, Tracing, Evaluation, Cost Monitoring | [observability-patterns.md](observability-patterns.md) |
| **GraphRAG Architect** | GraphRAG, Knowledge Graphs, Entity Extraction | [graphrag-patterns.md](graphrag-patterns.md) |
| **Safety Architect** | AI Safety, Guardrails, Hallucination Prevention | [safety-patterns.md](safety-patterns.md) |

---

## Delegation Matrix

Routing to the appropriate sub-agent based on topic:

| Topic | Sub-Agent |
|-------|-----------|
| Vector databases, embeddings | **RAG Architect** |
| Chunking strategies | **RAG Architect** |
| Re-ranking, retrieval | **RAG Architect** |
| Memory architecture | **Memory Architect** |
| Context window optimization | **Memory Architect** |
| Session/long-term memory | **Memory Architect** |
| Multi-agent patterns | **Orchestration Architect** |
| Agent handoff | **Orchestration Architect** |
| Supervisor design | **Orchestration Architect** |
| Tracing, logging | **Observability Architect** |
| Evaluation metrics | **Observability Architect** |
| Cost tracking | **Observability Architect** |
| Knowledge graphs | **GraphRAG Architect** |
| Entity extraction | **GraphRAG Architect** |
| Graph-based reasoning | **GraphRAG Architect** |
| Prompt injection defense | **Safety Architect** |
| Hallucination prevention | **Safety Architect** |
| Content filtering | **Safety Architect** |

---

## Invocation

Sub-agents can be invoked directly:

```
# Direct invocation
"/harmony:sub-agent:rag-architect what chunking strategy for legal documents?"
"/harmony:sub-agent:safety-architect review prompt injection defenses"
```

---

## Collaboration

Sub-agents can collaborate on complex systems:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUB-AGENT COLLABORATION                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Example: "Design a complete RAG system with safety"            │
│                                                                  │
│  Request received                                               │
│       │                                                         │
│       ├── RAG Architect: RAG pipeline design                    │
│       ├── Memory Architect: Memory for conversation context     │
│       ├── Safety Architect: Input/output guardrails             │
│       └── Observability Architect: Tracing and evaluation       │
│                                                                  │
│  Designs integrated                                             │
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
| **RAG Architect** | LangChain, LlamaIndex, Pinecone, Weaviate docs |
| **Memory Architect** | Mem0, Anthropic context engineering, Letta |
| **Orchestration Architect** | LangGraph, CrewAI, AutoGen, OpenAI Swarm |
| **Observability Architect** | LangSmith, Arize, Weights & Biases, OpenTelemetry |
| **GraphRAG Architect** | Neo4j, Microsoft GraphRAG, knowledge graph papers |
| **Safety Architect** | Anthropic safety, NeMo Guardrails, OWASP LLM |

---

## Best Practices

1. **Be specific** - "chunking for PDFs" vs "RAG help"
2. **Combine expertise** - Complex systems may need multiple sub-agents
3. **Review designs** - Sub-agents propose, you approve
4. **Self-contained** - Each sub-agent has its own knowledge base
