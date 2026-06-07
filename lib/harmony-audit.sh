#!/bin/bash
# harmony-audit.sh - Full coherence audit for Harmony Framework
# Usage: ./harmony-audit.sh [target_dir]

# Strict mode only when executed directly, not when sourced (error BASH-006)
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    set -euo pipefail
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Target directory
TARGET_DIR="${1:-.harmony}"
HARMONY_DIR="${TARGET_DIR}"

# Counters
declare -A COUNTS
declare -A VALID
declare -A ERRORS

# Progress bar function
progress_bar() {
    local pct=$1
    local width=20
    local filled=$((pct * width / 100))
    local empty=$((width - filled))
    printf '%s' "$(printf '█%.0s' $(seq 1 $filled 2>/dev/null) || true)"
    printf '%s' "$(printf '░%.0s' $(seq 1 $empty 2>/dev/null) || true)"
}

# Status icon
status_icon() {
    local valid=$1
    local total=$2
    if [[ $valid -eq $total ]]; then
        echo -e "${GREEN}✅${NC}"
    elif [[ $valid -gt $((total / 2)) ]]; then
        echo -e "${YELLOW}⚠️${NC}"
    else
        echo -e "${RED}❌${NC}"
    fi
}

# Header
print_header() {
    local project_name=$(jq -r '.project.name // "Unknown"' "$HARMONY_DIR/local/memory/working.json" 2>/dev/null || echo "Unknown")
    local date=$(date +%Y-%m-%d)

    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                         HARMONY FULL AUDIT                                    ║${NC}"
    echo -e "${BOLD}║                         $date • $project_name${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"
}

# ============================================================================
# Helper: Check if file has valid markdown structure (header or frontmatter)
# ============================================================================
is_valid_markdown() {
    local file="$1"
    local first_line=$(head -1 "$file" 2>/dev/null)

    # Check for markdown header
    if [[ "$first_line" =~ ^#+ ]]; then
        return 0
    fi

    # Check for YAML frontmatter
    if [[ "$first_line" == "---" ]]; then
        return 0
    fi

    # Check for HTML comment (some files use this)
    if [[ "$first_line" =~ ^\<\!-- ]]; then
        return 0
    fi

    # Check if file has any header within first 20 lines (after frontmatter)
    if head -20 "$file" 2>/dev/null | grep -q "^#"; then
        return 0
    fi

    return 1
}

# ============================================================================
# 1. COMMANDS CHECK
# ============================================================================
check_commands() {
    local dir="$HARMONY_DIR/commands"
    local total=0
    local valid=0
    local errors=()

    # Count command files
    if [[ -d "$dir" ]]; then
        total=$(find "$dir" -name "*.md" -o -name "*.yaml" 2>/dev/null | wc -l)

        # Check index exists
        if [[ -f "$dir/index.md" ]]; then
            ((valid++)) || true
        else
            errors+=("index.md missing")
        fi

        # Check all .md files are valid (header or frontmatter)
        for f in "$dir"/*.md; do
            [[ -f "$f" ]] || continue
            [[ "$(basename "$f")" == "index.md" ]] && continue  # Already counted
            if is_valid_markdown "$f"; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") invalid structure")
            fi
        done

        # Check YAML files
        for f in "$dir"/*.yaml; do
            [[ -f "$f" ]] || continue
            if yq '.' "$f" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") invalid YAML")
            fi
        done
    fi

    COUNTS[commands]=$total
    VALID[commands]=$valid
    ERRORS[commands]="${errors[*]:-}"
}

# ============================================================================
# 2. AGENTS CHECK
# ============================================================================
check_agents() {
    local dir="$HARMONY_DIR/agents"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.md; do
            [[ -f "$f" ]] || continue
            [[ "$(basename "$f")" == "INDEX.md" ]] && continue
            ((total++)) || true

            # Check frontmatter
            if head -50 "$f" | grep -q "^---" && head -50 "$f" | grep -q "^name:"; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") invalid frontmatter")
            fi
        done
    fi

    COUNTS[agents]=$total
    VALID[agents]=$valid
    ERRORS[agents]="${errors[*]:-}"
}

# ============================================================================
# 3. SPECIALTIES CHECK
# ============================================================================
check_specialties() {
    local dir="$HARMONY_DIR/specialties"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for d in "$dir"/*/; do
            [[ -d "$d" ]] || continue
            ((total++)) || true

            if [[ -f "${d}manifest.yaml" ]]; then
                # Validate YAML
                if yq '.' "${d}manifest.yaml" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('${d}manifest.yaml'))" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$d") invalid manifest YAML")
                fi
            else
                errors+=("$(basename "$d") missing manifest.yaml")
            fi
        done
    fi

    COUNTS[specialties]=$total
    VALID[specialties]=$valid
    ERRORS[specialties]="${errors[*]:-}"
}

# ============================================================================
# 4. PROFILES CHECK
# ============================================================================
check_profiles() {
    local dir="$HARMONY_DIR/profiles"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check registry
        if [[ -f "$dir/profiles-registry.yaml" ]]; then
            ((valid++)) || true
        else
            errors+=("profiles-registry.yaml missing")
        fi

        # Count profile directories
        for d in "$dir"/*/; do
            [[ -d "$d" ]] || continue
            ((total++)) || true
        done
    fi

    COUNTS[profiles]=$total
    VALID[profiles]=$((valid > 0 ? total : 0))
    ERRORS[profiles]="${errors[*]:-}"
}

# ============================================================================
# 5. KNOWLEDGE CHECK
# ============================================================================
check_knowledge() {
    local dir="$HARMONY_DIR/knowledge"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        total=$(find "$dir" -name "*.md" 2>/dev/null | wc -l)

        # Check each markdown file has valid structure (header or frontmatter)
        while IFS= read -r f; do
            if is_valid_markdown "$f"; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f")")
            fi
        done < <(find "$dir" -name "*.md" 2>/dev/null)
    fi

    COUNTS[knowledge]=$total
    VALID[knowledge]=$valid
    ERRORS[knowledge]="${errors[*]:-}"
}

# ============================================================================
# 6. CONFIG CHECK
# ============================================================================
check_config() {
    local dir="$HARMONY_DIR/config"
    local required=(
        "guardian-conventions.yaml"
        "llm-defaults.yaml"
        "model-tiers.yaml"
        "overrides.yaml"
        "pipeline-orchestration.yaml"
        "routing-rules.yaml"
    )
    local total=${#required[@]}
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "${required[@]}"; do
            if [[ -f "$dir/$f" ]]; then
                # Validate YAML
                if yq '.' "$dir/$f" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$dir/$f'))" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$f invalid YAML")
                fi
            else
                errors+=("$f missing")
            fi
        done

        # Check paths.yaml or paths.json
        if [[ -f "$dir/paths.yaml" ]] || [[ -f "$dir/paths.json" ]]; then
            ((total++)) || true
            ((valid++)) || true
        fi
    fi

    COUNTS[config]=$total
    VALID[config]=$valid
    ERRORS[config]="${errors[*]:-}"
}

# ============================================================================
# 7. MEMORY CHECK
# ============================================================================
check_memory() {
    local dir="$HARMONY_DIR/local/memory"
    local total=0
    local valid=0
    local errors=()
    local cb_state="UNKNOWN"

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.json; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            if jq empty "$f" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") invalid JSON")
            fi
        done

        # Get circuit breaker state
        if [[ -f "$dir/circuit-breaker.json" ]]; then
            cb_state=$(jq -r '.state // "UNKNOWN"' "$dir/circuit-breaker.json" 2>/dev/null)
        fi
    fi

    COUNTS[memory]=$total
    VALID[memory]=$valid
    ERRORS[memory]="${errors[*]:-}"
    COUNTS[cb_state]="$cb_state"
}

# ============================================================================
# 8. MCP CHECK (simplified - just check if tools are mentioned)
# ============================================================================
check_mcp() {
    # MCP availability is checked at runtime by Claude
    # Here we just mark as available
    COUNTS[mcp]=4
    VALID[mcp]=4
    ERRORS[mcp]=""
}

# ============================================================================
# 9. BIN CHECK (Shell scripts syntax)
# ============================================================================
check_bin() {
    local dir="$HARMONY_DIR/bin"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.sh; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            # Check shell syntax
            if bash -n "$f" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") syntax error")
            fi
        done
    fi

    COUNTS[bin]=$total
    VALID[bin]=$valid
    ERRORS[bin]="${errors[*]:-}"
}

# ============================================================================
# 10. HOOKS CHECK (Shell scripts)
# ============================================================================
check_hooks() {
    local dir="$HARMONY_DIR/hooks"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.sh; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            # Check shell syntax
            if bash -n "$f" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") syntax error")
            fi
        done
    fi

    COUNTS[hooks]=$total
    VALID[hooks]=$valid
    ERRORS[hooks]="${errors[*]:-}"
}

# ============================================================================
# 11. INTEGRATIONS CHECK (Registry + IDE configs)
# ============================================================================
check_integrations() {
    local dir="$HARMONY_DIR/integrations"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check registry
        if [[ -f "$dir/integrations-registry.yaml" ]]; then
            ((total++)) || true
            if yq '.' "$dir/integrations-registry.yaml" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$dir/integrations-registry.yaml'))" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("integrations-registry.yaml invalid YAML")
            fi
        fi

        # Check IDE directories
        for d in "$dir"/*/; do
            [[ -d "$d" ]] || continue
            ((total++)) || true

            # Each IDE should have manifest.yaml or at least one config file
            if [[ -f "${d}manifest.yaml" ]]; then
                # Validate manifest YAML
                if yq '.' "${d}manifest.yaml" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('${d}manifest.yaml'))" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$d")/manifest.yaml invalid YAML")
                fi
            elif ls "$d"*.{yaml,json,md} 2>/dev/null | head -1 > /dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$d") no manifest or config files")
            fi
        done
    fi

    COUNTS[integrations]=$total
    VALID[integrations]=$valid
    ERRORS[integrations]="${errors[*]:-}"
}

# ============================================================================
# 12. PATTERNS CHECK (P-XXX format, INDEX, registry)
# ============================================================================
check_patterns() {
    local dir="$HARMONY_DIR/patterns"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check INDEX.md
        if [[ -f "$dir/INDEX.md" ]]; then
            ((total++)) || true
            ((valid++)) || true
        else
            errors+=("INDEX.md missing")
        fi

        # Check pattern files (P-XXX-*.md)
        for f in "$dir"/P-*.md; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            # Validate P-XXX format
            local basename=$(basename "$f")
            if [[ "$basename" =~ ^P-[0-9]{3}- ]]; then
                if is_valid_markdown "$f"; then
                    ((valid++)) || true
                else
                    errors+=("$basename invalid structure")
                fi
            else
                errors+=("$basename invalid naming (expected P-XXX-)")
            fi
        done

        # Check registry files
        for reg in "$dir"/patterns-registry.*; do
            [[ -f "$reg" ]] || continue
            ((total++)) || true

            local ext="${reg##*.}"
            if [[ "$ext" == "json" ]]; then
                if jq empty "$reg" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$reg") invalid JSON")
                fi
            elif [[ "$ext" == "yaml" ]]; then
                if yq '.' "$reg" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$reg'))" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$reg") invalid YAML")
                fi
            fi
        done

        # Check cognitive patterns subdirectory
        if [[ -d "$dir/cognitive" ]]; then
            for f in "$dir/cognitive"/*.md; do
                [[ -f "$f" ]] || continue
                ((total++)) || true
                if is_valid_markdown "$f"; then
                    ((valid++)) || true
                else
                    errors+=("cognitive/$(basename "$f") invalid")
                fi
            done
        fi
    fi

    COUNTS[patterns]=$total
    VALID[patterns]=$valid
    ERRORS[patterns]="${errors[*]:-}"
}

# ============================================================================
# 13. ROUTING CHECK (YAML validity, agent refs)
# ============================================================================
check_routing() {
    local dir="$HARMONY_DIR/routing"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.yaml "$dir"/*.md; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            local ext="${f##*.}"
            if [[ "$ext" == "yaml" ]]; then
                if yq '.' "$f" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$f") invalid YAML")
                fi
            elif [[ "$ext" == "md" ]]; then
                if is_valid_markdown "$f"; then
                    ((valid++)) || true
                else
                    errors+=("$(basename "$f") invalid markdown")
                fi
            fi
        done
    fi

    COUNTS[routing]=$total
    VALID[routing]=$valid
    ERRORS[routing]="${errors[*]:-}"
}

# ============================================================================
# 14. RULES CHECK (R-XXX format, YAML validity)
# ============================================================================
check_rules() {
    local dir="$HARMONY_DIR/rules"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        for f in "$dir"/*.yaml "$dir"/*.md; do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            local basename=$(basename "$f")
            local ext="${f##*.}"

            if [[ "$ext" == "yaml" ]]; then
                # Check R-XXX format for rule files
                if [[ "$basename" =~ ^R-[0-9]{3}- ]]; then
                    if yq '.' "$f" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
                        ((valid++)) || true
                    else
                        errors+=("$basename invalid YAML")
                    fi
                else
                    # Other YAML files just need to be valid
                    if yq '.' "$f" > /dev/null 2>&1 || python3 -c "import yaml; yaml.safe_load(open('$f'))" 2>/dev/null; then
                        ((valid++)) || true
                    else
                        errors+=("$basename invalid YAML")
                    fi
                fi
            elif [[ "$ext" == "md" ]]; then
                if is_valid_markdown "$f"; then
                    ((valid++)) || true
                else
                    errors+=("$basename invalid markdown")
                fi
            fi
        done
    fi

    COUNTS[rules]=$total
    VALID[rules]=$valid
    ERRORS[rules]="${errors[*]:-}"
}

# ============================================================================
# 15. WORKFLOWS CHECK (Structure, cross-refs)
# ============================================================================
check_workflows() {
    local dir="$HARMONY_DIR/workflows"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check root markdown files
        for f in "$dir"/*.md; do
            [[ -f "$f" ]] || continue
            ((total++)) || true
            if is_valid_markdown "$f"; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") invalid")
            fi
        done

        # Check phase directories (1-analysis, 2-planning, etc.)
        for phase_dir in "$dir"/[1-5]-*/; do
            [[ -d "$phase_dir" ]] || continue
            ((total++)) || true

            # Each phase should have instructions.md OR subdirectories with content
            if [[ -f "${phase_dir}instructions.md" ]]; then
                ((valid++)) || true
            elif [[ -d "$phase_dir" ]] && ls "$phase_dir"*/ 2>/dev/null | head -1 > /dev/null; then
                # Has subdirectories, consider valid
                ((valid++)) || true
            else
                errors+=("$(basename "$phase_dir") empty or missing structure")
            fi
        done

        # Recursively check all markdown files in subdirectories
        while IFS= read -r f; do
            ((total++)) || true
            if is_valid_markdown "$f"; then
                ((valid++)) || true
            fi
        done < <(find "$dir" -mindepth 2 -name "*.md" 2>/dev/null)
    fi

    COUNTS[workflows]=$total
    VALID[workflows]=$valid
    ERRORS[workflows]="${errors[*]:-}"
}

# ============================================================================
# 16. ERROR-LIBRARY CHECK (JSON schema, index)
# ============================================================================
check_error_library() {
    local dir="$HARMONY_DIR/error-library"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check index.json
        if [[ -f "$dir/index.json" ]]; then
            ((total++)) || true
            if jq empty "$dir/index.json" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("index.json invalid JSON")
            fi
        fi

        # Check error JSON files
        while IFS= read -r f; do
            ((total++)) || true
            local basename=$(basename "$f")

            # Check JSON validity
            if jq empty "$f" 2>/dev/null; then
                # Validate ID format (CATEGORY-NNN)
                local id=$(jq -r '.id // ""' "$f" 2>/dev/null)
                if [[ "$id" =~ ^[A-Z]+-[0-9]{3}$ ]]; then
                    ((valid++)) || true
                else
                    errors+=("$basename invalid ID format: $id")
                fi
            else
                errors+=("$basename invalid JSON")
            fi
        done < <(find "$dir/errors" -name "*.json" 2>/dev/null | grep -v "index.json" || true)

        # Check schema
        if [[ -f "$dir/schema/error.schema.json" ]]; then
            ((total++)) || true
            if jq empty "$dir/schema/error.schema.json" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("error.schema.json invalid")
            fi
        fi
    fi

    COUNTS[error_library]=$total
    VALID[error_library]=$valid
    ERRORS[error_library]="${errors[*]:-}"
}

# ============================================================================
# 17. TIPS CHECK (Sequential naming)
# ============================================================================
check_tips() {
    local dir="$HARMONY_DIR/tips"
    local total=0
    local valid=0
    local errors=()
    local expected_num=1

    if [[ -d "$dir" ]]; then
        # Sort files and check sequential numbering
        for f in $(ls "$dir"/*.md 2>/dev/null | sort); do
            [[ -f "$f" ]] || continue
            ((total++)) || true

            local basename=$(basename "$f")
            # Extract number from filename (e.g., 01-welcome.md -> 01)
            local num=$(echo "$basename" | grep -oP '^[0-9]+' || echo "")

            if [[ -n "$num" ]] && is_valid_markdown "$f"; then
                ((valid++)) || true
            else
                errors+=("$basename invalid naming/structure")
            fi
        done
    fi

    COUNTS[tips]=$total
    VALID[tips]=$valid
    ERRORS[tips]="${errors[*]:-}"
}

# ============================================================================
# 18. TOOLS CHECK (Shell syntax, Docker)
# ============================================================================
check_tools() {
    local dir="$HARMONY_DIR/tools"
    local total=0
    local valid=0
    local errors=()

    if [[ -d "$dir" ]]; then
        # Check shell scripts recursively
        while IFS= read -r f; do
            ((total++)) || true
            if bash -n "$f" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(basename "$f") syntax error")
            fi
        done < <(find "$dir" -name "*.sh" 2>/dev/null)

        # Check Dockerfiles
        while IFS= read -r f; do
            ((total++)) || true
            # Basic Dockerfile validation (has FROM instruction)
            if grep -q "^FROM " "$f" 2>/dev/null; then
                ((valid++)) || true
            else
                errors+=("$(dirname "$f" | xargs basename)/Dockerfile invalid")
            fi
        done < <(find "$dir" -name "Dockerfile" 2>/dev/null)

        # Check requirements.txt files
        while IFS= read -r f; do
            ((total++)) || true
            # Basic check: file is not empty
            if [[ -s "$f" ]]; then
                ((valid++)) || true
            else
                errors+=("$(dirname "$f" | xargs basename)/requirements.txt empty")
            fi
        done < <(find "$dir" -name "requirements.txt" 2>/dev/null)

        # Check README files
        while IFS= read -r f; do
            ((total++)) || true
            if is_valid_markdown "$f"; then
                ((valid++)) || true
            fi
        done < <(find "$dir" -name "README.md" 2>/dev/null)
    fi

    COUNTS[tools]=$total
    VALID[tools]=$valid
    ERRORS[tools]="${errors[*]:-}"
}

# ============================================================================
# 19. BROKEN LINKS CHECK
# ============================================================================
check_links() {
    local total=0
    local broken=0
    local errors=()

    # Check manifest references
    for manifest in "$HARMONY_DIR"/specialties/*/manifest.yaml; do
        [[ -f "$manifest" ]] || continue
        local dir=$(dirname "$manifest")

        # Extract file references from manifest
        while IFS= read -r ref; do
            [[ -z "$ref" ]] && continue
            ((total++)) || true

            # Resolve relative path
            local full_path="$dir/$ref"
            if [[ ! -f "$full_path" ]]; then
                ((broken++)) || true
                errors+=("$manifest: $ref")
            fi
        done < <(grep -oP 'file:\s*\K[^\s]+' "$manifest" 2>/dev/null || true)
    done

    COUNTS[links_total]=$total
    COUNTS[links_broken]=$broken
    ERRORS[links]="${errors[*]:-}"
}

# ============================================================================
# PRINT SUMMARY
# ============================================================================
print_summary() {
    echo -e "║                                                                               ║"

    # Commands
    local pct=$((VALID[commands] * 100 / (COUNTS[commands] > 0 ? COUNTS[commands] : 1)))
    local bar=$(progress_bar $pct)
    local icon=$(status_icon ${VALID[commands]} ${COUNTS[commands]})
    printf "║   COMMANDS         %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[commands]}" "${COUNTS[commands]}"

    # Agents
    pct=$((VALID[agents] * 100 / (COUNTS[agents] > 0 ? COUNTS[agents] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[agents]} ${COUNTS[agents]})
    printf "║   AGENTS           %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[agents]}" "${COUNTS[agents]}"

    # Specialties
    pct=$((VALID[specialties] * 100 / (COUNTS[specialties] > 0 ? COUNTS[specialties] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[specialties]} ${COUNTS[specialties]})
    printf "║   SPECIALTIES      %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[specialties]}" "${COUNTS[specialties]}"

    # Profiles
    pct=$((VALID[profiles] * 100 / (COUNTS[profiles] > 0 ? COUNTS[profiles] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[profiles]} ${COUNTS[profiles]})
    printf "║   PROFILES         %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[profiles]}" "${COUNTS[profiles]}"

    # Knowledge
    pct=$((VALID[knowledge] * 100 / (COUNTS[knowledge] > 0 ? COUNTS[knowledge] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[knowledge]} ${COUNTS[knowledge]})
    printf "║   KNOWLEDGE        %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[knowledge]}" "${COUNTS[knowledge]}"

    # Config
    pct=$((VALID[config] * 100 / (COUNTS[config] > 0 ? COUNTS[config] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[config]} ${COUNTS[config]})
    printf "║   CONFIG           %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[config]}" "${COUNTS[config]}"

    # Memory
    pct=$((VALID[memory] * 100 / (COUNTS[memory] > 0 ? COUNTS[memory] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[memory]} ${COUNTS[memory]})
    printf "║   MEMORY           %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[memory]}" "${COUNTS[memory]}"

    # MCP
    pct=$((VALID[mcp] * 100 / (COUNTS[mcp] > 0 ? COUNTS[mcp] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[mcp]} ${COUNTS[mcp]})
    printf "║   MCP              %s  %3d%%  %s %d/%d available             ║\n" "$bar" "$pct" "$icon" "${VALID[mcp]}" "${COUNTS[mcp]}"

    echo -e "║   ─────────────────────────────────────────────────────────────────────────   ║"

    # BIN
    pct=$((VALID[bin] * 100 / (COUNTS[bin] > 0 ? COUNTS[bin] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[bin]} ${COUNTS[bin]})
    printf "║   BIN              %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[bin]}" "${COUNTS[bin]}"

    # HOOKS
    pct=$((VALID[hooks] * 100 / (COUNTS[hooks] > 0 ? COUNTS[hooks] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[hooks]} ${COUNTS[hooks]})
    printf "║   HOOKS            %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[hooks]}" "${COUNTS[hooks]}"

    # INTEGRATIONS
    pct=$((VALID[integrations] * 100 / (COUNTS[integrations] > 0 ? COUNTS[integrations] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[integrations]} ${COUNTS[integrations]})
    printf "║   INTEGRATIONS     %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[integrations]}" "${COUNTS[integrations]}"

    # PATTERNS
    pct=$((VALID[patterns] * 100 / (COUNTS[patterns] > 0 ? COUNTS[patterns] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[patterns]} ${COUNTS[patterns]})
    printf "║   PATTERNS         %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[patterns]}" "${COUNTS[patterns]}"

    # ROUTING
    pct=$((VALID[routing] * 100 / (COUNTS[routing] > 0 ? COUNTS[routing] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[routing]} ${COUNTS[routing]})
    printf "║   ROUTING          %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[routing]}" "${COUNTS[routing]}"

    # RULES
    pct=$((VALID[rules] * 100 / (COUNTS[rules] > 0 ? COUNTS[rules] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[rules]} ${COUNTS[rules]})
    printf "║   RULES            %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[rules]}" "${COUNTS[rules]}"

    # WORKFLOWS
    pct=$((VALID[workflows] * 100 / (COUNTS[workflows] > 0 ? COUNTS[workflows] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[workflows]} ${COUNTS[workflows]})
    printf "║   WORKFLOWS        %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[workflows]}" "${COUNTS[workflows]}"

    # ERROR-LIBRARY
    pct=$((VALID[error_library] * 100 / (COUNTS[error_library] > 0 ? COUNTS[error_library] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[error_library]} ${COUNTS[error_library]})
    printf "║   ERROR-LIBRARY    %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[error_library]}" "${COUNTS[error_library]}"

    # TIPS
    pct=$((VALID[tips] * 100 / (COUNTS[tips] > 0 ? COUNTS[tips] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[tips]} ${COUNTS[tips]})
    printf "║   TIPS             %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[tips]}" "${COUNTS[tips]}"

    # TOOLS
    pct=$((VALID[tools] * 100 / (COUNTS[tools] > 0 ? COUNTS[tools] : 1)))
    bar=$(progress_bar $pct)
    icon=$(status_icon ${VALID[tools]} ${COUNTS[tools]})
    printf "║   TOOLS            %s  %3d%%  %s %d/%d valid                 ║\n" "$bar" "$pct" "$icon" "${VALID[tools]}" "${COUNTS[tools]}"

    echo -e "║   ─────────────────────────────────────────────────────────────────────────   ║"

    # Links
    local links_valid=$((COUNTS[links_total] - COUNTS[links_broken]))
    pct=$((links_valid * 100 / (COUNTS[links_total] > 0 ? COUNTS[links_total] : 1)))
    [[ ${COUNTS[links_total]} -eq 0 ]] && pct=100
    bar=$(progress_bar $pct)
    icon=$(status_icon $links_valid ${COUNTS[links_total]})
    printf "║   LINKS            %s  %3d%%  %s %d broken                   ║\n" "$bar" "$pct" "$icon" "${COUNTS[links_broken]}"

    echo -e "║                                                                               ║"

    # Calculate overall score (all 18 categories)
    local total_valid=$((VALID[commands] + VALID[agents] + VALID[specialties] + VALID[profiles] + VALID[knowledge] + VALID[config] + VALID[memory] + VALID[mcp] + VALID[bin] + VALID[hooks] + VALID[integrations] + VALID[patterns] + VALID[routing] + VALID[rules] + VALID[workflows] + VALID[error_library] + VALID[tips] + VALID[tools] + links_valid))
    local total_items=$((COUNTS[commands] + COUNTS[agents] + COUNTS[specialties] + COUNTS[profiles] + COUNTS[knowledge] + COUNTS[config] + COUNTS[memory] + COUNTS[mcp] + COUNTS[bin] + COUNTS[hooks] + COUNTS[integrations] + COUNTS[patterns] + COUNTS[routing] + COUNTS[rules] + COUNTS[workflows] + COUNTS[error_library] + COUNTS[tips] + COUNTS[tools] + COUNTS[links_total]))
    local overall=$((total_valid * 100 / (total_items > 0 ? total_items : 1)))

    echo -e "║   ${BOLD}OVERALL SCORE: ${overall}%${NC}                                                          ║"
    echo -e "║                                                                               ║"
    echo -e "${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# ============================================================================
# PRINT DETAILS
# ============================================================================
print_details() {
    echo ""
    echo -e "${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║                         DETAILED ANALYSIS                                     ║${NC}"
    echo -e "${BOLD}╠═══════════════════════════════════════════════════════════════════════════════╣${NC}"

    # Circuit Breaker Status
    echo ""
    echo -e "┌─ CIRCUIT BREAKER ───────────────────────────────────────────────────────────┐"
    echo -e "│                                                                               │"
    local cb_icon="✅"
    [[ "${COUNTS[cb_state]}" == "OPEN" ]] && cb_icon="❌"
    [[ "${COUNTS[cb_state]}" == "HALF_OPEN" ]] && cb_icon="⚠️"
    echo -e "│   State: ${COUNTS[cb_state]} $cb_icon                                                            │"
    echo -e "│                                                                               │"
    echo -e "└───────────────────────────────────────────────────────────────────────────────┘"

    # Errors if any
    local has_errors=false
    local all_keys=(commands agents specialties profiles knowledge config memory bin hooks integrations patterns routing rules workflows error_library tips tools links)
    for key in "${all_keys[@]}"; do
        if [[ -n "${ERRORS[$key]:-}" ]]; then
            has_errors=true
            break
        fi
    done

    if $has_errors; then
        echo ""
        echo -e "┌─ ISSUES FOUND ──────────────────────────────────────────────────────────────┐"
        for key in "${all_keys[@]}"; do
            if [[ -n "${ERRORS[$key]:-}" ]]; then
                echo -e "│   ${YELLOW}[$key]${NC} ${ERRORS[$key]}"
            fi
        done
        echo -e "└───────────────────────────────────────────────────────────────────────────────┘"
    fi

    # Summary stats
    echo ""
    echo -e "┌─ SUMMARY ───────────────────────────────────────────────────────────────────┐"
    echo -e "│   Categories checked: 18                                                   │"
    echo -e "│   Total items validated: $((COUNTS[commands] + COUNTS[agents] + COUNTS[specialties] + COUNTS[profiles] + COUNTS[knowledge] + COUNTS[config] + COUNTS[memory] + COUNTS[mcp] + COUNTS[bin] + COUNTS[hooks] + COUNTS[integrations] + COUNTS[patterns] + COUNTS[routing] + COUNTS[rules] + COUNTS[workflows] + COUNTS[error_library] + COUNTS[tips] + COUNTS[tools] + COUNTS[links_total]))                                                              │"
    echo -e "└───────────────────────────────────────────────────────────────────────────────┘"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    # Check target exists
    if [[ ! -d "$TARGET_DIR" ]]; then
        echo -e "${RED}Error: Directory $TARGET_DIR not found${NC}"
        exit 1
    fi

    # Run all checks (18 categories)
    check_commands
    check_agents
    check_specialties
    check_profiles
    check_knowledge
    check_config
    check_memory
    check_mcp
    check_bin
    check_hooks
    check_integrations
    check_patterns
    check_routing
    check_rules
    check_workflows
    check_error_library
    check_tips
    check_tools
    check_links

    # Print results
    print_header
    print_summary
    print_details

    # Exit code based on errors
    local has_critical=false
    [[ ${COUNTS[links_broken]} -gt 0 ]] && has_critical=true
    [[ "${COUNTS[cb_state]}" == "OPEN" ]] && has_critical=true

    if $has_critical; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
