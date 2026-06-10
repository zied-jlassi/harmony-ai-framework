# Harmony Commands Reference

> **🌐 Language:** English · [Français](fr/commands.md)

> Complete reference for all 35 Harmony commands.

---

## Quick Reference

```bash
/go                    # Session kickoff
/harmony               # Interactive menu
```

---

## Commands by Category

### Validation Framework (1-5)

| Command | Description |
|---------|-------------|
| `/harmony full` | Full audit (~2-5 min) |
| `/harmony quick` | Quick check (~30s) |
| `/harmony duplicates` | Duplicate detection |
| `/harmony fix` | Propose fixes |
| `/harmony fix --apply` | Apply with confirmation |
| `/harmony watch` | Pre-commit hook |
| `/harmony watch --install` | Install hook |
| `/harmony watch --status` | Hook status |

### Reports (6-7)

| Command | Description |
|---------|-------------|
| `/harmony report` | Coherence matrix |
| `/harmony report --verbose` | Details by category |
| `/harmony tokens` | Token cost per agent |
| `/harmony tokens --breakdown` | Details per agent |
| `/harmony tokens --optimize` | Optimization suggestions |

### Specific Validation (8-10)

| Command | Description |
|---------|-------------|
| `/harmony pipeline` | Pipeline config vs docs coherence |
| `/harmony pipeline --verbose` | Full details |
| `/harmony pipeline --fix` | Propose fixes |
| `/harmony hooks` | Claude hooks validation |
| `/harmony hooks --install` | Install default hooks |
| `/harmony hooks --status` | Hooks status |
| `/harmony patterns` | Patterns validation |
| `/harmony patterns --fix` | Propose fixes |

### Synchronization (11-12)

| Command | Description |
|---------|-------------|
| `/harmony memory` | Sync MCP <-> CLAUDE.md |
| `/harmony memory --diff` | Show differences |
| `/harmony claude` | Claude Code config validation |
| `/harmony claude --update` | Update rules (GADER pattern) |
| `/harmony claude --fix` | Propose fixes |

### Rules Enforcement (13-15)

| Command | Description |
|---------|-------------|
| `/harmony rules` | Rules audit |
| `/harmony rules --usage` | Usage in the code |
| `/harmony rules --report` | Compliance report |

### Harmony Sentinel (16-20)

| Command | Description |
|---------|-------------|
| `/harmony sentinel` | Health dashboard (default) |
| `/harmony sentinel --status` | Alias for status |
| `/harmony sentinel --learn` | Document an error |
| `/harmony sentinel --reset` | Reset the Circuit Breaker |
| `/harmony sentinel --check` | Full verification |
| `/harmony sentinel --report` | Detailed report |

### Knowledge & Profiles (21-23)

| Command | Description |
|---------|-------------|
| `/harmony learn <url>` | Learn from a URL |
| `/harmony profiles` | List profiles |
| `/harmony profiles --active` | Show active |
| `/harmony profiles --add <name>` | Activate a profile |
| `/harmony profiles --remove <name>` | Deactivate a profile |
| `/harmony specialties` | List specialties |
| `/harmony specialties --active` | Show active |
| `/harmony specialties --add <name>` | Activate a specialty |
| `/harmony specialties --remove <name>` | Deactivate a specialty |

### Integrations (24-25)

| Command | Description |
|---------|-------------|
| `/harmony install <ide>` | Deploy to an IDE |
| `/harmony install --status` | Show integrations |

### HQVF Quality (26-27)

| Command | Description |
|---------|-------------|
| `/harmony ucv <story>` | Create UCVs |
| `/harmony ucv --validate <story>` | Verify coverage |

### Framework (28-30)

| Command | Description |
|---------|-------------|
| `/harmony init` | Initialize Harmony |
| `/harmony upgrade` | Update the framework |
| `/harmony upgrade --check` | Check for updates |
| `/harmony export` | Export configuration |
| `/harmony export --full` | Full export with memory |

### Session & Config (31-35)

| Command | Description |
|---------|-------------|
| `/harmony go` | Session kickoff - initializes context |
| `/harmony config` | **Natural-language configuration** |
| `/harmony config show` | Show current config |
| `/harmony config reset` | Reset config |
| `/harmony coverage` | UCV coverage report |
| `/harmony coverage <epic>` | Coverage for an Epic |
| `/harmony matrix` | Generate a requirements spec |
| `/harmony matrix <epic>` | Requirements spec for an Epic |
| `/harmony test-book` | Generate a test book |
| `/harmony test-book <epic>` | Test book for an Epic |

> **New**: `/harmony config` lets you configure Harmony in **natural language**.
> See [Natural Language Config](natural-language-config.md) for details.

---

## Examples

### Daily Workflow

```bash
# Start session
/go

# Quick check before commit
/harmony quick

# Full audit before PR
/harmony full
```

### Error Management

```bash
# View error dashboard
/harmony sentinel

# Document a resolved error
/harmony sentinel --learn

# Reset circuit breaker after diagnosis
/harmony sentinel --reset
```

### Quality Verification

```bash
# Create UCVs for a story
/harmony ucv STORY-042

# Validate coverage
/harmony ucv --validate STORY-042
```

### Natural-Language Configuration

```bash
# Open the config assistant
/harmony config

# Example phrases:
"Block DROP DATABASE on production"
"Docker required with prefix myapp"
"5 max failures before circuit breaker"
"Disable the pentest agent"
```

> See [Natural Language Config](natural-language-config.md) for more examples.
