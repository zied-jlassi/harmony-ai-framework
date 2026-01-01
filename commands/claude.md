# Harmony Claude - Claude Code Compliance

> Validate Claude Code configuration compliance.

---

## What It Checks

| File | Validation |
|------|------------|
| `~/.claude.json` | MUST exist with mcpServers |
| `~/.claude/.mcp.json` | MUST NOT exist |
| `~/.claude/settings.json` | MUST NOT contain mcpServers |
| `.mcp.json` | No redefinition of global servers |
| `CLAUDE.md` | Correct file references |

---

## Checklist

```
[ ] ~/.claude.json exists with mcpServers
[ ] ~/.claude/.mcp.json does NOT exist
[ ] ~/.claude/settings.json without mcpServers
[ ] .mcp.json doesn't redefine global servers
[ ] CLAUDE.md references correct files
[ ] Hooks in .claude/hooks/ are executable
[ ] Rules in .claude/rules/ if present
```

---

## Compliance Score

| Category | Weight |
|----------|--------|
| MCP Config | 40% |
| Settings | 20% |
| Hooks | 15% |
| CLAUDE.md | 15% |
| Rules | 10% |

**Verdicts:**
- 95-100: Excellent - Optimal configuration
- 80-94: Good - Minor adjustments recommended
- 60-79: Acceptable - Corrections needed
- <60: Non-compliant - Immediate action required

---

## Usage

```bash
/harmony claude              # 12 - Validation Claude Code
/harmony claude --update     # 12u - MAJ regles conformite (GADER)
/harmony claude --fix        # Proposer corrections
```

---

## Update Mode (--update)

Uses GADER pattern (document-enrichment.md):
- **G**ARDER - Keep existing valid content
- **A**JOUTER - Add new sections
- **D**EMANDER - Ask for deletion approval
- **E**NRICHIR - Enrich existing sections
- **R**EFUSER - Refuse complete file Write

---

## See Also

- [Memory](memory.md) - MCP memory sync
- [Hooks](hooks.md) - Hook validation
