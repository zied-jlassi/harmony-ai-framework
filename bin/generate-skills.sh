#!/usr/bin/env bash
# ============================================================================
# generate-skills.sh - Generate Claude Code Skills for Harmony Agents
# ============================================================================
# Creates .claude/skills/ with advanced features:
#   - context: fork (isolated execution)
#   - agent: opus/sonnet/haiku (model routing)
#   - allowed-tools (tool restrictions)
#   - hooks (per-agent validation)
#
# Usage: ./generate-skills.sh [harmony_dir]
# ============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARMONY_DIR="${1:-.harmony}"
SKILLS_DIR=".claude/skills"

# Agents that benefit from skills (isolation, restrictions)
# These agents get: context: fork, allowed-tools, hooks
declare -A SKILL_AGENTS=(
    ["rgpd"]="compliance"
    ["security"]="compliance"
    ["pentest"]="compliance"
    ["architect"]="design"
    ["ucv"]="compliance"
    ["tester"]="implementation"
    ["review"]="compliance"
)

# Model mapping from agent file's model: field
resolve_agent_model() {
    local model_key="$1"
    case "$model_key" in
        model_1|opus) echo "opus" ;;
        model_2|sonnet) echo "sonnet" ;;
        model_3|haiku) echo "haiku" ;;
        inherit|*) echo "sonnet" ;;
    esac
}

# Get allowed tools based on agent type
get_allowed_tools_yaml() {
    local agent_name="$1"
    local agent_type="$2"
    local tools=""

    case "$agent_type" in
        compliance)
            # Read-only for compliance agents (except tester)
            if [[ "$agent_name" == "pentest" ]]; then
                tools="Read Grep Glob Bash(nmap:*) Bash(curl:*) Bash(dig:*)"
            else
                tools="Read Grep Glob WebSearch WebFetch"
            fi
            ;;
        design)
            # Architects can use most tools
            tools="Read Grep Glob Write Edit Bash WebSearch WebFetch"
            ;;
        implementation)
            # Full access for implementation agents
            tools="Read Grep Glob Write Edit Bash WebSearch WebFetch"
            ;;
        *)
            tools="Read Grep Glob"
            ;;
    esac

    # Output YAML list format
    for tool in $tools; do
        echo "  - $tool"
    done
}

# Get hooks based on agent type
get_hooks_yaml() {
    local agent_name="$1"
    local agent_type="$2"

    case "$agent_type" in
        compliance)
            if [[ "$agent_name" != "tester" ]]; then
                cat << 'HOOKS'
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      command: "echo '[Harmony] Compliance agent: write operations blocked for audit integrity' && exit 1"
  Stop:
    - command: "echo '[Harmony] Compliance audit completed for $AGENT_NAME'"
      once: true
HOOKS
            else
                echo "# No write restrictions for tester"
            fi
            ;;
        *)
            echo "# Standard agent, no special hooks"
            ;;
    esac
}

# Generate a single skill file
generate_skill() {
    local agent_name="$1"
    local agent_type="$2"
    local agent_file="${HARMONY_DIR}/agents/${agent_name}.md"

    # Skip if agent file doesn't exist
    if [[ ! -f "$agent_file" ]]; then
        echo "  [SKIP] Agent file not found: $agent_file"
        return 0
    fi

    # Extract model from agent file
    local model_key
    model_key=$(grep -m1 "^model:" "$agent_file" 2>/dev/null | sed 's/model:[[:space:]]*//' || echo "inherit")
    local agent_model
    agent_model=$(resolve_agent_model "$model_key")

    # Extract description from agent file
    local description
    description=$(grep -m1 "^description:" "$agent_file" 2>/dev/null | sed 's/description:[[:space:]]*//' || echo "Harmony ${agent_name} agent")

    # Get allowed tools (YAML format)
    local allowed_tools_yaml
    allowed_tools_yaml=$(get_allowed_tools_yaml "$agent_name" "$agent_type")

    # Get hooks
    local hooks_yaml
    hooks_yaml=$(get_hooks_yaml "$agent_name" "$agent_type")

    # Generate skill file
    local skill_file="${SKILLS_DIR}/hf-agent-${agent_name}.md"

    cat > "$skill_file" << EOF
---
name: hf:agent:${agent_name}
description: ${description}
context: fork
agent: ${agent_model}
allowed-tools:
${allowed_tools_yaml}
${hooks_yaml}
---

# Harmony Agent: ${agent_name^}

You are operating as the **${agent_name^}** agent from the Harmony Framework.

## Instructions

Read and strictly follow the agent definition:
\`\`\`
@${HARMONY_DIR}/agents/${agent_name}.md
\`\`\`

## Current Task

\$ARGUMENTS

## Working Context

If a story is active, check:
\`\`\`
@${HARMONY_DIR}/memory/working.json
\`\`\`

## Output Guidelines

1. Follow the agent's specific output format
2. Be thorough but concise
3. Flag any issues found with severity levels
4. Provide actionable recommendations
EOF

    echo "  [OK] Generated: $skill_file (model: $agent_model, type: $agent_type)"
}

# Main
main() {
    echo "=============================================="
    echo " Harmony Skills Generator"
    echo "=============================================="
    echo ""
    echo "Target: $SKILLS_DIR"
    echo "Agents: ${!SKILL_AGENTS[*]}"
    echo ""

    # Create skills directory
    mkdir -p "$SKILLS_DIR"

    # Generate skills for each agent
    echo "Generating skills..."
    echo ""

    for agent_name in "${!SKILL_AGENTS[@]}"; do
        agent_type="${SKILL_AGENTS[$agent_name]}"
        generate_skill "$agent_name" "$agent_type"
    done

    echo ""
    echo "=============================================="
    echo " Skills generated successfully!"
    echo "=============================================="
    echo ""
    echo "Skills location: $SKILLS_DIR/"
    echo ""
    echo "Features enabled:"
    echo "  - context: fork (isolated execution)"
    echo "  - agent: opus/sonnet/haiku (model routing)"
    echo "  - allowed-tools (per-agent restrictions)"
    echo "  - hooks (compliance validation)"
    echo ""
    echo "Usage: /hf:agent:<name> <task>"
    echo "Example: /hf:agent:rgpd Review user data handling"
    echo ""
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
