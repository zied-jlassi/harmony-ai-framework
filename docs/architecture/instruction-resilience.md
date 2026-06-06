# Instruction Resilience Architecture

Harmony separates its critical instructions from the user-owned `CLAUDE.md` so that
framework protocols keep working even if `CLAUDE.md` is edited, truncated, or hit by a
merge conflict. This document explains the architecture and why it is designed this way.

> Decision record: this architecture is archived as an ADR in the internal `research/`
> folder. This page is the public, as-built description.

---

## Context

When Harmony is installed, it needs critical instructions to be reliably available:

- Agent announcement protocol (P-010)
- Guardian routing
- Sentinel error handling
- Security boundaries

Injecting all of this directly into `CLAUDE.md` is fragile:

1. **Fragility**: if the user edits `CLAUDE.md`, framework behavior can break
2. **Update conflicts**: framework updates may corrupt user content
3. **No fallback**: if the header is damaged, all protocol enforcement fails
4. **Merge conflicts**: git conflicts when multiple tools modify `CLAUDE.md`
5. **No protection**: instructions can be accidentally deleted

If the P-010 announcement protocol is not followed, it is usually because instructions in
`CLAUDE.md` were modified, truncated during an update, or not properly loaded.

---

## Architecture

Harmony adopts a **hierarchical, resilient instruction architecture**: a minimal pointer in
`CLAUDE.md`, with the real instructions living under `.harmony/`.

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

1. **CLAUDE.md safe to modify**: users can add their own content freely
2. **Updates don't conflict**: framework updates only touch `.harmony/`
3. **Fallback guaranteed**: instructions always available in `.harmony/`
4. **Multi-tool support**: works with Cursor, Codex, Copilot via AGENTS.md
5. **Version controlled**: instructions versioned with framework
6. **Checksum protected**: detect tampering or corruption

### Negative

1. **Extra file to load**: Claude must read `.harmony/INSTRUCTIONS.md`
2. **Migration needed**: existing installations need an update

### Neutral

1. **Hierarchical loading**: matches industry patterns (OpenAI, Anthropic)

---

## Sources

| Source | Pattern | Relevance |
|--------|---------|-----------|
| [Anthropic Blog](https://claude.com/blog/using-claude-md-files) | "Break up into separate files and reference them" | Direct recommendation |
| [Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices) | Hierarchical loading, `.local.md` variants | Best practice |
| [OpenAI Codex](https://github.com/letta-ai/agent-file) | `AGENTS.md` with fallback chain | Multi-tool compat |

---

## Related

- [P-010 Agent Announcement](../../patterns/P-010-agent-announcement.md)
- [Guardian Protocol](../../agents/guardian.md)
- [Installation Script](../../bin/install.sh)
