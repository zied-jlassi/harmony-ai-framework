# Bash Testing Patterns

> Patterns universels pour tests bash avec `set -euo pipefail`.
> **Source**: AutoLearning - chaque pattern vient d'une erreur réelle.

## Erreurs Connues (Error Library)

Ces erreurs sont documentées dans `error-library/errors/bash/`:

| ID | Description | Commande |
|----|-------------|----------|
| [BASH-001](../../../error-library/errors/bash/BASH-001.json) | `((VAR++))` crash avec set -e | `get_error_solution "BASH-001"` |
| [BASH-002](../../../error-library/errors/bash/BASH-002.json) | Regex `{n}` non supporté | `get_error_solution "BASH-002"` |
| [BASH-003](../../../error-library/errors/bash/BASH-003.json) | Exit code perdu avec set -e | `get_error_solution "BASH-003"` |
| [BASH-004](../../../error-library/errors/bash/BASH-004.json) | Fonction attend fichier pas string | `get_error_solution "BASH-004"` |
| [BASH-005](../../../error-library/errors/bash/BASH-005.json) | Fonction retourne exit code | `get_error_solution "BASH-005"` |

```bash
# Charger l'error-library
source framework/lib/error-library-loader.sh

# Chercher une solution
search_errors "set -e"
get_error_solution "BASH-001"
```

---

## Patterns de Test

### 1. Structure Standard

```bash
#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=""
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

setup() {
    TEST_DIR=$(mktemp -d)
}

teardown() {
    [[ -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

trap teardown EXIT

main() {
    setup
    run_tests
    print_results
    [[ $TESTS_FAILED -eq 0 ]]
}

main "$@"
```

### 2. Assertions Réutilisables

```bash
assert_eq() {
    local actual="$1" expected="$2" msg="$3"
    if [[ "$actual" == "$expected" ]]; then
        echo "✓ $msg"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $msg"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local string="$1" substring="$2" msg="$3"
    if [[ "$string" == *"$substring"* ]]; then
        echo "✓ $msg"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $msg"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_exists() {
    local path="$1" msg="$2"
    if [[ -f "$path" ]]; then
        echo "✓ $msg"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ $msg (file not found: $path)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

skip() {
    echo "○ $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}
```

### 3. Test Défensif

```bash
test_my_function() {
    # Vérifier si la fonction existe
    if ! type my_function &>/dev/null; then
        skip "my_function not available"
        return
    fi

    # Capturer exit code (voir BASH-003)
    my_function "arg" 2>/dev/null && code=0 || code=$?

    assert_eq "$code" "0" "my_function returns success"
}
```

### 4. Préparer les Globals

```bash
setup() {
    TEST_DIR=$(mktemp -d)

    # Définir les globals attendus par les fonctions
    export SOME_DIR="$TEST_DIR/data"
    export CONFIG_FILE="$TEST_DIR/config.json"

    # Créer les fichiers attendus
    mkdir -p "$SOME_DIR"
    echo '{"key": "value"}' > "$CONFIG_FILE"
}
```

### 5. Tester avec Fichiers Temporaires

```bash
test_count_errors() {
    # Créer un fichier (voir BASH-004)
    local test_file="$TEST_DIR/errors.txt"
    echo "Error: something failed" > "$test_file"
    echo "Fatal: crash" >> "$test_file"

    # Passer le chemin, pas le contenu
    local count=$(count_errors "$test_file")

    assert_eq "$count" "2" "count_errors finds 2 errors"
}
```

---

## Quick Reference

| Pattern | Usage |
|---------|-------|
| Exit code capture | `cmd && c=0 \|\| c=$?` |
| Increment counter | `VAR=$((VAR + 1))` |
| Temp directory | `TEST_DIR=$(mktemp -d)` |
| Cleanup on exit | `trap teardown EXIT` |
| Check function exists | `type func &>/dev/null` |
| Suppress stderr | `cmd 2>/dev/null` |

---

> **Voir aussi**: `error-library/` pour la liste complète des erreurs bash documentées.
