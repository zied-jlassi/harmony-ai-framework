#!/bin/bash
# =============================================================================
# Harmony Framework - Test Environment Setup
# Pattern: P-013 Test Environment Isolation
# =============================================================================
#
# Creates an isolated test environment in /tmp/harmony-framework/{timestamp}
# to prevent any modification to the source framework.
#
# IMPORTANT: This script checks for uncommitted changes before running tests.
#            Always commit your work before testing to avoid data loss.
#
# Usage:
#   source ./setup-test-env.sh [framework_source_dir]
#
# Options:
#   --force    Skip git check (not recommended)
#
# Environment Variables Set:
#   HARMONY_TEST_DIR      - Root of current test run
#   HARMONY_DIR           - Framework directory in test environment
#   HARMONY_TEST_TIMESTAMP - Timestamp of this run
#
# =============================================================================

set -e

# =============================================================================
# SAFETY CHECK: Uncommitted changes
# =============================================================================

check_git_status() {
    local src_dir="$1"
    local force_mode="$2"

    # Skip if not a git repo
    if [[ ! -d "$src_dir/.git" ]] && ! git -C "$src_dir" rev-parse --git-dir >/dev/null 2>&1; then
        return 0
    fi

    # Check for uncommitted changes
    if ! git -C "$src_dir" diff --quiet HEAD 2>/dev/null; then
        echo ""
        echo "========================================"
        echo "WARNING: Uncommitted Changes Detected!"
        echo "========================================"
        echo ""
        echo "You have uncommitted changes in the framework."
        echo "It is STRONGLY recommended to commit before testing"
        echo "to avoid losing work in case of an incident."
        echo ""

        # Show what's uncommitted
        echo "Uncommitted files:"
        git -C "$src_dir" status --short 2>/dev/null | head -10
        REMAINING=$(git -C "$src_dir" status --short 2>/dev/null | wc -l)
        if [[ $REMAINING -gt 10 ]]; then
            echo "  ... and $((REMAINING - 10)) more files"
        fi
        echo ""

        if [[ "$force_mode" == "true" ]]; then
            echo "Continuing anyway (--force specified)..."
            echo ""
        else
            echo "Options:"
            echo "  1. Commit your changes first:"
            echo "     git add -A && git commit -m 'WIP: before test run'"
            echo ""
            echo "  2. Or run with --force to skip this check:"
            echo "     source setup-test-env.sh --force"
            echo ""
            return 1
        fi
    else
        echo "Git status: All changes committed"
    fi
}

# Parse arguments
FORCE_MODE="false"
FRAMEWORK_ARG=""

for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE_MODE="true"
            ;;
        *)
            FRAMEWORK_ARG="$arg"
            ;;
    esac
done

# Configuration
TIMESTAMP=$(date +%Y%m%d%H%M)
TEST_ROOT="/tmp/harmony-framework"
TEST_DIR="$TEST_ROOT/$TIMESTAMP"

# Determine framework source
if [[ -n "$FRAMEWORK_ARG" ]]; then
    FRAMEWORK_SRC="$FRAMEWORK_ARG"
elif [[ -n "$HARMONY_FRAMEWORK_SRC" ]]; then
    FRAMEWORK_SRC="$HARMONY_FRAMEWORK_SRC"
else
    # Default: relative to this script
    FRAMEWORK_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Validate source exists
if [[ ! -d "$FRAMEWORK_SRC/agents" ]]; then
    echo "ERROR: Framework source not found: $FRAMEWORK_SRC"
    echo "Usage: source setup-test-env.sh [framework_source_dir]"
    return 1 2>/dev/null || exit 1
fi

# =============================================================================
# SAFETY CHECK: Run git status check
# =============================================================================
if ! check_git_status "$FRAMEWORK_SRC" "$FORCE_MODE"; then
    return 1 2>/dev/null || exit 1
fi

echo "========================================"
echo "Harmony Test Environment Setup"
echo "========================================"

# =============================================================================
# STEP 1: Publish to Verdaccio (optional but recommended)
# =============================================================================
publish_to_verdaccio() {
    local project_root="$1"
    local makefile_dir="$(cd "$project_root/.." && pwd)"

    if [[ -f "$makefile_dir/Makefile" ]]; then
        echo ""
        echo "[1/4] Publishing to Verdaccio..."

        # Clean and republish
        cd "$makefile_dir"
        make clean-cache 2>/dev/null || true
        make clean-harmony 2>/dev/null || true
        make bump-patch 2>/dev/null || true
        make publish 2>/dev/null || {
            echo "  WARNING: Verdaccio publish failed (might not be running)"
            return 1
        }
        echo "  Package published to local registry"
        cd - >/dev/null
    else
        echo "[1/4] Skipping Verdaccio (no Makefile found)"
    fi
}

# =============================================================================
# STEP 2: Clear memory (if make target exists)
# =============================================================================
clear_memory() {
    local project_root="$1"
    local makefile_dir="$(cd "$project_root/.." && pwd)"

    echo ""
    echo "[2/4] Clearing memory..."

    # Clear Claude memory if exists
    if [[ -d "$project_root/../.claude/memory" ]]; then
        echo "  Clearing .claude/memory/..."
        rm -rf "$project_root/../.claude/memory/"*.json 2>/dev/null || true
    fi

    echo "  Memory cleared"
}

# Run pre-test steps if not in quick mode
if [[ "$FORCE_MODE" != "true" ]]; then
    publish_to_verdaccio "$FRAMEWORK_SRC"
    clear_memory "$FRAMEWORK_SRC"
fi
echo ""
echo "[3/4] Creating test environment..."
echo "  Source:    $FRAMEWORK_SRC"
echo "  Target:    $TEST_DIR"
echo "  Timestamp: $TIMESTAMP"
echo ""

# Create test directory
mkdir -p "$TEST_DIR"

# =============================================================================
# STEP 3: Fresh Install from Verdaccio OR Copy
# =============================================================================
install_framework() {
    local target_dir="$1"
    local project_root="$2"
    local makefile_dir="$(cd "$project_root/.." && pwd)"

    # Try fresh install via make install-local
    if [[ -f "$makefile_dir/Makefile" ]]; then
        echo "  Installing via make install-local..."
        cd "$makefile_dir"

        # Use make to install in target directory
        if make install-local TARGET="$target_dir" 2>/dev/null; then
            echo "  Fresh install complete!"
            cd - >/dev/null
            return 0
        fi

        cd - >/dev/null
        echo "  make install-local failed, falling back to copy..."
    fi

    # Fallback: Copy files directly
    echo "  Copying framework files..."
    mkdir -p "$target_dir/.harmony"
    for dir in agents workflows patterns templates hooks lib bin config docs commands; do
        if [[ -d "$project_root/$dir" ]]; then
            echo "    - $dir/"
            cp -r "$project_root/$dir" "$target_dir/.harmony/"
        fi
    done
}

install_framework "$TEST_DIR" "$FRAMEWORK_SRC"

# =============================================================================
# STEP 4: Create user structure (P-012 compliant)
# =============================================================================
echo ""
echo "[4/4] Creating user structure (P-012)..."
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

# Create empty config (mirroring framework structure)
mkdir -p "$TEST_DIR/.harmony/local/config"
cat > "$TEST_DIR/.harmony/local/config/overrides.yaml" << 'EOF'
# Harmony Test Environment Configuration
# Generated by setup-test-env.sh

test_mode: true

# Override paths here if needed
# paths:
#   backlog: ".harmony/local/project/backlog"
EOF

# Create test results directory
mkdir -p "$TEST_DIR/test-results/logs"

# Create test project (fake project for testing)
mkdir -p "$TEST_DIR/test-project/src"
cat > "$TEST_DIR/test-project/README.md" << 'EOF'
# Test Project

This is a fake project created for testing Harmony Framework.
EOF

# Update latest symlink
rm -f "$TEST_ROOT/latest"
ln -sf "$TIMESTAMP" "$TEST_ROOT/latest"

# Export environment variables
export HARMONY_TEST_DIR="$TEST_DIR"
export HARMONY_DIR="$TEST_DIR/.harmony"
export HARMONY_TEST_TIMESTAMP="$TIMESTAMP"

echo ""
echo "========================================"
echo "Test Environment Ready!"
echo "========================================"
echo ""
echo "Environment Variables:"
echo "  HARMONY_TEST_DIR=$HARMONY_TEST_DIR"
echo "  HARMONY_DIR=$HARMONY_DIR"
echo "  HARMONY_TEST_TIMESTAMP=$HARMONY_TEST_TIMESTAMP"
echo ""
echo "Symlink: $TEST_ROOT/latest -> $TIMESTAMP"
echo ""
echo "Usage:"
echo "  ls \$HARMONY_DIR/agents/"
echo "  cat \$HARMONY_DIR/workflows/discovery.md"
echo ""
