# Auto-Learning with MCP Memory

> **🌐 Language:** English · [Français](fr/mcp-autolearning.md)

> **Cross-session learning for the Sentinel System**

This document explains how Harmony uses `@modelcontextprotocol/server-memory` to persist and retrieve the errors learned by the Sentinel System.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         HARMONY AUTO-LEARNING                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Session 1: Erreur detectee                                              │
│  ┌───────────────────┐                                                   │
│  │ Sentinel          │                                                   │
│  │ detecte erreur    │                                                   │
│  └─────────┬─────────┘                                                   │
│            │                                                             │
│            ▼                                                             │
│  ┌───────────────────┐      ┌─────────────────────────────────────┐     │
│  │ error-journal.json│ ───▶ │ @modelcontextprotocol/server-memory │     │
│  │ (source verite)   │ sync │                                     │     │
│  │                   │      │  create_entities:                   │     │
│  │ {                 │      │    name: "ERR-002"                  │     │
│  │   "id": "ERR-002",│      │    type: "BashError"                │     │
│  │   "category":     │      │    observations:                    │     │
│  │     "bash",       │      │      - "set -e + ((++)) = exit"     │     │
│  │   "symptom": ...  │      │      - "Use $((var+1)) instead"     │     │
│  │ }                 │      │                                     │     │
│  └───────────────────┘      │  create_relations:                  │     │
│                             │    from: "ERR-002"                  │     │
│                             │    to: "P-011-bash-arithmetic"      │     │
│                             │    type: "caused_by"                │     │
│                             └─────────────────────────────────────┘     │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Session 2: Nouvelle session avec code bash                              │
│  ┌───────────────────┐                                                   │
│  │ Context Preloader │                                                   │
│  │ (Guardian Step 4) │                                                   │
│  └─────────┬─────────┘                                                   │
│            │                                                             │
│            ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────┐      │
│  │ search_nodes("bash arithmetic set-e")                         │      │
│  │                                                               │      │
│  │ Resultat:                                                     │      │
│  │ {                                                             │      │
│  │   "entities": [{                                              │      │
│  │     "name": "ERR-002",                                        │      │
│  │     "type": "BashError",                                      │      │
│  │     "observations": [                                         │      │
│  │       "((var++)) avec set -e cause exit code 1",              │      │
│  │       "Solution: var=$((var + 1))"                            │      │
│  │     ]                                                         │      │
│  │   }],                                                         │      │
│  │   "relations": [{                                             │      │
│  │     "from": "ERR-002",                                        │      │
│  │     "to": "P-011",                                            │      │
│  │     "type": "caused_by"                                       │      │
│  │   }]                                                          │      │
│  │ }                                                             │      │
│  └───────────────────────────────────────────────────────────────┘      │
│            │                                                             │
│            ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────┐      │
│  │ Agent PREVENU avant de faire la meme erreur                   │      │
│  │                                                               │      │
│  │ "Attention: Erreur connue ERR-002 - ((var++)) avec set -e"    │      │
│  │ "Solution: Utiliser var=$((var + 1))"                         │      │
│  └───────────────────────────────────────────────────────────────┘      │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Files Involved

### Source of Truth: `error-journal.json`

```json
{
  "version": "1.0",
  "errors": [
    {
      "id": "ERR-002",
      "date": "2026-01-02",
      "category": "bash-scripting",
      "severity": "critical",
      "title": "((expr++)) avec set -e cause exit inattendu",
      "symptom": "Script bash sort immediatement apres ((tip_num++))",
      "root_cause": "Avec set -e, ((0++)) retourne exit code 1",
      "correct_solution": "Utiliser var=$((var + 1))",
      "prevention_rule": "JAMAIS utiliser ((var++)) avec set -e",
      "related_pattern": "P-011",
      "tags": ["bash", "set-e", "arithmetic"]
    }
  ]
}
```

### Knowledge Graph: `server-memory`

Entities created:
- `ERR-002` (type: BashError)
- `P-011-bash-arithmetic` (type: Pattern)
- `install.sh` (type: Module)

Relations:
- `ERR-002` --caused_by--> `P-011-bash-arithmetic`
- `ERR-002` --occurred_in--> `install.sh`
- `P-011-bash-arithmetic` --prevents--> `ERR-002`

---

## MCP Memory Operations

### 1. Record an error (after Sentinel detection)

```javascript
// Creer l'entite erreur
mcp__memory__create_entities({
  entities: [{
    name: "ERR-002",
    entityType: "BashError",
    observations: [
      "((var++)) avec set -e cause exit code 1 car 0 est falsy",
      "Solution: Utiliser var=$((var + 1))",
      "Fichier: framework/bin/install.sh",
      "Severite: critical"
    ]
  }]
});

// Creer la relation avec le pattern
mcp__memory__create_relations({
  relations: [{
    from: "ERR-002",
    to: "P-011-bash-arithmetic",
    relationType: "caused_by"
  }]
});
```

### 2. Search relevant errors (Context Preloader)

```javascript
// Recherche semantique basee sur le contexte actuel
const results = mcp__memory__search_nodes({
  query: "bash arithmetic set-e scripting"
});

// Resultat: toutes les erreurs et patterns lies
// {
//   entities: [{ name: "ERR-002", ... }],
//   relations: [{ from: "ERR-002", to: "P-011", ... }]
// }
```

### 3. Add observations (enrichment)

```javascript
// Si l'erreur se reproduit, ajouter des observations
mcp__memory__add_observations({
  observations: [{
    entityName: "ERR-002",
    contents: [
      "Recurrence: 2026-01-10 dans file-watcher.sh",
      "Meme pattern, contexte different"
    ]
  }]
});
```

---

## Integration with Sentinel

### Complete Workflow

1. **Detection** (Sentinel agent)
   - Detects an error via pattern matching or analysis
   - Records it in `error-journal.json`

2. **MCP Sync** (new)
   - Creates an entity in server-memory
   - Creates relations with existing patterns
   - Automatic semantic indexing

3. **Retrieval** (Context Preloader)
   - At session startup
   - Semantic search based on open files / context
   - Injection of relevant errors into the LLM context

4. **Prevention** (Agent)
   - The agent sees past errors BEFORE coding
   - Avoids reproducing the same errors

---

## Configuration

### MCP Client (required)

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### Environment variables

```bash
# Chemin du knowledge graph (defaut: ~/.harmony/memory-graph)
HARMONY_MEMORY_PATH=~/.harmony/memory-graph

# Activer sync automatique (defaut: true)
HARMONY_MEMORY_SYNC=true
```

---

## Advantages vs Previous Approach

| Aspect | Before (session-only) | After (MCP memory) |
|--------|---------------------|-------------------|
| **Persistence** | Single session | Cross-session |
| **Search** | grep/pattern | Semantic |
| **Relations** | None | Full graph |
| **Context** | Manual | Automatic |
| **Prevention** | Reactive | Proactive |

---

## Sentinel Commands

```bash
# Voir erreurs en memoire
/harmony sentinel --status

# Apprendre une erreur manuellement
/harmony sentinel --learn "ERR-XXX"

# Voir patterns appris
/harmony sentinel --patterns

# Sync vers MCP memory
/harmony sentinel --sync
```

---

## Troubleshooting

### MCP memory unavailable

```bash
# Verifier que le serveur repond
npx -y @modelcontextprotocol/server-memory --help

# Verifier la configuration Claude Desktop
cat ~/.config/claude-desktop/config.json | jq '.mcpServers.memory'
```

### Errors not found

```bash
# Verifier le contenu du graphe
# (via MCP Inspector ou directement)
mcp__memory__read_graph()

# Re-sync depuis error-journal.json
/harmony sentinel --sync --force
```

---

## References

- [server-memory documentation](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
- [Sentinel Agent](../agents/sentinel.md)
- [Pattern P-016: Error Journal](../patterns/P-016-error-journal.md)
