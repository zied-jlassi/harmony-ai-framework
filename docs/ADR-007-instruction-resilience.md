# ADR-007: Instruction Resilience Architecture

> **Status**: Accepted
> **Date**: 2026-01-18
> **Deciders**: Framework Team

---

## Context

### The Problem

When Harmony Framework is installed, it injects a header section into `CLAUDE.md` containing critical instructions for:
- Agent announcement protocol (P-010)
- Guardian routing
- Sentinel error handling
- Security boundaries

**However, this approach has critical flaws:**

1. **Fragility**: If the user modifies `CLAUDE.md`, framework behavior breaks
2. **Update conflicts**: Framework updates may corrupt user content
3. **No fallback**: If header is damaged, all protocol enforcement fails
4. **Merge conflicts**: Git conflicts when multiple tools modify `CLAUDE.md`
5. **No protection**: Instructions can be accidentally deleted

### Evidence of the Problem

```
User observation:
"c'est l'architect qui travaille?"
"Oui, je travaille en mode Architect pour créer les ADRs"
"il y a eu un handoff?"
"Non, pas de handoff formel"

Expected behavior (P-010):
● 🏗️ Architect Agent : Je suis l'Architect, expert en conception...
[Then work begins]

Actual behavior:
Claude casually claims "mode Architect" without formal announcement
```

The P-010 Agent Announcement protocol was not followed because instructions in `CLAUDE.md` may have been:
- Modified by user
- Truncated during update
- Not properly loaded

---

## Decision

### Separate Instructions from CLAUDE.md

Adopt a **hierarchical, resilient instruction architecture**:

```
BEFORE (Fragile):
┌─────────────────────────────────────┐
│ CLAUDE.md                           │
│ ├── Harmony header (50+ lines)     │◄── Can be corrupted
│ ├── Framework instructions         │◄── Can be modified
│ └── User content                   │
└─────────────────────────────────────┘

AFTER (Resilient):
┌─────────────────────────────────────┐
│ CLAUDE.md (minimal - 10 lines)      │
│ └── Pointer to .harmony/            │◄── Safe to modify
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ .harmony/INSTRUCTIONS.md            │
│ ├── P-010 Agent Announcement       │◄── Protected
│ ├── Guardian Protocol              │◄── Checksummed
│ ├── Sentinel Rules                 │◄── Versioned
│ └── All critical instructions      │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ .harmony/AGENTS.md (optional)       │
│ └── OpenAI Codex / Cursor compat   │◄── Multi-tool
└─────────────────────────────────────┘
```

---

## Implementation

### 1. Minimal CLAUDE.md Header

```markdown
## 🛡️ HARMONY FRAMEWORK

> **IMPORTANT**: Read `.harmony/INSTRUCTIONS.md` for all framework protocols.
> **CONFIG**: `HARMONY_DIR=.harmony`
> **READ-ONLY**: This section is auto-generated. Run `/harmony init` to repair.
```

### 2. Full Instructions in .harmony/INSTRUCTIONS.md

Contains all critical protocols:
- P-010 Agent Announcement (MANDATORY)
- Guardian Protocol (intent detection, routing)
- Sentinel System (error memory, circuit breaker)
- HQVF Quality Gates
- Security boundaries
- Agent greeting formats

### 3. AGENTS.md for Multi-Tool Compatibility

```markdown
# AGENTS.md - Harmony Framework

Compatible with: OpenAI Codex, Cursor, GitHub Copilot, JetBrains AI

[Same instructions as INSTRUCTIONS.md]
```

### 4. Checksum Protection

```bash
# .harmony/checksums.sha256
sha256sum INSTRUCTIONS.md AGENTS.md > checksums.sha256
```

### 5. Self-Repair Mechanism

```bash
# /harmony init --repair
# Regenerates INSTRUCTIONS.md from framework source
# Restores CLAUDE.md header if corrupted
```

---

## Consequences

### Positive

1. **CLAUDE.md safe to modify**: Users can add their own content freely
2. **Updates don't conflict**: Framework updates only touch `.harmony/`
3. **Fallback guaranteed**: Instructions always available in `.harmony/`
4. **Multi-tool support**: Works with Cursor, Codex, Copilot via AGENTS.md
5. **Version controlled**: Instructions versioned with framework
6. **Checksum protected**: Detect tampering or corruption

### Negative

1. **Extra file to load**: Claude must read `.harmony/INSTRUCTIONS.md`
2. **Migration needed**: Existing installations need update

### Neutral

1. **Hierarchical loading**: Matches industry patterns (OpenAI, Anthropic)

---

## Research Sources

| Source | Pattern | Relevance |
|--------|---------|-----------|
| [Anthropic Blog](https://claude.com/blog/using-claude-md-files) | "Break up into separate files and reference them" | Direct recommendation |
| [Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices) | Hierarchical loading, `.local.md` variants | Best practice |
| [OpenAI Codex](https://github.com/letta-ai/agent-file) | `AGENTS.md` with fallback chain | Multi-tool compat |
| [0xdevalias Gist](https://gist.github.com/0xdevalias/f40bc5a6f84c4c5ad862e314894b2fa6) | AI agent rule files patterns | Industry survey |

---

## Related

- [P-010 Agent Announcement](../patterns/P-010-agent-announcement.md)
- [Guardian Protocol](../agents/guardian.md)
- [Installation Script](../bin/install.sh)
