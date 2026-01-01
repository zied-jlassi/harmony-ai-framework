# Harmony Memory - Sync MCP Memory

> Synchronize rules between MCP memory and CLAUDE.md.

---

## What It Does

| Source | Role |
|--------|------|
| **CLAUDE.md** | Source of truth (versioned in Git) |
| **MCP Memory** | Fast cache (can be corrupted/lost) |

---

## Phases

### Phase 1: Read (read-only)

- Scan CLAUDE.md for sections with "(OBLIGATOIRE)"
- Read MCP memory entities (Configuration/Rule/AgentRule)
- Build correspondence table

### Phase 2: Compare (display only)

| Status | Description |
|--------|-------------|
| [SYNC] | Present in both, content coherent |
| [MISSING_MCP] | In CLAUDE.md, absent from MCP |
| [MISSING_DOC] | In MCP, absent from CLAUDE.md |
| [CONFLICT] | Present but different content |

### Phase 3: Propose (requires approval)

For each anomaly:
- Option A: Create MCP entity from CLAUDE.md
- Option B: Add rule to CLAUDE.md from MCP
- Option C: Delete orphan MCP entity
- Option D: Resolve conflict (choose version)

---

## Output

```
HARMONY MEMORY SYNC
───────────────────

Phase 1: Reading sources...
Phase 2: Comparing...

| Rule                | CLAUDE.md | MCP Memory | Status |
|---------------------|-----------|------------|--------|
| DockerRules         | L.198     | EntityType | SYNC   |
| BraveSearchRules    | L.200     | EntityType | SYNC   |
| SearchResourcePattern| L.246    | -          | MISSING_MCP |

Phase 3: Proposing actions...
```

---

## Usage

```bash
/harmony memory              # 11 - Sync MCP <-> CLAUDE.md
/harmony memory --diff       # Afficher differences
```

---

## See Also

- [Claude](claude.md) - Claude Code validation
- [Sentinel](sentinel.md) - Error memory
