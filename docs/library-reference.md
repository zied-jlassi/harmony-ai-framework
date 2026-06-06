# Library Reference

> Complete reference for all Harmony Framework bash libraries.

---

## Overview

Harmony Framework includes powerful bash libraries that provide the core functionality. These libraries are designed for **JIT (Just-In-Time) loading** - only what's needed is loaded when needed.

| Library | File | Purpose |
|---------|------|---------|
| [ARIA Detector](#aria-detector) | `lib/aria-detector.sh` | Automatic intent and context detection |
| [Context Preloader](#context-preloader) | `lib/context-preloader.sh` | Safe context loading with state machine |
| [Sprint Tracker](#sprint-tracker) | `lib/sprint-tracker.sh` | Sprint, story, and pipeline management |
| [Cost Tracker](#cost-tracker) | `lib/cost-tracker.sh` | API cost tracking with multi-currency |
| [Config Loader](#config-loader) | `lib/config-loader.sh` | Configuration loading with lazy caching |
| [Assistant Toolkit](#assistant-toolkit) | `lib/assistant-toolkit.sh` | Unified toolkit orchestrator |

---

## ARIA Detector

> **A**utomatic **R**untime **I**ntent **A**nalyzer - Two-stage detection system.

**File:** `lib/aria-detector.sh`

### Two-Stage Detection

ARIA uses a two-stage detection system for maximum accuracy:

| Stage | Method | Speed | Accuracy |
|-------|--------|-------|----------|
| **Stage 1** | Pattern Matching | Instant (0ms) | 70-80% |
| **Stage 2** | LLM Enrichment | ~500ms | 95%+ |

### Context Flags

ARIA detects these context flags from user requests:

#### Compliance Flags (Priority 0-1: BLOCKING/HIGH)

| Flag | Detection Keywords | Triggered Agents |
|------|-------------------|------------------|
| `has_minors` | enfant, mineur, child, children, minor, school | rgpd, security, legal |
| `personal_data` | email, nom, adresse, phone, birthday, photo | rgpd, security |
| `security_critical` | paiement, payment, card, bank, encryption | security, pentest |
| `has_auth` | password, login, session, token, jwt, oauth | security, database |
| `legal_compliance` | cgu, cgv, terms, privacy, policy, gdpr, rgpd | legal, rgpd |

#### UI/UX Flags (Priority 2-3)

| Flag | Detection Keywords | Triggered Agents |
|------|-------------------|------------------|
| `has_ui` | form, button, modal, menu, component | ux-designer, accessibility |
| `has_db_schema` | database, table, schema, migration, orm | database, architect |
| `needs_infra` | docker, kubernetes, ci, cd, pipeline, aws | devops |
| `performance_critical` | optimization, benchmark, cache, latency | performance |

#### Project Type Flags

| Flag | Detection Keywords | Triggered Agents |
|------|-------------------|------------------|
| `is_web` | react, vue, angular, next, html, css | developer-web, designer-web |
| `is_mobile` | react-native, expo, flutter, ionic | developer-mobile, designer-mobile |
| `is_game` | phaser, unity, godot, sprite, physics | developer-gaming, architect-gaming |
| `is_api` | express, nestjs, rest, graphql, endpoint | developer-software, architect |

### Priority Levels

| Priority | Level | Meaning |
|----------|-------|---------|
| 0 | BLOCKING | Must validate before proceeding |
| 1 | HIGH | Requires validation |
| 2 | MEDIUM | Advisory |
| 3 | LOW | Informational |

### Key Functions

```bash
# Detect compliance flags from text
flags=$(aria_detect_compliance_flags "user request text")
# Returns: "has_auth personal_data"

# Detect UI/UX flags
ui_flags=$(aria_detect_ui_flags "create login form")
# Returns: "has_ui has_auth"

# Detect project type from package.json
project_flags=$(aria_detect_project_type "/path/to/project")
# Returns: "is_web is_api"

# Get triggered agents for flags
agents=$(aria_get_triggered_agents "has_auth personal_data")
# Returns: "security rgpd database"

# Check for blocking flags
if aria_has_blocking_flags "has_minors"; then
    echo "Blocking validation required!"
fi
```

---

## Context Preloader

> Loop-safe context loading with state machine guarantees.

**File:** `lib/context-preloader.sh`

### Safety Guarantees

| Guarantee | Implementation |
|-----------|----------------|
| No infinite loops | Forward-only state machine |
| No recursive calls | Depth guard (MAX_DEPTH=1) |
| No unbounded loading | Token budget (15,000 default) |
| Immutable after load | Context locked after injection |

### State Machine

```
IDLE → CLASSIFYING → RESOLVING → LOADING → INJECTING → LOCKED
```

States can only move **forward** - never backward. Once LOCKED, context cannot be modified.

### Multi-Provider LLM Support

Stage 2 detection supports multiple LLM providers (auto-detected from API keys):

| Provider | API Key Variable | Model Used |
|----------|-----------------|------------|
| Anthropic | `ANTHROPIC_API_KEY` | claude-3-haiku |
| OpenAI | `OPENAI_API_KEY` | gpt-4o-mini |
| Groq | `GROQ_API_KEY` | llama-3.1-8b-instant |
| Azure | `AZURE_OPENAI_API_KEY` | gpt-4o-mini |
| Mistral | `MISTRAL_API_KEY` | mistral-small |

### Key Functions

```bash
# Stage 1 only (instant pattern matching)
result=$(run_pattern_detection "user request" "/project/dir")
# Returns JSON: {"context_flags":[], "triggered_agents":[], "confidence":70}

# Full two-stage detection (pattern + LLM)
result=$(run_two_stage_detection "user request" "/project/dir")
# Returns JSON with enriched classification

# Main entry point (used by Guardian)
preload_context "$USER_REQUEST" "$SELECTED_AGENT"

# Check current state
state=$(get_preloader_state)  # → IDLE | CLASSIFYING | ... | LOCKED

# Get token usage
tokens=$(get_preloader_tokens)  # → number of tokens used

# Reset for testing
reset_preloader
```

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PRELOADER_MAX_TOKENS` | 15000 | Maximum tokens to preload |
| `PRELOADER_MAX_DEPTH` | 1 | Prevent recursive loading |
| `PRELOADER_CACHE_TTL` | 1800 | Cache TTL in seconds (30 min) |

---

## Sprint Tracker

> Complete sprint, story, and pipeline management with safety features.

**File:** `lib/sprint-tracker.sh`

### Core Functions

#### Sprint Operations

```bash
# Initialize working memory
init_working_memory "My Project"

# Start a sprint
start_sprint "SPRINT-001" "Sprint 1 - MVP" 30 "Sprint Goal"

# Complete sprint
complete_sprint

# Add axis to sprint
add_sprint_axis "A_Backend" "EPIC-001" 20 "Backend implementation"

# Update axis status
update_axis_status "A_Backend" "DONE"

# Add velocity
add_velocity 15
```

#### Story Operations

```bash
# Start a story
start_story "STORY-001" "User login" 5 "EPIC-001" "Developer"

# Complete story (adds points to velocity)
complete_story

# Update progress
update_story_progress 3 5  # 3 of 5 tasks done

# Update UCV status
update_ucv_status "APPROVED"  # PENDING | APPROVED | REJECTED
```

### Autopilot Pipeline

The `run_story_pipeline()` function orchestrates the full story lifecycle with ARIA integration:

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTOPILOT PIPELINE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. ARIA Detection → Identify compliance requirements            │
│                                                                  │
│  2. Dynamic Pipeline Build:                                      │
│     ├── [ARIA-triggered agents] (rgpd, security, legal...)     │
│     ├── developer                                               │
│     ├── tester                                                  │
│     ├── ucv-qa                                                  │
│     └── ucv-validator                                           │
│                                                                  │
│  3. Per-Phase Execution:                                         │
│     ├── Circuit Breaker Check                                   │
│     ├── API Budget Check                                        │
│     ├── Agent Invocation                                        │
│     ├── Completion Detection                                    │
│     └── Success/Failure Recording                               │
│                                                                  │
│  4. Story Completion or Escalation                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

```bash
# Run autopilot pipeline for a story
run_story_pipeline "STORY-001"

# Get pipeline status
get_pipeline_status "STORY-001"
```

### Circuit Breaker

Per-story circuit breaker with per-phase tracking:

| Limit | Value | Description |
|-------|-------|-------------|
| Max failures per story | 10 | Opens circuit breaker |
| Max failures per phase | 5 | Blocks phase |
| Max iterations | 10 | Prevents infinite loops |

**States:**

| State | Meaning | Action |
|-------|---------|--------|
| `CLOSED` | Normal operation | Allow operations |
| `OPEN` | Max failures reached | Block operations |
| `HALF_OPEN` | Testing recovery | Allow one test operation |

```bash
# Initialize circuit breaker for story
init_story_circuit_breaker "STORY-001"

# Check if operations allowed
if check_story_circuit_breaker "STORY-001" "developer"; then
    # Proceed with operation
fi

# Record failure (increments counter, may open circuit)
record_story_failure "STORY-001" "developer"

# Record success (resets phase counter)
record_story_success "STORY-001" "developer"

# Reset circuit breaker (after manual diagnosis)
reset_circuit_breaker "STORY-001" "Fixed root cause"
```

### Escalation System

When circuit breaker opens, automatic escalation triggers:

```bash
# Triggered automatically when circuit breaker opens
on_circuit_breaker_open "STORY-001" "developer" "Error details"
```

**Escalation Steps:**

1. **Record to Error Journal** - Sentinel auto-learning
2. **Mark Story** - Status = `NEEDS_ESCALATION`
3. **Show Similar Errors** - From MCP Memory
4. **Auto-Escalate** - Move to next story in sprint

### Completion Detection

Detects story completion from agent output:

```bash
# Returns: 0=COMPLETE, 1=IN_PROGRESS, 2=BLOCKED
detect_story_completion "STORY-001" "developer" "$agent_output"
```

**Completion Signals by Phase:**

| Phase | Complete Signals | Blocked Signals |
|-------|-----------------|-----------------|
| developer | "implementation complete", "code ready" | "blocked", "error", "failed" |
| tester | "all tests passing", "coverage 100%" | "test fail", "coverage gap" |
| ucv-validator | "Coverage: 100%", "all validated" | "gaps", "incomplete" |

### API Budget

Rate limiting to prevent runaway costs:

```bash
# Check if budget allows operations
if check_api_budget; then
    # Proceed
fi
```

| Limit | Default | Description |
|-------|---------|-------------|
| `api_calls_limit` | 10,000 | Max API calls per sprint |
| `warning_threshold` | 80% | Show warning at this usage |

### Sprint Health

Monitor sprint health:

```bash
get_sprint_health
# Returns: {"total": 10, "done": 3, "escalated": 2, "healthy": true}
```

---

## Cost Tracker

> API cost tracking with multi-currency support.

**File:** `lib/cost-tracker.sh`

### Model Pricing

Pricing per 1K tokens (January 2026):

| Model | Input | Output |
|-------|-------|--------|
| claude-sonnet-4 / sonnet | $0.003 | $0.015 |
| claude-opus-4 / opus | $0.015 | $0.075 |
| claude-haiku / haiku | $0.00025 | $0.00125 |

### Key Functions

```bash
# Initialize cost tracking
init_cost_tracking

# Track API usage
track_usage "sonnet" 1000 500 "developer"
# Args: model, input_tokens, output_tokens, agent

# Get session cost
cost=$(get_session_cost)  # → "0.0234"

# Get costs by agent
costs=$(get_agent_costs)  # → {"developer": 0.02, "tester": 0.01}

# Get specific agent cost
dev_cost=$(get_agent_cost "developer")
```

### Multi-Currency Support

```bash
# Get preferred currency from config
currency=$(get_preferred_currency)  # → "EUR" or "USD"

# Format cost with currency
formatted=$(format_cost 0.05 "EUR")  # → "0.0460 €"

# Format in both currencies
dual=$(format_cost_dual 0.05)  # → "$0.0500 (0.0460 €)"

# Get EUR exchange rate (cached daily)
rate=$(get_eur_rate)  # → "0.92"

# Convert USD to EUR
eur=$(usd_to_eur 1.00)  # → "0.92"
```

### Configuration

Set preferred currency in `.harmony/local/autopilot-config.json`:

```json
{
  "cost_tracking": {
    "currency": "EUR"
  }
}
```

Or in `.harmony/local/config/overrides.yaml`:

```yaml
cost_tracking:
  currency: EUR
```

---

## Config Loader

> Centralized configuration with lazy caching and backward compatibility.

**File:** `lib/config-loader.sh`

### Configuration Precedence

Files are loaded in order (last wins):

1. `framework/config/harmony.config.json` - Framework defaults
2. `.harmony/config/overrides.yaml` - Project overrides
3. `.harmony/local/config/overrides.yaml` - Local overrides (highest priority)

### Key Functions

```bash
# Load all configs (merges automatically)
load_config

# Get config value with fallback
docker_required=$(get_config "docker.required" "false")

# Get config array
patterns=$(get_config_array "rules_enforcer.add_dangerous_patterns")

# Check version compatibility
check_config_version
```

### Branch Cache (Lazy Loading)

O(1) lookup for agent/branch resolution with lazy loading:

```bash
# Resolve agent to branch file
branch_path=$(resolve_agent "developer-web")
# → "specialties/developer/branchs/web.md"

# Cache is built lazily - only loaded specialties are cached
```

### Version Utilities

```bash
# Compare semantic versions
if version_gte "1.2.0" "1.0.0"; then
    echo "Version is compatible"
fi
```

### Deprecation Warnings

The loader automatically warns about deprecated config keys:

```
⚠️  Deprecated: 'docker_required' → use 'docker.required' instead
```

| Deprecated Key | New Key |
|----------------|---------|
| `docker_required` | `docker.required` |
| `container_prefix` | `docker.container_prefix` |
| `guardian_mode` | `guardian.mode` |
| `sentinel_enabled` | `sentinel.enabled` |

### YAML Fallback Parser

When `yq` is not installed, a basic YAML parser handles simple configs:

- Supports nested objects up to 3 levels
- Handles strings, booleans, numbers
- **Limitations:** No arrays, no multiline strings

---

## Assistant Toolkit

> Unified orchestrator for all assistant modules.

**File:** `lib/assistant-toolkit.sh`

### Modules

| Module | Purpose |
|--------|---------|
| `model-manager` | Model aliases, tiers, cost estimation |
| `auto-linter` | Language detection, automatic linting |
| `repomap` | Repository structure analysis |
| `file-watcher` | File change detection and hooks |
| `history-summarizer` | Session history, context compression |

### Key Functions

```bash
# Initialize all modules
assistant_init "/path/to/project"

# Check status
assistant_status

# Run workflow on a file
assistant_workflow "src/app.ts" --fix

# Run workflow on changed files
assistant_workflow_changed --fix

# Generate AI context
assistant_context "/path/to/project"
```

### Module Loading

```bash
# Load single module
load_module "model-manager"

# Load all modules
load_all_modules

# Check if loaded
if is_module_loaded "auto-linter"; then
    run_lint_check "$file"
fi
```

---

## See Also

- [Architecture](architecture.md) - System architecture
- [Context Persistence](context-persistence.md) - Memory system
- [Assistant Toolkit](assistant-toolkit.md) - Toolkit details
- [MCP AutoLearning](mcp-autolearning.md) - Cross-session learning
