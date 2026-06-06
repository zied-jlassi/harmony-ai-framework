#!/bin/bash
# =============================================================================
# Harmony Framework - Compliance Proof Generation
# =============================================================================
# Automated generation of compliance documentation proving governance,
# security, and alignment with business intent.
#
# Usage:
#   source "${HARMONY_DIR}/lib/compliance-reporter.sh"
#
#   # Generate compliance report
#   compliance_generate_report "sprint-1"
#
#   # Add compliance check
#   compliance_add_check "security" "OWASP" "passed"
#
#   # Get compliance status
#   compliance_get_status
#
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# LOAD GUARD
# -----------------------------------------------------------------------------
if [[ "${COMPLIANCE_REPORTER_LOADED:-}" == "true" ]]; then
    return 0
fi
COMPLIANCE_REPORTER_LOADED=true

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
if [[ -z "${HARMONY_DIR:-}" ]]; then
    HARMONY_DIR=".harmony"
fi

COMPLIANCE_CONFIG="${HARMONY_DIR}/local/compliance-templates.json"
COMPLIANCE_PROOFS="${HARMONY_DIR}/local/memory/compliance-proofs.json"

# Colors
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_WHITE='\033[1;37m'
C_RED='\033[0;31m'
C_NC='\033[0m'

# Source date utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/date_utils.sh" ]]; then
    source "${SCRIPT_DIR}/date_utils.sh"
fi

# Compliance categories
declare -A COMPLIANCE_CATEGORIES=(
    ["security"]="Security & Access Control"
    ["privacy"]="Data Privacy & GDPR"
    ["quality"]="Code Quality & Testing"
    ["governance"]="AI Governance"
    ["audit"]="Audit Trail"
)

# -----------------------------------------------------------------------------
# INTERNAL FUNCTIONS
# -----------------------------------------------------------------------------

_compliance_generate_id() {
    echo "CPL-$(date +%s%N | sha256sum | head -c 8)"
}

_compliance_timestamp() {
    if command -v get_iso_timestamp &>/dev/null; then
        get_iso_timestamp
    else
        date -u +"%Y-%m-%dT%H:%M:%S+00:00"
    fi
}

_compliance_init_proofs() {
    if [[ ! -f "$COMPLIANCE_PROOFS" ]]; then
        mkdir -p "$(dirname "$COMPLIANCE_PROOFS")"
        cp "${HARMONY_DIR}/templates/memory/compliance-proofs.template.json" "$COMPLIANCE_PROOFS"
        local ts
        ts=$(_compliance_timestamp)
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg ts "$ts" '.created = $ts' "$COMPLIANCE_PROOFS" > "$tmp_file" && mv "$tmp_file" "$COMPLIANCE_PROOFS"
    fi
}

# Calculate compliance score
_compliance_calculate_score() {
    _compliance_init_proofs

    local passed
    passed=$(jq '.statistics.passed' "$COMPLIANCE_PROOFS")
    local total
    total=$(jq '.statistics.total_checks' "$COMPLIANCE_PROOFS")

    if (( total == 0 )); then
        echo "0"
        return
    fi

    echo "scale=0; $passed * 100 / $total" | bc
}

# -----------------------------------------------------------------------------
# PUBLIC API
# -----------------------------------------------------------------------------

# Add compliance check
# Usage: compliance_add_check category standard result [details]
compliance_add_check() {
    local category="$1"
    local standard="$2"
    local result="$3"  # passed, failed, warning
    local details="${4:-}"

    _compliance_init_proofs

    local check_id
    check_id=$(_compliance_generate_id)

    local ts
    ts=$(_compliance_timestamp)

    local tmp_file
    tmp_file=$(mktemp)
    jq --arg id "$check_id" \
       --arg cat "$category" \
       --arg std "$standard" \
       --arg result "$result" \
       --arg details "$details" \
       --arg ts "$ts" \
       '.checks += [{
          "id": $id,
          "timestamp": $ts,
          "category": $cat,
          "standard": $std,
          "result": $result,
          "details": $details
        }] |
        .statistics.total_checks += 1 |
        if $result == "passed" then .statistics.passed += 1 else . end |
        if $result == "failed" then .statistics.failed += 1 else . end |
        .statistics.by_category[$cat] = ((.statistics.by_category[$cat] // 0) + 1)' \
        "$COMPLIANCE_PROOFS" > "$tmp_file" && mv "$tmp_file" "$COMPLIANCE_PROOFS"

    local status_color
    case "$result" in
        "passed") status_color="$C_GREEN" ;;
        "failed") status_color="$C_RED" ;;
        "warning") status_color="$C_YELLOW" ;;
        *) status_color="$C_NC" ;;
    esac

    echo -e "Compliance check: ${C_WHITE}$standard${C_NC} - ${status_color}$result${C_NC}"
}

# Generate compliance report
# Usage: compliance_generate_report name [output_file]
compliance_generate_report() {
    local report_name="$1"
    local output_file="${2:-}"

    _compliance_init_proofs

    local report_id
    report_id=$(_compliance_generate_id)

    local ts
    ts=$(_compliance_timestamp)

    local score
    score=$(_compliance_calculate_score)

    # Gather data
    local checks
    checks=$(jq '.checks' "$COMPLIANCE_PROOFS")

    local stats
    stats=$(jq '.statistics' "$COMPLIANCE_PROOFS")

    # Build report
    local report
    report=$(jq -n \
        --arg id "$report_id" \
        --arg name "$report_name" \
        --arg ts "$ts" \
        --argjson score "$score" \
        --argjson checks "$checks" \
        --argjson stats "$stats" \
        '{
          "id": $id,
          "name": $name,
          "generated": $ts,
          "compliance_score": $score,
          "summary": {
            "total_checks": $stats.total_checks,
            "passed": $stats.passed,
            "failed": $stats.failed,
            "by_category": $stats.by_category
          },
          "checks": $checks
        }')

    # Store report
    local tmp_file
    tmp_file=$(mktemp)
    jq --argjson report "$report" \
       '.reports += [$report] |
        .statistics.total_reports += 1' \
        "$COMPLIANCE_PROOFS" > "$tmp_file" && mv "$tmp_file" "$COMPLIANCE_PROOFS"

    # Output or save
    if [[ -n "$output_file" ]]; then
        echo "$report" | jq . > "$output_file"
        echo -e "${C_GREEN}Report saved to: $output_file${C_NC}"
    else
        echo "$report" | jq .
    fi

    echo -e "${C_CYAN}Compliance Score: ${C_WHITE}${score}%${C_NC}"
}

# Get compliance status
# Usage: compliance_get_status
compliance_get_status() {
    _compliance_init_proofs

    local score
    score=$(_compliance_calculate_score)

    local stats
    stats=$(jq '.statistics' "$COMPLIANCE_PROOFS")

    echo -e "${C_CYAN}=== Compliance Status ===${C_NC}"
    echo ""

    # Score with color
    local score_color
    if (( score >= 90 )); then
        score_color="$C_GREEN"
    elif (( score >= 70 )); then
        score_color="$C_YELLOW"
    else
        score_color="$C_RED"
    fi
    echo -e "Compliance Score: ${score_color}${score}%${C_NC}"
    echo ""

    echo -e "${C_WHITE}Checks:${C_NC}"
    echo -e "  Total:  $(echo "$stats" | jq -r '.total_checks')"
    echo -e "  Passed: ${C_GREEN}$(echo "$stats" | jq -r '.passed')${C_NC}"
    echo -e "  Failed: ${C_RED}$(echo "$stats" | jq -r '.failed')${C_NC}"
    echo ""

    echo -e "${C_WHITE}By Category:${C_NC}"
    echo "$stats" | jq -r '.by_category | to_entries[] | "  \(.key): \(.value)"'
}

# List recent checks
# Usage: compliance_list_checks [limit]
compliance_list_checks() {
    local limit="${1:-20}"

    _compliance_init_proofs

    echo -e "${C_CYAN}=== Recent Compliance Checks ===${C_NC}"
    jq -r --argjson limit "$limit" '.checks[-$limit:] | reverse | .[] |
        "[\(.result)] \(.category)/\(.standard)"' "$COMPLIANCE_PROOFS"
}

# Get failed checks
# Usage: compliance_get_failed
compliance_get_failed() {
    _compliance_init_proofs

    echo -e "${C_RED}=== Failed Compliance Checks ===${C_NC}"
    jq -r '[.checks[] | select(.result == "failed")] |
        .[] | "\(.category)/\(.standard): \(.details)"' "$COMPLIANCE_PROOFS"
}

# Add standard compliance checks
# Usage: compliance_run_standard_checks
compliance_run_standard_checks() {
    echo -e "${C_CYAN}Running standard compliance checks...${C_NC}"

    # Security checks
    if [[ -f "${HARMONY_DIR}/local/memory/security-log.json" ]]; then
        local security_blocks
        security_blocks=$(jq '.statistics.blocked // 0' "${HARMONY_DIR}/local/memory/security-log.json" 2>/dev/null || echo "0")
        if (( security_blocks > 0 )); then
            compliance_add_check "security" "Security Gates Active" "passed" "Blocked $security_blocks threats"
        else
            compliance_add_check "security" "Security Gates Active" "passed" "No threats detected"
        fi
    fi

    # Audit trail check
    if [[ -f "${HARMONY_DIR}/local/memory/audit-journal.json" ]]; then
        local audit_entries
        audit_entries=$(jq '.entries | length' "${HARMONY_DIR}/local/memory/audit-journal.json" 2>/dev/null || echo "0")
        if (( audit_entries > 0 )); then
            compliance_add_check "audit" "Audit Trail" "passed" "$audit_entries entries recorded"
        else
            compliance_add_check "audit" "Audit Trail" "warning" "No audit entries"
        fi
    else
        compliance_add_check "audit" "Audit Trail" "failed" "Audit journal not found"
    fi

    # Confidence scoring check
    if [[ -f "${HARMONY_DIR}/local/memory/confidence-history.json" ]]; then
        compliance_add_check "governance" "Confidence Scoring" "passed" "Active"
    fi

    # Data sandbox check
    if [[ -f "${HARMONY_DIR}/local/memory/sandbox-quarantine.json" ]]; then
        compliance_add_check "security" "Data Sandbox" "passed" "Active"
    fi

    echo -e "${C_GREEN}Standard checks completed${C_NC}"
}

# Export compliance report as markdown
# Usage: compliance_export_markdown output_file
compliance_export_markdown() {
    local output_file="$1"

    _compliance_init_proofs

    local score
    score=$(_compliance_calculate_score)

    local ts
    ts=$(_compliance_timestamp)

    {
        echo "# Compliance Report"
        echo ""
        echo "**Generated:** $ts"
        echo ""
        echo "## Compliance Score: ${score}%"
        echo ""
        echo "## Summary"
        echo ""
        echo "| Metric | Value |"
        echo "|--------|-------|"
        jq -r '.statistics | "| Total Checks | \(.total_checks) |"' "$COMPLIANCE_PROOFS"
        jq -r '.statistics | "| Passed | \(.passed) |"' "$COMPLIANCE_PROOFS"
        jq -r '.statistics | "| Failed | \(.failed) |"' "$COMPLIANCE_PROOFS"
        echo ""
        echo "## Checks by Category"
        echo ""
        jq -r '.statistics.by_category | to_entries[] | "- **\(.key)**: \(.value) checks"' "$COMPLIANCE_PROOFS"
        echo ""
        echo "## Detailed Checks"
        echo ""
        echo "| Category | Standard | Result | Details |"
        echo "|----------|----------|--------|---------|"
        jq -r '.checks[] | "| \(.category) | \(.standard) | \(.result) | \(.details) |"' "$COMPLIANCE_PROOFS"
    } > "$output_file"

    echo -e "${C_GREEN}Markdown report exported to: $output_file${C_NC}"
}

# Clear compliance data
# Usage: compliance_clear
compliance_clear() {
    if [[ -f "$COMPLIANCE_PROOFS" ]]; then
        rm "$COMPLIANCE_PROOFS"
    fi
    _compliance_init_proofs
    echo -e "${C_GREEN}Compliance data cleared${C_NC}"
}

# -----------------------------------------------------------------------------
# SELF TEST
# -----------------------------------------------------------------------------
_compliance_reporter_self_test() {
    echo -e "${C_CYAN}=== Compliance Reporter Self Test ===${C_NC}"

    local test_dir
    test_dir=$(mktemp -d)
    export HARMONY_DIR="$test_dir/.harmony"
    mkdir -p "$HARMONY_DIR/local/memory"

    local passed=0
    local failed=0

    # Test 1: Add check (passed)
    echo -n "Test 1: Add passed check... "
    compliance_add_check "security" "OWASP-1" "passed" "No vulnerabilities" >/dev/null
    local check_count
    check_count=$(jq '.checks | length' "$COMPLIANCE_PROOFS")
    if (( check_count == 1 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 2: Add check (failed)
    echo -n "Test 2: Add failed check... "
    compliance_add_check "quality" "Coverage" "failed" "Below threshold" >/dev/null
    local failed_count
    failed_count=$(jq '.statistics.failed' "$COMPLIANCE_PROOFS")
    if (( failed_count == 1 )); then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 3: Calculate score
    echo -n "Test 3: Calculate score... "
    local score
    score=$(_compliance_calculate_score)
    if (( score == 50 )); then  # 1 passed, 1 failed = 50%
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC} (got: $score)"
        ((failed++))
    fi

    # Test 4: Generate report
    echo -n "Test 4: Generate report... "
    local report
    report=$(compliance_generate_report "test-report" 2>&1)
    if [[ "$report" == *"compliance_score"* ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Test 5: Export markdown
    echo -n "Test 5: Export markdown... "
    compliance_export_markdown "$test_dir/report.md" >/dev/null
    if [[ -f "$test_dir/report.md" ]]; then
        echo -e "${C_GREEN}PASS${C_NC}"
        ((passed++))
    else
        echo -e "${C_RED}FAIL${C_NC}"
        ((failed++))
    fi

    # Cleanup
    rm -rf "$test_dir"
    unset HARMONY_DIR

    echo ""
    echo -e "Results: ${C_GREEN}$passed passed${C_NC}, ${C_RED}$failed failed${C_NC}"

    [[ $failed -eq 0 ]]
}

if [[ "${1:-}" == "--test" ]]; then
    _compliance_reporter_self_test
    exit $?
fi
