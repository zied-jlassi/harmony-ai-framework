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
# Args: name, path, description, [type]
# type: "compliance" = read-only with fork, "design" = fork with full access, "" = standard
generate_agent_command() {
    local name="$1"
    local path="$2"
    local description="$3"
    local agent_type="${4:-}"

    local filename="hf-agent-${name}.md"
    local extra_frontmatter=""

    # Add Claude Code v2.1.0 features based on agent type
    case "$agent_type" in
        compliance)
            # Read-only agents: isolated context, restricted tools, block writes
            extra_frontmatter="context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
hooks:
  PreToolUse:
    - matcher: \"Write|Edit\"
      command: \"echo '[Harmony] Compliance agent: read-only mode' && exit 1\""
            ;;
        compliance-opus)
            # Like compliance but with opus model (security, pentest)
            extra_frontmatter="context: fork
agent: opus
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
hooks:
  PreToolUse:
    - matcher: \"Write|Edit\"
      command: \"echo '[Harmony] Compliance agent: read-only mode' && exit 1\""
            ;;
        design)
            # Design agents: isolated context, full tools, opus model
            extra_frontmatter="context: fork
agent: opus"
            ;;
        system)
            # System agents: Guardian, Sentinel - ultra-fast monitoring
            extra_frontmatter="context: fork
agent: haiku
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
hooks:
  PreToolUse:
    - matcher: \"Write|Edit|Bash\"
      command: \"echo '[Harmony] System agent: monitoring only' && exit 1\""
            ;;
        orchestration)
            # Orchestration agents: SM, Supervisor, Party - coordination
            extra_frontmatter="context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Task
  - Write
hooks:
  PreToolUse:
    - matcher: \"Edit|Bash\"
      command: \"echo '[Harmony] Orchestration: use Task for delegation' && exit 1\""
            ;;
        quality)
            # Quality agents: Lint, Dependency, Performance, QA - analysis with Bash
            extra_frontmatter="context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebFetch
hooks:
  PreToolUse:
    - matcher: \"Write|Edit\"
      command: \"echo '[Harmony] Quality agent: analysis only' && exit 1\""
            ;;
        creative-design)
            # Creative agents: Designer, UX, Narrative - create new, don't modify
            extra_frontmatter="context: fork
agent: sonnet
allowed-tools:
  - Read
  - Grep
  - Glob
  - Write
  - WebSearch
hooks:
  PreToolUse:
    - matcher: \"Edit|Bash\"
      command: \"echo '[Harmony] Creative agent: create new, dont modify' && exit 1\""
            ;;
        *)
            # Standard agents: no special features
            ;;
    esac

    if [[ -n "$extra_frontmatter" ]]; then
        cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:agent:${name}"
description: "${description}"
${extra_frontmatter}
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF
    else
        cat > "$TARGET_DIR/$filename" << EOF
---
name: "/hf:agent:${name}"
description: "${description}"
---
Read \`\${HARMONY_DIR}/${path}\`
Args: \$ARGUMENTS
EOF
    fi

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
    # ============================================================
    # SYSTEM AGENTS (haiku, monitoring only) - CRITICAL
    # ============================================================
    generate_agent_command "guardian" "agents/guardian.md" "Workflow Protector - intent detection, routing" "system"
    generate_agent_command "sentinel" "agents/sentinel.md" "Memory Guardian - error learning, circuit breaker" "system"

    # ============================================================
    # IMPLEMENTATION AGENTS (standard, full access)
    # ============================================================
    generate_agent_command "dev" "agents/developer.md" "Expert full-stack developer - TDD, Clean Architecture"
    generate_agent_command "tester" "agents/tester.md" "QA engineer - test strategy, automation, coverage"
    generate_agent_command "docs" "agents/tech-writer.md" "Tech Writer - documentation, guides"
    generate_agent_command "quick-flow" "agents/quick-flow.md" "Quick flow mode - fast development, shortcuts"
    generate_agent_command "quick-flow-solo" "agents/quick-flow-solo.md" "Solo dev mode - abbreviated workflow"
    generate_agent_command "visual-documenter" "specialties/creative/branchs/visual-documenter.md" "Visual documenter - diagrams, infographics"

    # ============================================================
    # DESIGN AGENTS (opus, fork, full access)
    # ============================================================
    generate_agent_command "architect" "agents/architect.md" "Software architect - system design, ADRs, decisions" "design"
    generate_agent_command "ai-architect" "agents/ai-architect.md" "AI/LLM architect - RAG, multi-agent, memory" "design"
    generate_agent_command "database" "agents/database.md" "Database architect - schema design, migrations, optimization" "design"

    # ============================================================
    # CREATIVE-DESIGN AGENTS (sonnet, fork, Write only)
    # ============================================================
    generate_agent_command "designer" "agents/designer.md" "Creative designer - visual, game design" "creative-design"
    generate_agent_command "ux" "agents/ux-designer.md" "UX Designer - wireframes, user flows" "creative-design"
    generate_agent_command "narrative" "agents/narrative-designer.md" "Narrative designer - game storytelling" "creative-design"
    generate_agent_command "design-thinking" "specialties/creative/branchs/design-thinking-lead.md" "Design thinking lead - user-centered innovation" "creative-design"
    generate_agent_command "innovation-scout" "specialties/creative/branchs/innovation-scout.md" "Innovation scout - emerging tech, trends analysis" "creative-design"
    generate_agent_command "problem-solver" "specialties/creative/branchs/problem-solver.md" "Problem solver - root cause analysis, solutions" "creative-design"
    generate_agent_command "ux-storyteller" "specialties/creative/branchs/ux-storyteller.md" "UX storyteller - user journeys, narratives" "creative-design"

    # ============================================================
    # ORCHESTRATION AGENTS (sonnet, fork, Task + Write)
    # ============================================================
    generate_agent_command "sm" "agents/scrum-master.md" "Scrum Master - stories, sprints, planning, INVEST" "orchestration"
    generate_agent_command "supervisor" "agents/supervisor.md" "Multi-agent orchestrator - coordination, delegation" "orchestration"
    generate_agent_command "party" "agents/party.md" "Multi-agent discussion - brainstorm, debate, consensus" "orchestration"
    generate_agent_command "backlog" "agents/backlog.md" "Backlog dashboard - visualization, kanban, priorities" "orchestration"
    generate_agent_command "ucv" "agents/ucv.md" "UCV Coordinator - verification workflow" "orchestration"
    generate_agent_command "brainstorm" "specialties/creative/branchs/brainstorm-facilitator.md" "Brainstorm facilitator - ideation, creative sessions" "orchestration"
    generate_agent_command "analyst" "agents/analyst.md" "Business analyst - requirements, briefs, PRD" "orchestration"
    generate_agent_command "pm" "agents/product-manager.md" "Product Manager - roadmap, priorities" "orchestration"

    # ============================================================
    # QUALITY AGENTS (sonnet, fork, Bash for linters)
    # ============================================================
    generate_agent_command "lint" "specialties/quality/branchs/lint.md" "Code quality linter - ESLint, Prettier, code style" "quality"
    generate_agent_command "dependency" "specialties/quality/branchs/dependency.md" "Dependency auditor - npm audit, vulnerabilities, licenses" "quality"
    generate_agent_command "performance" "specialties/quality/branchs/performance.md" "Performance auditor - optimization, benchmarks, profiling" "quality"
    generate_agent_command "exploratory-qa" "agents/exploratory-qa.md" "Exploratory QA - manual testing, UX validation" "quality"
    generate_agent_command "ucv-qa" "specialties/ucv/branchs/qa.md" "UCV QA - manual browser validation (HQVF)" "quality"

    # ============================================================
    # COMPLIANCE AGENTS (sonnet, fork, read-only)
    # ============================================================
    generate_agent_command "accessibility" "agents/accessibility.md" "Accessibility auditor - WCAG/RGAA/EAA" "compliance"
    generate_agent_command "review" "agents/review.md" "Code Reviewer - code review, best practices" "compliance"
    generate_agent_command "atlas" "agents/atlas.md" "Architecture validator - clean architecture, layer boundaries" "compliance"
    generate_agent_command "harmony" "agents/harmony.md" "Framework coherence auditor - orphans, duplicates, manifests" "compliance"
    generate_agent_command "ucv-validator" "specialties/ucv/branchs/validator.md" "UCV Validator - validates 100% UCV coverage" "compliance"
    generate_agent_command "ucv-writer" "specialties/ucv/branchs/writer.md" "UCV Writer - creates Use Case Verifiables" "compliance"
    generate_agent_command "legal" "specialties/legal/branchs/legal.md" "Legal audit orchestrator - RGPD, CGV, accessibility, DPO" "compliance"

    # ============================================================
    # COMPLIANCE-OPUS AGENTS (opus, fork, read-only - security/legal)
    # ============================================================
    generate_agent_command "security" "agents/security.md" "Security auditor - OWASP Top 10" "compliance-opus"
    generate_agent_command "rgpd" "agents/rgpd.md" "RGPD/GDPR compliance auditor" "compliance-opus"
    generate_agent_command "pentest" "agents/pentest.md" "Penetration testing agent" "compliance-opus"
    generate_agent_command "security-dpo" "specialties/security/branchs/dpo.md" "Data Protection Officer - RGPD implementation, privacy" "compliance-opus"
    generate_agent_command "security-auditor" "specialties/security/branchs/auditor.md" "Security auditor - vulnerability assessment, compliance" "compliance-opus"
    generate_agent_command "security-engineer" "specialties/security/branchs/engineer.md" "Security engineer - secure coding, hardening" "compliance-opus"
    generate_agent_command "security-researcher" "specialties/security/branchs/researcher.md" "Security researcher - threat analysis, CVE research" "compliance-opus"

    # ============================================================
    # DEVOPS AGENTS (standard)
    # ============================================================
    generate_agent_command "devops" "specialties/devops/branchs/devops.md" "DevOps engineer - CI/CD, Docker, Kubernetes, infrastructure"
    generate_agent_command "devops-builder" "specialties/devops/branchs/builder.md" "Build engineer - Docker, CI pipelines, artifacts"
    generate_agent_command "i18n" "specialties/i18n/branchs/i18n.md" "Internationalization specialist - translations, localization"

    # ============================================================
    # GAMING SPECIALTY BRANCHES (context-specific)
    # ============================================================
    generate_agent_command "game-architect" "specialties/architecture/branchs/gaming.md" "Game architect - ECS, state machines, multiplayer" "design"
    generate_agent_command "game-designer" "specialties/designer/branchs/gaming.md" "Game designer - GDD, mechanics, core loops" "creative-design"
    generate_agent_command "game-developer" "specialties/developer/branchs/gaming.md" "Game developer - Unity, Godot, game logic"
    generate_agent_command "game-sm" "specialties/scrum-master/branchs/gaming.md" "Game scrum master - sprints, playtests, milestones" "orchestration"
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
