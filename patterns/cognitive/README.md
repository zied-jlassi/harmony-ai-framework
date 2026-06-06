# Cognitive Modules

> Reasoning patterns for Harmony Framework agents

---

## Overview

Cognitive modules provide structured reasoning patterns that agents use to solve complex problems. Each module implements a specific cognitive strategy.

---

## Available Modules

| Module | Description | Use Case |
|--------|-------------|----------|
| **ReAct** | Reasoning + Acting loop | General task execution |
| **Reflection** | Self-evaluation patterns | Quality improvement |
| **Self-Consistency** | Multi-path reasoning | Complex decisions |
| **LATS** | Language Agent Tree Search | Exploration tasks |
| **Graph-of-Thoughts** | Graph-based reasoning | Multi-step problems |

---

## Module Files

```
cognitive/
├── README.md           # This file
├── react.md            # ReAct (Reasoning + Acting)
├── reflection.md       # Self-reflection patterns
├── self-consistency.md # Multi-path reasoning
├── lats.md             # Language Agent Tree Search
└── graph-of-thoughts.md # Graph-based reasoning
```

---

## Usage

Agents reference cognitive modules to enhance their reasoning:

```
Agent uses: ReAct + Reflection

THOUGHT → ACTION → OBSERVATION → REFLECT → REPEAT
```

---

## References

- [ReAct Paper](https://arxiv.org/abs/2210.03629)
- [Reflexion Paper](https://arxiv.org/abs/2303.11366)
- [Self-Consistency Paper](https://arxiv.org/abs/2203.11171)
- [Tree of Thoughts Paper](https://arxiv.org/abs/2305.10601)
- [Graph of Thoughts Paper](https://arxiv.org/abs/2308.09687)

---

*Based on Harmony Framework (MIT License) - Adapted for Harmony Framework*
