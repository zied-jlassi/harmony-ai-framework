# Pattern: Test Environment Isolation (P-013)

> **ID**: P-013
> **Category**: Testing / Safety
> **Status**: MANDATORY
> **Priority**: HIGH

---

## Problem

Executing tests directly in the Harmony Framework project:
- Risk of accidental file deletion
- Repository pollution with test artifacts
- Conflicts with source code
- Difficulty debugging failed tests

## Solution

Use temporary directory `/tmp/harmony-framework/` with timestamped runs.

---

## Rule

**NEVER test directly in the framework source.**
**ALWAYS use `/tmp/harmony-framework/{timestamp}/`.**

---

## Structure

```
/tmp/harmony-framework/
│
├── {YmdHM}/                   # Test run (e.g., 202501031318)
│   │
│   ├── .harmony/              # Framework copy
│   │   ├── agents/
│   │   ├── workflows/
│   │   ├── patterns/
│   │   ├── templates/
│   │   ├── hooks/
│   │   ├── lib/
│   │   ├── bin/
│   │   ├── config/
│   │   ├── docs/
│   │   └── local/             # Empty user structure
│   │       ├── config.yaml
│   │       ├── overrides/
│   │       └── project/
│   │           ├── backlog/
│   │           │   ├── epics/
│   │           │   ├── stories/
│   │           │   └── tasks/
│   │           ├── prd/
│   │           ├── briefs/
│   │           ├── analysis/
│   │           └── architecture/
│   │
│   ├── test-results/          # Test outputs
│   │   ├── summary.json
│   │   ├── coverage.json
│   │   └── logs/
│   │
│   └── test-project/          # Fake project for tests
│       └── src/
│
└── latest -> {YmdHM}/         # Symlink to most recent
```

---

## Timestamp Format

Format: `YmdHM` (Year, month, day, Hour, Minute)

```bash
TIMESTAMP=$(date +%Y%m%d%H%M)
# Example: 202501031318 = 2025-01-03 13:18
```

---

## Safety Rule

**ALWAYS commit before testing.**

The setup script checks for uncommitted changes and blocks execution if found:

```
========================================"
WARNING: Uncommitted Changes Detected!
========================================

You have uncommitted changes in the framework.
It is STRONGLY recommended to commit before testing
to avoid losing work in case of an incident.

Options:
  1. Commit your changes first:
     git add -A && git commit -m 'WIP: before test run'

  2. Or run with --force to skip this check:
     source setup-test-env.sh --force
```

---

## Setup Script

```bash
#!/bin/bash
# framework/bin/setup-test-env.sh
# See full script in framework/bin/setup-test-env.sh

set -e

# Safety check: uncommitted changes
check_git_status "$FRAMEWORK_SRC" "$FORCE_MODE"

# Paths
TIMESTAMP=$(date +%Y%m%d%H%M)
TEST_ROOT="/tmp/harmony-framework"
TEST_DIR="$TEST_ROOT/$TIMESTAMP"
FRAMEWORK_SRC="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "Setting up test environment..."
echo "  Source: $FRAMEWORK_SRC"
echo "  Target: $TEST_DIR"

# Create test directory
mkdir -p "$TEST_DIR"

# Copy framework (excluding .git, tests, research)
for dir in agents workflows patterns templates hooks lib bin config docs; do
    if [[ -d "$FRAMEWORK_SRC/$dir" ]]; then
        cp -r "$FRAMEWORK_SRC/$dir" "$TEST_DIR/.harmony/"
    fi
done

# Create empty user structure (P-012 compliant)
mkdir -p "$TEST_DIR/.harmony/local/overrides/agents"
mkdir -p "$TEST_DIR/.harmony/local/overrides/hooks"
mkdir -p "$TEST_DIR/.harmony/local/overrides/templates"
mkdir -p "$TEST_DIR/.harmony/local/project/backlog/epics"
mkdir -p "$TEST_DIR/.harmony/local/project/backlog/stories"
mkdir -p "$TEST_DIR/.harmony/local/project/backlog/tasks"
mkdir -p "$TEST_DIR/.harmony/local/project/prd"
mkdir -p "$TEST_DIR/.harmony/local/project/briefs"
mkdir -p "$TEST_DIR/.harmony/local/project/analysis"
mkdir -p "$TEST_DIR/.harmony/local/project/architecture/adrs"
mkdir -p "$TEST_DIR/.harmony/local/project/roadmap"
mkdir -p "$TEST_DIR/.harmony/local/project/rex"

# Create empty config
cat > "$TEST_DIR/.harmony/local/config.yaml" << 'EOF'
# Test environment config
test_mode: true
EOF

# Create test results directory
mkdir -p "$TEST_DIR/test-results/logs"

# Create test project
mkdir -p "$TEST_DIR/test-project/src"

# Update latest symlink
rm -f "$TEST_ROOT/latest"
ln -sf "$TIMESTAMP" "$TEST_ROOT/latest"

# Export variables
export HARMONY_TEST_DIR="$TEST_DIR"
export HARMONY_DIR="$TEST_DIR/.harmony"
export HARMONY_TEST_TIMESTAMP="$TIMESTAMP"

echo ""
echo "Test environment ready!"
echo "  HARMONY_TEST_DIR=$HARMONY_TEST_DIR"
echo "  HARMONY_DIR=$HARMONY_DIR"
echo "  Symlink: $TEST_ROOT/latest"
```

---

## Cleanup Script

```bash
#!/bin/bash
# framework/bin/cleanup-test-env.sh

TEST_ROOT="/tmp/harmony-framework"
KEEP_RUNS="${1:-5}"  # Keep last N runs

echo "Cleaning test environments (keeping last $KEEP_RUNS)..."

if [[ ! -d "$TEST_ROOT" ]]; then
    echo "No test directory found."
    exit 0
fi

# Get runs sorted by name (chronological)
RUNS=$(ls -1 "$TEST_ROOT" 2>/dev/null | grep -E '^[0-9]{12}$' | sort -r)
COUNT=0

for run in $RUNS; do
    ((COUNT++))
    if [[ $COUNT -gt $KEEP_RUNS ]]; then
        echo "  Removing: $run"
        rm -rf "$TEST_ROOT/$run"
    else
        echo "  Keeping: $run"
    fi
done

echo "Done."
```

---

## Test Runner Template

```bash
#!/bin/bash
# tests/e2e/run-tests.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/../../framework" && pwd)"

# Setup test environment
echo "=== Setting up test environment ==="
source "$FRAMEWORK_DIR/bin/setup-test-env.sh" "$FRAMEWORK_DIR"

# Run tests
echo ""
echo "=== Running tests ==="
echo "Testing: $HARMONY_DIR"

PASSED=0
FAILED=0

run_test() {
    local test_name="$1"
    local test_script="$2"

    echo -n "  $test_name... "
    if bash "$test_script" "$HARMONY_DIR" > "$HARMONY_TEST_DIR/test-results/logs/$test_name.log" 2>&1; then
        echo "OK"
        ((PASSED++))
    else
        echo "FAIL"
        ((FAILED++))
    fi
}

# Add tests here
# run_test "workflows" "$SCRIPT_DIR/validate-workflows.sh"
# run_test "agents" "$SCRIPT_DIR/validate-agents.sh"
# run_test "patterns" "$SCRIPT_DIR/validate-patterns.sh"

# Summary
echo ""
echo "=== Results ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Logs: $HARMONY_TEST_DIR/test-results/logs/"

# Exit code
[[ $FAILED -eq 0 ]]
```

---

## Usage Examples

### Manual Testing

```bash
# Setup
source framework/bin/setup-test-env.sh

# Test in isolation
ls $HARMONY_DIR/agents/
cat $HARMONY_DIR/workflows/discovery.md

# Clean up
framework/bin/cleanup-test-env.sh
```

### CI/CD Pipeline

```yaml
# .github/workflows/test.yml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Run tests
      run: ./tests/e2e/run-tests.sh

    - name: Upload results
      uses: actions/upload-artifact@v4
      with:
        name: test-results
        path: /tmp/harmony-framework/latest/test-results/
```

### Debugging Failed Test

```bash
# After test failure, inspect the environment
cd /tmp/harmony-framework/latest

# Check what was tested
ls -la .harmony/

# Check logs
cat test-results/logs/workflows.log

# Make fixes, re-run specific test
./tests/e2e/validate-workflows.sh .harmony
```

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `HARMONY_TEST_DIR` | Current test run directory | `/tmp/harmony-framework/202501031318` |
| `HARMONY_DIR` | Framework directory in test | `/tmp/harmony-framework/202501031318/.harmony` |
| `HARMONY_TEST_TIMESTAMP` | Run timestamp | `202501031318` |

---

## Benefits

| Benefit | Description |
|---------|-------------|
| **Safety** | Source code never modified |
| **Isolation** | Each run is independent |
| **History** | Previous runs kept for debug |
| **CI/CD Ready** | Works in pipelines |
| **Clean** | Easy cleanup with script |

---

## Related

- [P-012 Framework Guardian](./P-012-framework-guardian.md) - Structure protection
- [Install Script](../bin/install.sh) - Installation process
