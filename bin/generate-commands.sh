#!/bin/bash
# Harmony Framework - Generate Claude Code Commands
# Generates .claude/commands/*.md from framework/commands/*.yaml

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

# Function to generate agent command
generate_agent_command() {
    local name="$1"
    local path="$2"
    local description="$3"
    local arguments="$4"

    local filename="hf-agent-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
# /hf:agent:${name}

${description}

## Usage

\`\`\`
/hf:agent:${name} ${arguments}
\`\`\`

## Behavior

Load and activate the agent defined in \`${path}\`.

Arguments: ${arguments}

---

## Execution

Read and apply the agent file: \`\${HARMONY_DIR}/${path}\`
EOF

    echo "  ✅ $filename"
}

# Function to generate workflow command
generate_workflow_command() {
    local name="$1"
    local path="$2"
    local description="$3"
    local arguments="$4"

    local filename="hf-workflow-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
# /hf:workflow:${name}

${description}

## Usage

\`\`\`
/hf:workflow:${name} ${arguments}
\`\`\`

## Behavior

Execute the workflow defined in \`${path}\`.

Arguments: ${arguments}

---

## Execution

Read and execute the workflow: \`\${HARMONY_DIR}/${path}\`
EOF

    echo "  ✅ $filename"
}

# Function to generate testarch command
generate_testarch_command() {
    local name="$1"
    local path="$2"
    local description="$3"
    local arguments="$4"

    local filename="hf-testarch-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
# /hf:testarch:${name}

${description}

## Usage

\`\`\`
/hf:testarch:${name} ${arguments}
\`\`\`

## Behavior

Execute the test architecture workflow defined in \`${path}\`.

Arguments: ${arguments}

---

## Execution

Read and execute: \`\${HARMONY_DIR}/${path}\`
EOF

    echo "  ✅ $filename"
}

# Function to generate diagram command
generate_diagram_command() {
    local name="$1"
    local path="$2"
    local description="$3"
    local arguments="$4"

    local filename="hf-diagram-${name}.md"

    cat > "$TARGET_DIR/$filename" << EOF
# /hf:diagram:${name}

${description}

## Usage

\`\`\`
/hf:diagram:${name} ${arguments}
\`\`\`

## Behavior

Create a diagram using the workflow defined in \`${path}\`.

Arguments: ${arguments}

---

## Execution

Read and execute: \`\${HARMONY_DIR}/${path}\`
EOF

    echo "  ✅ $filename"
}

# Parse YAML and generate commands
# Note: This uses simple grep/sed for portability (no yq required)

echo "=== Generating Agent Commands ==="
if [[ -f "$COMMANDS_DIR/agents.yaml" ]]; then
    # Extract agent names and generate
    generate_agent_command "dev" "agents/developer.md" "Expert full-stack developer - implementation, TDD, Clean Architecture" "[story-id]"
    generate_agent_command "architect" "agents/architect.md" "Software architect - system design, ADRs, technical decisions" "[topic-or-decision]"
    generate_agent_command "analyst" "agents/analyst.md" "Business analyst - requirements, briefs, PRD" "[topic]"
    generate_agent_command "tester" "agents/tester.md" "QA engineer - test strategy, automation, coverage" "[scope-or-story]"
    generate_agent_command "sm" "agents/scrum-master.md" "Scrum Master - stories, sprints, planning, SPIDR, INVEST" "[action-or-story]"
    generate_agent_command "ai-architect" "agents/ai-architect.md" "AI/LLM architect - RAG, multi-agent, memory systems" "[ai-topic]"
    generate_agent_command "exploratory-qa" "agents/exploratory-qa.md" "Exploratory QA - manual testing, UX validation" "[module-or-feature]"
    generate_agent_command "ucv-writer" "agents/ucv-writer.md" "UCV Writer - creates Use Case Verifiables (HQVF)" "[story-id]"
    generate_agent_command "ucv-validator" "agents/ucv-validator.md" "UCV Validator - validates 100% UCV coverage (HQVF)" "[story-id]"
    generate_agent_command "ucv-qa" "agents/ucv-qa.md" "UCV QA - manual browser validation (HQVF)" "[story-id]"
    generate_agent_command "accessibility" "agents/accessibility.md" "Accessibility auditor - WCAG/RGAA/EAA" "[module]"
    generate_agent_command "security" "agents/security.md" "Security auditor - OWASP Top 10" "[module]"
    generate_agent_command "rgpd" "agents/rgpd.md" "RGPD/GDPR compliance auditor" "[module]"
    generate_agent_command "pentest" "agents/pentest.md" "Penetration testing agent" "[target]"
    generate_agent_command "ux" "agents/ux-designer.md" "UX Designer - wireframes, user flows" "[feature-or-screen]"
    generate_agent_command "pm" "agents/product-manager.md" "Product Manager - roadmap, priorities" "[topic]"
    generate_agent_command "docs" "agents/tech-writer.md" "Tech Writer - documentation, guides" "[doc-type]"
    generate_agent_command "review" "agents/review.md" "Code Reviewer - code review, best practices" "[pr-or-files]"
fi

echo ""
echo "=== Generating Workflow Commands ==="
if [[ -f "$COMMANDS_DIR/workflows.yaml" ]]; then
    generate_workflow_command "dev-story" "workflows/4-implementation/dev-story/workflow.yaml" "Complete story development workflow" "[story-id]"
    generate_workflow_command "create-story" "workflows/4-implementation/create-story/workflow.yaml" "Create a new story with acceptance criteria" "[epic-or-feature]"
    generate_workflow_command "code-review" "workflows/4-implementation/code-review/workflow.yaml" "Code review workflow" "[pr-number-or-files]"
    generate_workflow_command "sprint-planning" "workflows/4-implementation/sprint-planning/workflow.yaml" "Sprint planning session" "[sprint-number]"
    generate_workflow_command "sprint-status" "workflows/4-implementation/sprint-status/workflow.yaml" "Sprint status report" ""
    generate_workflow_command "retrospective" "workflows/4-implementation/retrospective/workflow.yaml" "Sprint retrospective" "[sprint-number]"
    generate_workflow_command "status" "workflows/workflow-status/workflow.yaml" "Show current workflow status" ""
    generate_workflow_command "init" "workflows/workflow-status/init/workflow.yaml" "Initialize Harmony workflow" "[project-type]"
fi

echo ""
echo "=== Generating TestArch Commands ==="
if [[ -f "$COMMANDS_DIR/testarch.yaml" ]]; then
    generate_testarch_command "framework" "workflows/testarch/framework/workflow.yaml" "Initialize test framework" "[framework]"
    generate_testarch_command "atdd" "workflows/testarch/atdd/workflow.yaml" "ATDD workflow" "[story-id]"
    generate_testarch_command "automate" "workflows/testarch/automate/workflow.yaml" "Automate test cases" "[test-scope]"
    generate_testarch_command "ci" "workflows/testarch/ci/workflow.yaml" "Setup CI/CD for tests" "[platform]"
fi

echo ""
echo "=== Generating Diagram Commands ==="
if [[ -f "$COMMANDS_DIR/diagrams.yaml" ]]; then
    generate_diagram_command "flowchart" "workflows/diagrams/flowchart/workflow.yaml" "Create flowchart diagram" "[process-name]"
    generate_diagram_command "wireframe" "workflows/diagrams/wireframe/workflow.yaml" "Create UI wireframe" "[screen-name]"
    generate_diagram_command "dataflow" "workflows/diagrams/dataflow/workflow.yaml" "Create dataflow diagram" "[system-name]"
    generate_diagram_command "create" "workflows/diagrams/diagram/workflow.yaml" "Create diagram (auto-detect type)" "[description]"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
TOTAL=$(ls -1 "$TARGET_DIR"/hf-*.md 2>/dev/null | wc -l)
echo "Generated: $TOTAL commands in $TARGET_DIR"
echo ""
echo "Commands available:"
echo "  /hf:agent:*     - Agent commands (dev, architect, tester, etc.)"
echo "  /hf:workflow:*  - Workflow commands (dev-story, code-review, etc.)"
echo "  /hf:testarch:*  - Test architecture commands"
echo "  /hf:diagram:*   - Diagram generation commands"
