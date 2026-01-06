#!/bin/bash
# ============================================================================
# verify-package-integrity.sh - Verify coherence between package.json and install.sh
# ============================================================================
# Run this before publishing to ensure all directories are correctly listed
# ============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_JSON="$SCRIPT_DIR/package.json"
INSTALL_SH="$SCRIPT_DIR/bin/install.sh"

echo "🔍 Verifying package integrity..."
echo ""

# Extract directories from package.json (files array)
echo "📦 Directories in package.json:"
PACKAGE_DIRS=$(grep -E '^\s*"[a-z-]+/"' "$PACKAGE_JSON" | sed 's/.*"\([^"]*\)\/".*/\1/' | sort)
echo "$PACKAGE_DIRS" | sed 's/^/   /'

echo ""

# Extract directories from install.sh (dirs_to_copy array)
echo "📋 Directories in install.sh (dirs_to_copy):"
INSTALL_DIRS=$(grep -A 30 'dirs_to_copy=(' "$INSTALL_SH" | grep -E '^\s*"[a-z-]+"' | sed 's/.*"\([^"]*\)".*/\1/' | sort)
echo "$INSTALL_DIRS" | sed 's/^/   /'

echo ""

# Compare
ONLY_IN_PACKAGE=$(comm -23 <(echo "$PACKAGE_DIRS") <(echo "$INSTALL_DIRS"))
ONLY_IN_INSTALL=$(comm -13 <(echo "$PACKAGE_DIRS") <(echo "$INSTALL_DIRS"))

# Filter out expected exceptions
EXPECTED_ONLY_PACKAGE="bin"  # bin/ is for npm only, not copied to .harmony

ERRORS=0

if [[ -n "$ONLY_IN_PACKAGE" ]]; then
    echo "⚠️  In package.json but NOT in install.sh:"
    while IFS= read -r dir; do
        if [[ "$dir" == "$EXPECTED_ONLY_PACKAGE" ]]; then
            echo "   $dir (expected - npm only)"
        else
            echo "   ❌ $dir"
            ERRORS=$((ERRORS + 1))
        fi
    done <<< "$ONLY_IN_PACKAGE"
    echo ""
fi

if [[ -n "$ONLY_IN_INSTALL" ]]; then
    echo "⚠️  In install.sh but NOT in package.json:"
    echo "$ONLY_IN_INSTALL" | sed 's/^/   ❌ /'
    echo ""
    ERRORS=$((ERRORS + 1))
fi

# Verify directories exist
echo "📂 Verifying directories exist:"
MISSING=0
for dir in $PACKAGE_DIRS; do
    if [[ -d "$SCRIPT_DIR/$dir" ]]; then
        echo "   ✓ $dir"
    else
        echo "   ❌ $dir (missing!)"
        MISSING=$((MISSING + 1))
    fi
done

echo ""

if [[ $ERRORS -gt 0 || $MISSING -gt 0 ]]; then
    echo "❌ Verification FAILED: $ERRORS mismatches, $MISSING missing directories"
    exit 1
else
    echo "✅ Package integrity verified!"
fi
