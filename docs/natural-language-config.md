# Natural Language Configuration

> **🌐 Language:** English · [Français](fr/natural-language-config.md)

> **Command**: `/harmony config`

Configure Harmony by talking normally, without editing YAML files.

---

## Principle

```
You say                             →  Harmony generates
────────────────────────────────────────────────────────────────
"Block DROP DATABASE"               →  rules_enforcer.add_dangerous_patterns
"Use Docker"                        →  docker.required: true
"Disable the circuit breaker"       →  sentinel.circuit_breaker.enabled: false
```

---

## Usage examples

### Security & Rules

```
"I want to block DROP DATABASE on my production database"
```
```yaml
# Result in .harmony/local/config/overrides.yaml
rules_enforcer:
  add_dangerous_patterns:
    - 'DROP DATABASE.*production'
```

```
"Block rm -rf on the /data folder"
```
```yaml
rules_enforcer:
  add_dangerous_patterns:
    - 'rm -rf.*/data'
```

```
"Add a warning for sudo commands"
```
```yaml
rules_enforcer:
  add_warning_patterns:
    - 'sudo'
```

---

### Docker

```
"My project uses Docker with the prefix myapp"
```
```yaml
docker:
  required: true
  container_prefix: "myapp"
```

```
"Disable Docker for this project"
```
```yaml
docker:
  required: false
```

---

### Guardian (Story checking)

```
"Disable story checking for the scripts/ folder"
```
```yaml
guardian:
  add_allowed_directories:
    - "scripts/"
```

```
"Exclude .test.ts files from checking"
```
```yaml
guardian:
  add_allowed_extensions:
    - ".test.ts"
```

```
"Switch Guardian to block mode"
```
```yaml
guardian:
  mode: "block"  # instead of "warn"
```

```
"Disable Guardian completely"
```
```yaml
guardian:
  enabled: false
```

---

### Sentinel (Circuit Breaker)

```
"5 maximum failures before circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    max_failures: 5
```

```
"10 minutes cooldown after circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    cooldown_minutes: 10
```

```
"Disable the circuit breaker"
```
```yaml
sentinel:
  circuit_breaker:
    enabled: false
```

---

### Agents

```
"Disable the pentest agent"
```
```yaml
agents:
  disabled:
    - "pentest"
```

```
"Alias qa for exploratory-qa"
```
```yaml
agents:
  aliases:
    qa: "exploratory-qa"
```

```
"Alias luna for the tester agent"
```
```yaml
agents:
  aliases:
    luna: "tester"
```

---

### Project

```
"The project is called MyApp"
```
```yaml
project:
  name: "MyApp"
```

```
"I prefer responses in French"
```
```yaml
project:
  language: "fr"
```

---

## Complete Mapping

| You say | YAML key | Value |
|---------|----------|-------|
| "block X" | `rules_enforcer.add_dangerous_patterns` | `["X"]` |
| "warning for X" | `rules_enforcer.add_warning_patterns` | `["X"]` |
| "allow X" | `rules_enforcer.add_allowed_patterns` | `["X"]` |
| "Docker required" | `docker.required` | `true` |
| "prefix X" | `docker.container_prefix` | `"X"` |
| "disable Guardian" | `guardian.enabled` | `false` |
| "block mode" | `guardian.mode` | `"block"` |
| "exclude folder X" | `guardian.add_allowed_directories` | `["X"]` |
| "exclude extension X" | `guardian.add_allowed_extensions` | `["X"]` |
| "X max failures" | `sentinel.circuit_breaker.max_failures` | `X` |
| "X minutes cooldown" | `sentinel.circuit_breaker.cooldown_minutes` | `X` |
| "disable agent X" | `agents.disabled` | `["X"]` |
| "alias X = Y" | `agents.aliases` | `{ "X": "Y" }` |
| "project is called X" | `project.name` | `"X"` |
| "language X" | `project.language` | `"X"` |

---

## Special Commands

| Command | Action |
|---------|--------|
| `/harmony config show` | Show the current config |
| `/harmony config reset` | Reset (with backup) |
| `/harmony config lang fr` | Change the language |
| `/harmony config help` | Show help |

---

## Generated File

All user configurations are saved in:

```
.harmony/local/config/overrides.yaml
```

This file is:
- **Local** to your machine (in `.harmony/local/`)
- **Preserved** across framework updates
- **Ignored by git** (personal data)
- **Merged** with the default values

> **Note**: The `.harmony/local/` folder contains all your personal data and is never versioned.

---

## Language Detection

The command answers in your language:

```
You: "Bloquer les suppressions de base"
Harmony: ✅ Configuration mise à jour !

You: "Block database deletions"
Harmony: ✅ Configuration updated!
```

---

## Full Session Example

```
You: /harmony config

Harmony: 👋 Hello! I'm the Harmony configuration assistant.
         Describe what you want to configure in natural language.

You: I want Docker to be required with the prefix "webapp",
     and block any DROP command on prod.

Harmony: 📝 I understood that you want:
         - Docker required with prefix "webapp"
         - Block DROP commands on production

         Is that right?

You: Yes

Harmony: ✅ Configuration updated!

         File: .harmony/local/config/overrides.yaml

         docker:
           required: true
           container_prefix: "webapp"

         rules_enforcer:
           add_dangerous_patterns:
             - 'DROP.*prod'
```

---

## See Also

- [Configuration Reference](overrides.md) - Detailed YAML format
- [Commands Reference](commands.md) - All commands
- [Guardian Protocol](../agents/guardian.md) - Story checking
- [Sentinel System](../agents/sentinel.md) - Circuit breaker
