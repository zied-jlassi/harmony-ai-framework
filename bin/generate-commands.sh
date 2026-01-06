#!/bin/bash
# Harmony Framework - Generate Claude Code Commands
# Generates .claude/commands/*.md from framework/commands/*.yaml
# Format: Compact YAML frontmatter with name + description

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(dirname "$SCRIPT_DIR")"
COMMANDS_DIR="$FRAMEWORK_DIR/commands"
TARGET_DIR="${1:-.claude/commands}"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         HARMONY - Generate Claude Code Commands                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Source: $COMMANDS_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Create target directory
mkdir -p "$TARGET_DIR"

# Function to generate agent command (compact format)
# Args: name, path, description
generate_agent_command() {
    local name="$1"
    local path="$2"
    local description="$3"

    local filename="hf-agent-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:agent:${name}"
description: "${description}"
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF

    echo "  ✅ $filename"
}

# Function to generate workflow command (compact format)
generate_workflow_command() {
    local name="$1"
    local path="$2"
    local description="$3"

    local filename="hf-workflow-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:workflow:${name}"
description: "${description}"
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF

    echo "  ✅ $filename"
}

# Function to generate testarch command (compact format)
generate_testarch_command() {
    local name="$1"
    local path="$2"
    local description="$3"

    local filename="hf-testarch-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:testarch:${name}"
description: "${description}"
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF

    echo "  ✅ $filename"
}

# Function to generate diagram command (compact format)
generate_diagram_command() {
    local name="$1"
    local path="$2"
    local description="$3"

    local filename="hf-diagram-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:diagram:${name}"
description: "${description}"
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF

    echo "  ✅ $filename"
}

# ============================================================
# Generate Core Commands (special format, not /hf:*:*)
# ============================================================
echo "=== Generating Core Commands ==="

# /go command
cat > "$TARGET_DIR/go.md" << 'EOF'
---
name: "/go"
description: "GO - Session Kickoff - Initialize session with project context"
---
Load and execute the go command from `${HARMONY_DIR}/commands/go.md`.

Arguments: $ARGUMENTS
EOF
echo "  ✅ go.md"

# /harmony command
cat > "$TARGET_DIR/harmony.md" << 'EOF'
---
name: "/harmony"
description: "Harmony Framework - 30 commands: validation, sentinel, profiles, ucv..."
---
If no arg: Read `${HARMONY_DIR}/commands/index.md`
If arg: Read `${HARMONY_DIR}/commands/$ARGUMENTS.md`
EOF
echo "  ✅ harmony.md"

# /sentinel command
cat > "$TARGET_DIR/sentinel.md" << 'EOF'
---
name: "/sentinel"
description: "Harmony Sentinel - Auto-Learning Error Memory"
---
Read `${HARMONY_DIR}/commands/sentinel.md`
Args: $ARGUMENTS
EOF
echo "  ✅ sentinel.md"

# ============================================================
# Generate Agent Commands (/hf:agent:*)
# ============================================================
echo ""
echo "=== Generating Agent Commands ==="
if [[ -f "$COMMANDS_DIR/agents.yaml" ]]; then
    # Core Agents
    generate_agent_command "dev" "agents/developer.md" "Expert full-stack developer - TDD, Clean Architecture"
    generate_agent_command "architect" "agents/architect.md" "Software architect - system design, ADRs, decisions"
    generate_agent_command "analyst" "agents/analyst.md" "Business analyst - requirements, briefs, PRD"
    generate_agent_command "tester" "agents/tester.md" "QA engineer - test strategy, automation, coverage"
    generate_agent_command "sm" "agents/scrum-master.md" "Scrum Master - stories, sprints, planning, INVEST"

    # Specialist Agents
    generate_agent_command "ai-architect" "agents/ai-architect.md" "AI/LLM architect - RAG, multi-agent, memory"
    generate_agent_command "exploratory-qa" "agents/exploratory-qa.md" "Exploratory QA - manual testing, UX validation"
    generate_agent_command "ucv-writer" "specialties/ucv/branchs/writer.md" "UCV Writer - creates Use Case Verifiables"
    generate_agent_command "ucv-validator" "specialties/ucv/branchs/validator.md" "UCV Validator - validates 100% UCV coverage"
    generate_agent_command "ucv-qa" "specialties/ucv/branchs/qa.md" "UCV QA - manual browser validation (HQVF)"

    # Compliance Agents
    generate_agent_command "accessibility" "agents/accessibility.md" "Accessibility auditor - WCAG/RGAA/EAA"
    generate_agent_command "security" "agents/security.md" "Security auditor - OWASP Top 10"
    generate_agent_command "rgpd" "agents/rgpd.md" "RGPD/GDPR compliance auditor"
    generate_agent_command "pentest" "agents/pentest.md" "Penetration testing agent"

    # Additional Core Agents
    generate_agent_command "ux" "agents/ux-designer.md" "UX Designer - wireframes, user flows"
    generate_agent_command "pm" "agents/product-manager.md" "Product Manager - roadmap, priorities"
    generate_agent_command "docs" "agents/tech-writer.md" "Tech Writer - documentation, guides"
    generate_agent_command "review" "agents/review.md" "Code Reviewer - code review, best practices"
fi

# ============================================================
# Generate Workflow Commands (/hf:workflow:*)
# ============================================================
echo ""
echo "=== Generating Workflow Commands ==="
if [[ -f "$COMMANDS_DIR/workflows.yaml" ]]; then
    generate_workflow_command "dev-story" "workflows/4-implementation/dev-story/workflow.yaml" "Complete story development workflow"
    generate_workflow_command "create-story" "workflows/4-implementation/create-story/workflow.yaml" "Create a new story with acceptance criteria"
    generate_workflow_command "code-review" "workflows/4-implementation/code-review/workflow.yaml" "Code review workflow"
    generate_workflow_command "sprint-planning" "workflows/4-implementation/sprint-planning/workflow.yaml" "Sprint planning session"
    generate_workflow_command "sprint-status" "workflows/4-implementation/sprint-status/workflow.yaml" "Sprint status report"
    generate_workflow_command "retrospective" "workflows/4-implementation/retrospective/workflow.yaml" "Sprint retrospective"
    generate_workflow_command "status" "workflows/workflow-status/workflow.yaml" "Show current workflow status"
    generate_workflow_command "init" "workflows/workflow-status/init/workflow.yaml" "Initialize Harmony workflow"
fi

# ============================================================
# Generate TestArch Commands (/hf:testarch:*)
# ============================================================
echo ""
echo "=== Generating TestArch Commands ==="
if [[ -f "$COMMANDS_DIR/testarch.yaml" ]]; then
    generate_testarch_command "framework" "workflows/testarch/framework/workflow.yaml" "Initialize production-ready test framework architecture (Playwright or Cypress) with fixtures, helpers, and configuration"
    generate_testarch_command "atdd" "workflows/testarch/atdd/workflow.yaml" "Generate failing acceptance tests before implementation using TDD red-green-refactor cycle"
    generate_testarch_command "automate" "workflows/testarch/automate/workflow.yaml" "Expand test automation coverage after implementation or analyze existing codebase to generate comprehensive test suite"
    generate_testarch_command "ci" "workflows/testarch/ci/workflow.yaml" "Scaffold CI/CD quality pipeline with test execution, burn-in loops, and artifact collection"
fi

# ============================================================
# Generate Diagram Commands (/hf:diagram:*)
# ============================================================
echo ""
echo "=== Generating Diagram Commands ==="
if [[ -f "$COMMANDS_DIR/diagrams.yaml" ]]; then
    generate_diagram_command "create" "workflows/diagrams/diagram/workflow.yaml" "Create diagram (auto-detect type)"
    generate_diagram_command "flowchart" "workflows/diagrams/flowchart/workflow.yaml" "Create flowchart diagram"
    generate_diagram_command "wireframe" "workflows/diagrams/wireframe/workflow.yaml" "Create UI wireframe"
    generate_diagram_command "dataflow" "workflows/diagrams/dataflow/workflow.yaml" "Create dataflow diagram"
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
TOTAL=$(ls -1 "$TARGET_DIR"/*.md 2>/dev/null | wc -l)
echo "Generated: $TOTAL commands in $TARGET_DIR"
echo ""
echo "Commands available:"
echo "  /go              - Session kickoff"
echo "  /harmony         - Interactive menu (30 commands)"
echo "  /sentinel        - Error memory system"
echo "  /hf:agent:*      - Agent commands (18 agents)"
echo "  /hf:workflow:*   - Workflow commands (8 workflows)"
echo "  /hf:testarch:*   - Test architecture commands (4 commands)"
echo "  /hf:diagram:*    - Diagram generation commands (4 commands)"
