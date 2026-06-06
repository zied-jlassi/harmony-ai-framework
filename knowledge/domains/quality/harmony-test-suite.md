# Harmony Framework Test Suite

> Documentation complète du système de tests Harmony.
> Pour patterns bash universels, voir: `../../shared/patterns/bash-testing-patterns.md`

## Quick Start

```bash
cd tests/e2e/scripts

# Unit tests (pas besoin de .harmony)
./test.sh /tmp/x unit

# Validation (nécessite .harmony)
./test.sh /path/project validate

# Scenarios end-to-end
./test.sh /path/project scenario full
```

---

## Architecture

```
tests/e2e/scripts/
├── test.sh                    # Orchestrateur principal
├── README.md                  # Documentation utilisateur
├── KNOWLEDGE.md               # Base de connaissances détaillée
├── lib/
│   ├── assertions.sh          # 14 assertions réutilisables
│   └── setup.sh               # Utilitaires setup/teardown
├── unit/                      # Tests unitaires
│   ├── run-all.sh
│   ├── test-sprint-tracker.sh # 52 tests
│   ├── test-date-utils.sh     # 25 tests
│   ├── test-config-loader.sh  # 33 tests
│   ├── test-recovery.sh       # 26 tests
│   └── test-autopilot.sh      # 11 tests
├── modules/                   # Tests d'intégration
│   ├── validate-install.sh
│   ├── validate-guardian.sh
│   ├── validate-sentinel.sh
│   ├── validate-hqvf.sh
│   ├── validate-pipeline.sh
│   ├── validate-routing.sh
│   └── validate-safety.sh
└── scenarios/                 # Tests E2E
    ├── test-scenario-full.sh
    ├── test-comprehensive.sh
    └── test-scenario-nestjs-school.sh
```

---

## Couverture

| Bibliothèque | Fonctions | Tests | Couverture |
|--------------|-----------|-------|------------|
| sprint-tracker.sh | 52 | 52 | 100% |
| date_utils.sh | 6 | 25 | 100% |
| config-loader.sh | 13 | 33 | 100% |
| recovery.sh | 18 | 26 | 100% |
| autopilot-commands.sh | 6 | 11 | 100% |
| **Total** | **95** | **147** | **100%** |

---

## Commandes

| Commande | Description | .harmony requis |
|----------|-------------|-----------------|
| `unit [name]` | Tests unitaires | Non |
| `validate` | Tous les validate-*.sh | Oui |
| `install` | Validation installation | Oui |
| `guardian` | Guardian Protocol | Oui |
| `sentinel` | Sentinel Memory | Oui |
| `hqvf` | HQVF/UCV Quality | Oui |
| `pipeline` | Pipeline Orchestration | Oui |
| `routing` | Agent Routing | Oui |
| `safety` | Ralph Safety System | Oui |
| `story` | Story Lifecycle | Oui |
| `scenario <name>` | E2E scenario | Oui |
| `all` | Tout | Oui |

---

## Scenarios E2E

### test-scenario-full.sh (~5 min)
- Workflow complet: Story → Pipeline → Completion
- Métriques de performance
- Consommation tokens
- Tous subsystems: Memory, Hooks, AutoLearning, Safety

### test-comprehensive.sh (~10 min)
- 30+ agents
- 37 commandes
- Tous profils et spécialités
- Circuit breaker, rate limiter
- Memory, Pipeline, Hooks, Templates

### test-scenario-nestjs-school.sh (~3 min)
- Stack: NestJS + Prisma + JWT
- Comportement JIT réel

---

## Signatures Critiques

### sprint-tracker.sh

```bash
# Response Analysis - RETOURNE EXIT CODE
detect_story_completion(story_id, phase, output)
# 0=COMPLETE, 1=IN_PROGRESS, 2=BLOCKED

# Circuit Breaker - RETOURNE EXIT CODE
check_story_circuit_breaker(story_id)  # 0=CLOSED, 1=OPEN
init_story_circuit_breaker(story_id)
record_story_failure(story_id)
record_story_success(story_id)
reset_circuit_breaker(story_id)

# ATTENTION: Attend FILE PATH pas string
count_real_errors(file_path)

# ATTENTION: Utilise global HARMONY_DIR
check_api_budget()  # Retourne exit code

# ATTENTION: Signatures spécifiques
update_session_context(agent, workflow, action)
add_handoff(from, to, context)
clear_handoff()  # Pas d'arguments
```

### config-loader.sh

```bash
version_gte(v1, v2)           # Exit code
load_config()                 # Popule MERGED_CONFIG
get_config(key, default)
get_config_array(key)
get_config_bool(key, default)
has_config(key)               # Exit code
resolve_hook(name)
resolve_agent(name)
resolve_template(name)
```

### recovery.sh

```bash
checkpoint_before(action)
checkpoint_after(action)
checkpoint_failed(action, error_type)
create_backup(description)
restore_backup(backup_name)
recover_state()
```

---

## Variables Globales

| Variable | Description |
|----------|-------------|
| `HARMONY_DIR` | Chemin vers `.harmony` |
| `WORKING_MEMORY` | Chemin vers `working.json` |
| `MERGED_CONFIG` | Configuration JSON chargée |
| `TEST_TARGET_DIR` | Répertoire temp pour isolation |
| `FRAMEWORK_DIR` | Racine harmony-framework |
| `FRAMEWORK_LIB` | Chemin vers `framework/lib` |

---

## Features Testées

### Memory System
- `working.json` - État sprint/story
- `workflow-state.json` - État pipeline
- `error-journal.json` - Tracking erreurs
- `learned-patterns.json` - Patterns appris

### AutoLearning
- Capture erreurs dans error-journal.json
- Extraction patterns dans learned-patterns.json
- Détection stuck loops
- Analyse de confiance

### Safety (Ralph)
- **Circuit Breaker**: CLOSED → OPEN après échecs consécutifs
- **Rate Limiter**: Budget API vérifié par check_api_budget()

### Guardian Protocol
- Modes: strict, normal
- Config: `guardian.mode`

### HQVF/UCV
- Quality gates par phase
- `update_quality_gate(phase, status)`
- `check_quality_gates()`

---

## Créer un Nouveau Test

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/assertions.sh"
source "$SCRIPT_DIR/lib/setup.sh"

setup() {
    create_test_dir
    create_minimal_harmony_structure "$TEST_TARGET_DIR"

    # Sourcer la lib à tester
    source "$FRAMEWORK_LIB/my-lib.sh"
}

test_my_function() {
    suite "My Function"

    if type my_function &>/dev/null; then
        local result
        result=$(my_function "arg" 2>/dev/null) || result=""
        assert_eq "$result" "expected" "Description"
    else
        skip "my_function not available"
    fi
}

main() {
    echo -e "${BOLD}Unit Tests: my-lib.sh${NC}"
    setup
    test_my_function
    print_summary
    cleanup_test_dir
    [[ $TESTS_FAILED -eq 0 ]]
}

main "$@"
```

---

## CI/CD

```bash
#!/bin/bash
cd tests/e2e/scripts

# Unit tests (rapide, pas de dépendances)
./test.sh /tmp/ci unit || exit 1

# Integration (nécessite projet initialisé)
harmony init /tmp/ci-project
./test.sh /tmp/ci-project validate || exit 1

# Scenario complet
./test.sh /tmp/ci-project scenario full || exit 1
```

---

## Liens

- [bash-testing-patterns.md](../../shared/patterns/bash-testing-patterns.md) - Patterns universels

---

> **Origine**: Documentation construite par AutoLearning.
> Chaque pattern vient d'une erreur réelle rencontrée et résolue.
