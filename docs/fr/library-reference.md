# Library Reference

> **🌐 Langue :** [English](../library-reference.md) · Français

> Référence complète de toutes les bibliothèques bash du Harmony Framework.

---

## Vue d'ensemble

Le Harmony Framework inclut de puissantes bibliothèques bash qui fournissent les fonctionnalités fondamentales. Ces bibliothèques sont conçues pour un **chargement JIT (Just-In-Time)** : seul ce qui est nécessaire est chargé, au moment où c'est nécessaire.

| Bibliothèque | Fichier | Rôle |
|---------|------|---------|
| [ARIA Detector](#aria-detector) | `lib/aria-detector.sh` | Détection automatique d'intention et de contexte |
| [Context Preloader](#context-preloader) | `lib/context-preloader.sh` | Chargement de contexte sûr avec machine à états |
| [Sprint Tracker](#sprint-tracker) | `lib/sprint-tracker.sh` | Gestion des sprints, stories et pipelines |
| [Config Loader](#config-loader) | `lib/config-loader.sh` | Chargement de configuration avec cache paresseux |
| [Assistant Toolkit](#assistant-toolkit) | `lib/assistant-toolkit.sh` | Orchestrateur de toolkit unifié |

---

## ARIA Detector

> **A**utomatic **R**untime **I**ntent **A**nalyzer - Système de détection à deux étages.

**File:** `lib/aria-detector.sh`

### Détection à deux étages

ARIA utilise un système de détection à deux étages pour une précision maximale :

| Étage | Méthode | Vitesse | Précision |
|-------|--------|-------|----------|
| **Stage 1** | Pattern Matching | Instantané (0 ms) | 70-80 % |
| **Stage 2** | LLM Enrichment | ~500 ms | 95 %+ |

### Drapeaux de contexte (context flags)

ARIA détecte ces drapeaux de contexte à partir des requêtes utilisateur :

#### Drapeaux de conformité (Priorité 0-1 : BLOCKING/HIGH)

| Flag | Mots-clés de détection | Agents déclenchés |
|------|-------------------|------------------|
| `has_minors` | enfant, mineur, child, children, minor, school | rgpd, security, legal |
| `personal_data` | email, nom, adresse, phone, birthday, photo | rgpd, security |
| `security_critical` | paiement, payment, card, bank, encryption | security, pentest |
| `has_auth` | password, login, session, token, jwt, oauth | security, database |
| `legal_compliance` | cgu, cgv, terms, privacy, policy, gdpr, rgpd | legal, rgpd |

#### Drapeaux UI/UX (Priorité 2-3)

| Flag | Mots-clés de détection | Agents déclenchés |
|------|-------------------|------------------|
| `has_ui` | form, button, modal, menu, component | ux-designer, accessibility |
| `has_db_schema` | database, table, schema, migration, orm | database, architect |
| `needs_infra` | docker, kubernetes, ci, cd, pipeline, aws | devops |
| `performance_critical` | optimization, benchmark, cache, latency | performance |

#### Drapeaux de type de projet

| Flag | Mots-clés de détection | Agents déclenchés |
|------|-------------------|------------------|
| `is_web` | react, vue, angular, next, html, css | developer-web, designer-web |
| `is_mobile` | react-native, expo, flutter, ionic | developer-mobile, designer-mobile |
| `is_game` | phaser, unity, godot, sprite, physics | developer-gaming, architect-gaming |
| `is_api` | express, nestjs, rest, graphql, endpoint | developer-software, architect |

### Niveaux de priorité

| Priorité | Niveau | Signification |
|----------|-------|---------|
| 0 | BLOCKING | Doit être validé avant de continuer |
| 1 | HIGH | Nécessite une validation |
| 2 | MEDIUM | Indicatif |
| 3 | LOW | Informatif |

### Fonctions clés

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

> Chargement de contexte sûr en boucle, avec garanties de machine à états.

**File:** `lib/context-preloader.sh`

### Garanties de sûreté

| Garantie | Implémentation |
|-----------|----------------|
| Pas de boucles infinies | Machine à états forward-only |
| Pas d'appels récursifs | Garde de profondeur (MAX_DEPTH=1) |
| Pas de chargement non borné | Budget de tokens (15 000 par défaut) |
| Immuable après chargement | Contexte verrouillé après injection |

### Machine à états

```
IDLE → CLASSIFYING → RESOLVING → LOADING → INJECTING → LOCKED
```

Les états ne peuvent avancer que **vers l'avant** : jamais en arrière. Une fois à LOCKED, le contexte ne peut plus être modifié.

### Prise en charge multi-fournisseur de LLM

La détection de l'étage 2 prend en charge plusieurs fournisseurs de LLM (auto-détectés à partir des clés d'API) :

| Fournisseur | Variable de clé d'API | Modèle utilisé |
|----------|-----------------|------------|
| Anthropic | `ANTHROPIC_API_KEY` | claude-3-haiku |
| OpenAI | `OPENAI_API_KEY` | gpt-4o-mini |
| Groq | `GROQ_API_KEY` | llama-3.1-8b-instant |
| Azure | `AZURE_OPENAI_API_KEY` | gpt-4o-mini |
| Mistral | `MISTRAL_API_KEY` | mistral-small |

### Fonctions clés

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

| Variable | Défaut | Description |
|----------|---------|-------------|
| `PRELOADER_MAX_TOKENS` | 15000 | Nombre maximal de tokens à précharger |
| `PRELOADER_MAX_DEPTH` | 1 | Empêche le chargement récursif |
| `PRELOADER_CACHE_TTL` | 1800 | TTL du cache en secondes (30 min) |

---

## Sprint Tracker

> Gestion complète des sprints, stories et pipelines avec fonctions de sûreté.

**File:** `lib/sprint-tracker.sh`

### Fonctions principales

#### Opérations sur les sprints

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

#### Opérations sur les stories

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

### Pipeline Autopilot

La fonction `run_story_pipeline()` orchestre le cycle de vie complet d'une story avec intégration ARIA :

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

Circuit breaker par story avec suivi par phase :

| Limite | Valeur | Description |
|-------|-------|-------------|
| Max d'échecs par story | 10 | Ouvre le circuit breaker |
| Max d'échecs par phase | 5 | Bloque la phase |
| Max d'itérations | 10 | Empêche les boucles infinies |

**États :**

| State | Signification | Action |
|-------|---------|--------|
| `CLOSED` | Fonctionnement normal | Autorise les opérations |
| `OPEN` | Max d'échecs atteint | Bloque les opérations |
| `HALF_OPEN` | Test de récupération | Autorise une opération de test |

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

### Système d'escalade

Lorsque le circuit breaker s'ouvre, une escalade automatique se déclenche :

```bash
# Triggered automatically when circuit breaker opens
on_circuit_breaker_open "STORY-001" "developer" "Error details"
```

**Étapes d'escalade :**

1. **Enregistrement au journal d'erreurs** - Auto-apprentissage Sentinel
2. **Marquage de la story** - Statut = `NEEDS_ESCALATION`
3. **Affichage des erreurs similaires** - Depuis MCP Memory
4. **Auto-escalade** - Passe à la story suivante du sprint

### Détection d'achèvement

Détecte l'achèvement d'une story à partir de la sortie de l'agent :

```bash
# Returns: 0=COMPLETE, 1=IN_PROGRESS, 2=BLOCKED
detect_story_completion "STORY-001" "developer" "$agent_output"
```

**Signaux d'achèvement par phase :**

| Phase | Signaux d'achèvement | Signaux de blocage |
|-------|-----------------|-----------------|
| developer | "implementation complete", "code ready" | "blocked", "error", "failed" |
| tester | "all tests passing", "coverage 100%" | "test fail", "coverage gap" |
| ucv-validator | "Coverage: 100%", "all validated" | "gaps", "incomplete" |

### Budget API

Limitation de débit pour éviter les coûts incontrôlés :

```bash
# Check if budget allows operations
if check_api_budget; then
    # Proceed
fi
```

| Limite | Défaut | Description |
|-------|---------|-------------|
| `api_calls_limit` | 10,000 | Max d'appels API par sprint |
| `warning_threshold` | 80% | Affiche un avertissement à ce niveau d'usage |

### Santé du sprint

Surveiller la santé du sprint :

```bash
get_sprint_health
# Returns: {"total": 10, "done": 3, "escalated": 2, "healthy": true}
```

### Contrôle de boucle (sûreté autopilot)

Fonctions qui maintiennent les longues boucles autopilot en sécurité : filtrage des erreurs, détection de boucle bloquée, score de confiance et récupération en douceur du circuit breaker.

```bash
# Visual dashboard of circuit-breaker state (CLOSED / OPEN / HALF_OPEN)
show_circuit_status "STORY-001"

# Two-stage error filtering (avoids JSON/log false positives)
count_real_errors "$output"

# Detect a stuck loop across multiple iterations of output history
detect_stuck_loop "$output_history"

# Confidence score 0-100 that a story is actually complete
analyze_response_confidence "$response"

# Move an OPEN circuit breaker to HALF_OPEN for a controlled retry
transition_to_half_open "STORY-001"

# Should execution halt now? (combines CB state + stuck + confidence)
should_halt_execution "STORY-001"
```

---

## Date Utils

> Utilitaires de date/heure multiplateformes (macOS BSD / Linux GNU). Voir le pattern `P-011-bash-cross-platform`.

**File:** `lib/date_utils.sh`

```bash
get_iso_timestamp        # → YYYY-MM-DDTHH:MM:SS+00:00
get_epoch_timestamp      # → Unix seconds
get_basic_timestamp      # → YYYY-MM-DD HH:MM:SS
get_next_hour_time       # → ISO timestamp rounded to next hour
get_time_diff_seconds "$t1" "$t2"   # → diff in seconds between two timestamps
format_duration 3723     # → "1h 2m 3s" (human readable)
```

---

## Config Loader

> Configuration centralisée avec cache paresseux et compatibilité ascendante.

**File:** `lib/config-loader.sh`

### Précédence de configuration

Les fichiers sont chargés dans l'ordre (le dernier l'emporte) :

1. `framework/config/harmony.config.json` - Valeurs par défaut du framework
2. `.harmony/config/overrides.yaml` - Surcharges du projet
3. `.harmony/local/config/overrides.yaml` - Surcharges locales (priorité la plus élevée)

### Fonctions clés

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

### Cache de branches (chargement paresseux)

Recherche en O(1) pour la résolution agent/branche avec chargement paresseux :

```bash
# Resolve agent to branch file
branch_path=$(resolve_agent "developer-web")
# → "specialties/developer/branchs/web.md"

# Cache is built lazily - only loaded specialties are cached
```

### Utilitaires de version

```bash
# Compare semantic versions
if version_gte "1.2.0" "1.0.0"; then
    echo "Version is compatible"
fi
```

### Avertissements de dépréciation

Le loader avertit automatiquement à propos des clés de configuration dépréciées :

```
⚠️  Deprecated: 'docker_required' → use 'docker.required' instead
```

| Clé dépréciée | Nouvelle clé |
|----------------|---------|
| `docker_required` | `docker.required` |
| `container_prefix` | `docker.container_prefix` |
| `guardian_mode` | `guardian.mode` |
| `sentinel_enabled` | `sentinel.enabled` |

### Parseur YAML de repli

Lorsque `yq` n'est pas installé, un parseur YAML basique gère les configurations simples :

- Prend en charge les objets imbriqués jusqu'à 3 niveaux
- Gère les chaînes, booléens, nombres
- **Limitations :** Pas de tableaux, pas de chaînes multilignes

---

## Assistant Toolkit

> Orchestrateur unifié pour tous les modules d'assistance.

**File:** `lib/assistant-toolkit.sh`

### Modules

| Module | Rôle |
|--------|---------|
| `model-manager` | Alias de modèles, paliers, estimation des coûts |
| `auto-linter` | Détection de langage, linting automatique |
| `repomap` | Analyse de la structure du dépôt |
| `file-watcher` | Détection des changements de fichiers et hooks |
| `history-summarizer` | Historique de session, compression du contexte |

### Fonctions clés

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

### Chargement des modules

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

## Voir aussi

- [Architecture](architecture.md) - Architecture du système
- [Context Persistence](context-persistence.md) - Système de mémoire
- [Assistant Toolkit](assistant-toolkit.md) - Détails du toolkit
- [MCP AutoLearning](mcp-autolearning.md) - Apprentissage cross-session
