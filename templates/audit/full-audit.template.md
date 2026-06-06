# Full Audit Output Template

> Template for `/harmony full` command output.

---

## Summary Box

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         HARMONY FULL AUDIT                                    ║
║                         {{DATE}} • {{PROJECT_NAME}}                           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   COMMANDS         {{BAR_COMMANDS}}  {{PCT_COMMANDS}}%  {{STATUS_COMMANDS}}   ║
║   AGENTS           {{BAR_AGENTS}}  {{PCT_AGENTS}}%  {{STATUS_AGENTS}}         ║
║   SPECIALTIES      {{BAR_SPECS}}  {{PCT_SPECS}}%  {{STATUS_SPECS}}            ║
║   PROFILES         {{BAR_PROFILES}}  {{PCT_PROFILES}}%  {{STATUS_PROFILES}}   ║
║   KNOWLEDGE        {{BAR_KNOWLEDGE}}  {{PCT_KNOWLEDGE}}%  {{STATUS_KNOWLEDGE}}║
║   CONFIG           {{BAR_CONFIG}}  {{PCT_CONFIG}}%  {{STATUS_CONFIG}}         ║
║   MEMORY           {{BAR_MEMORY}}  {{PCT_MEMORY}}%  {{STATUS_MEMORY}}         ║
║   MCP              {{BAR_MCP}}  {{PCT_MCP}}%  {{STATUS_MCP}}                  ║
║   ─────────────────────────────────────────────────────────────────────────   ║
║   BIN              {{BAR_BIN}}  {{PCT_BIN}}%  {{STATUS_BIN}}                  ║
║   HOOKS            {{BAR_HOOKS}}  {{PCT_HOOKS}}%  {{STATUS_HOOKS}}            ║
║   INTEGRATIONS     {{BAR_INTEGRATIONS}}  {{PCT_INTEGRATIONS}}%  {{STATUS_INTEGRATIONS}}║
║   PATTERNS         {{BAR_PATTERNS}}  {{PCT_PATTERNS}}%  {{STATUS_PATTERNS}}  ║
║   ROUTING          {{BAR_ROUTING}}  {{PCT_ROUTING}}%  {{STATUS_ROUTING}}      ║
║   RULES            {{BAR_RULES}}  {{PCT_RULES}}%  {{STATUS_RULES}}            ║
║   WORKFLOWS        {{BAR_WORKFLOWS}}  {{PCT_WORKFLOWS}}%  {{STATUS_WORKFLOWS}}║
║   ERROR-LIBRARY    {{BAR_ERRORS}}  {{PCT_ERRORS}}%  {{STATUS_ERRORS}}        ║
║   TIPS             {{BAR_TIPS}}  {{PCT_TIPS}}%  {{STATUS_TIPS}}              ║
║   TOOLS            {{BAR_TOOLS}}  {{PCT_TOOLS}}%  {{STATUS_TOOLS}}            ║
║   ─────────────────────────────────────────────────────────────────────────   ║
║   LINKS            {{BAR_LINKS}}  {{PCT_LINKS}}%  {{STATUS_LINKS}}            ║
║                                                                               ║
║   OVERALL SCORE: {{OVERALL_SCORE}}%                                           ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

**Progress Bar Legend**:
- `████████████████████` = 100%
- `████████████████░░░░` = 80%
- `████████████░░░░░░░░` = 60%
- `████████░░░░░░░░░░░░` = 40%
- `████░░░░░░░░░░░░░░░░` = 20%

**Status Icons**:
- `✅` = All valid
- `⚠️` = Warnings present
- `❌` = Errors found

---

## Detailed Sections

### 1. COMMANDS COHERENCE

```
┌─ 1. COMMANDS COHERENCE ─────────────────────────────────────────────────────────┐
│                                                                               │
│   Total Commands: {{CMD_TOTAL}} (index.md + {{CMD_FILES}} command files)      │
│                                                                               │
│   ✅ Core Commands:                                                           │
│      {{CMD_CORE_LIST}}                                                        │
│                                                                               │
│   ✅ YAML Configs: {{CMD_YAML_LIST}}                                          │
│                                                                               │
│   Index Check:     {{CMD_INDEX_STATUS}} All commands referenced in index.md   │
│   File Check:      {{CMD_FILES_STATUS}} All referenced files exist            │
│   Orphan Check:    {{CMD_ORPHAN_STATUS}} No orphan command files              │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 2. AGENTS COHERENCE

```
┌─ 2. AGENTS COHERENCE ───────────────────────────────────────────────────────────┐
│                                                                               │
│   Total Agents: {{AGENT_TOTAL}} (+ INDEX.md)                                  │
│                                                                               │
│   ✅ Core Agents ({{AGENT_CORE_COUNT}}):                                      │
│      {{AGENT_CORE_LIST}}                                                      │
│                                                                               │
│   ✅ Specialist Agents ({{AGENT_SPEC_COUNT}}):                                │
│      {{AGENT_SPEC_LIST}}                                                      │
│                                                                               │
│   Frontmatter:     {{AGENT_FM_STATUS}} All agents have valid YAML frontmatter │
│   Required Fields: {{AGENT_RF_STATUS}} name, displayName, description, version│
│   Triggers:        {{AGENT_TR_STATUS}} All agents have routing triggers       │
│   Phase/Step:      {{AGENT_PS_STATUS}} Valid phase (1-5) and step numbers     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 3. SPECIALTIES COHERENCE

```
┌─ 3. SPECIALTIES COHERENCE ──────────────────────────────────────────────────────┐
│                                                                               │
│   Total Specialties: {{SPEC_TOTAL}}                                           │
│                                                                               │
{{SPEC_LIST}}
│                                                                               │
│   Manifest Check:  {{SPEC_MANIFEST_STATUS}} All manifests valid YAML          │
│   Branches Check:  {{SPEC_BRANCH_STATUS}} All declared branches exist         │
│   Knowledge Refs:  {{SPEC_KNOW_STATUS}} All referenced knowledge exists       │
│   Profile Refs:    {{SPEC_PROF_STATUS}} All referenced profiles exist         │
│   Pattern Refs:    {{SPEC_PATT_STATUS}} All referenced patterns exist         │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 4. PROFILES COHERENCE

```
┌─ 4. PROFILES COHERENCE ─────────────────────────────────────────────────────────┐
│                                                                               │
│   Registry: profiles-registry.yaml {{PROF_REG_STATUS}}                        │
│                                                                               │
│   Categories:                                                                 │
{{PROF_CATEGORIES}}
│                                                                               │
│   Total Profiles: {{PROF_TOTAL}}                                              │
│                                                                               │
│   Registry Sync:   {{PROF_SYNC_STATUS}} All directories registered            │
│   Knowledge Refs:  {{PROF_KNOW_STATUS}} All referenced knowledge exists       │
│   Orphan Check:    {{PROF_ORPH_STATUS}} No orphan profile directories         │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 5. KNOWLEDGE COHERENCE

```
┌─ 5. KNOWLEDGE COHERENCE ────────────────────────────────────────────────────────┐
│                                                                               │
│   Structure:                                                                  │
{{KNOW_STRUCTURE}}
│                                                                               │
│   Total Knowledge Files: {{KNOW_TOTAL}}                                       │
│                                                                               │
│   Markdown Valid:  {{KNOW_MD_STATUS}} All files valid markdown                │
│   Referenced:      {{KNOW_REF_STATUS}} All files referenced                   │
│   Orphan Check:    {{KNOW_ORPH_STATUS}} {{KNOW_ORPH_COUNT}} orphan files      │
│   Internal Links:  {{KNOW_LINK_STATUS}} No broken internal links              │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 6. CONFIG COHERENCE

```
┌─ 6. CONFIG COHERENCE ───────────────────────────────────────────────────────────┐
│                                                                               │
{{CONFIG_LIST}}
│                                                                               │
│   YAML Valid:      {{CONFIG_YAML_STATUS}} All configs valid YAML              │
│   Refs Valid:      {{CONFIG_REF_STATUS}} All referenced files exist           │
│   No Conflicts:    {{CONFIG_CONF_STATUS}} No conflicting settings             │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

**Required Configs**:
- `guardian-conventions.yaml`
- `llm-defaults.yaml`
- `model-tiers.yaml`
- `overrides.yaml`
- `paths.yaml` / `paths.json`
- `pipeline-orchestration.yaml`
- `routing-rules.yaml`

### 7. MEMORY STATE

```
┌─ 7. MEMORY STATE ───────────────────────────────────────────────────────────────┐
│                                                                               │
│   Location: .harmony/local/memory/                                            │
│   Files: {{MEM_COUNT}}/{{MEM_EXPECTED}} present {{MEM_STATUS}}                 │
│                                                                               │
{{MEM_FILES_LIST}}
│                                                                               │
│   Circuit Breaker Status:                                                     │
│   ├── State: {{CB_STATE}} {{CB_STATE_ICON}}                                   │
│   ├── Consecutive Failures: {{CB_FAILURES}}                                   │
│   ├── Last Success: {{CB_LAST_SUCCESS}}                                       │
│   └── Max Failures Before OPEN: {{CB_MAX}}                                    │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

**Required Memory Files**:
- `working.json`
- `workflow-state.json`
- `circuit-breaker.json`
- `error-journal.json`
- `learned-patterns.json`
- `user-preferences.json`
- `session-tracker.json`

### 8. MCP INTEGRATION

```
┌─ 8. MCP INTEGRATION ────────────────────────────────────────────────────────────┐
│                                                                               │
│   Required MCP Servers:                                                       │
│   ├── {{MCP_MEMORY_STATUS}} memory         - Cross-session learning           │
│   └── {{MCP_SEQ_STATUS}} sequentialthinking - Structured reasoning            │
│                                                                               │
│   Optional MCP Servers:                                                       │
│   ├── {{MCP_BRAVE_STATUS}} brave-search    - Web search                       │
│   └── {{MCP_CTX7_STATUS}} context7         - Library docs                     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 9. BIN SCRIPTS

```
┌─ 9. BIN SCRIPTS ────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Entry Points:                                                               │
{{BIN_LIST}}
│                                                                               │
│   Shell Syntax:    {{BIN_SYNTAX_STATUS}} All scripts valid bash               │
│   Executable:      {{BIN_EXEC_STATUS}} All scripts executable                 │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 10. HOOKS

```
┌─ 10. HOOKS ─────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Available Hooks:                                                            │
{{HOOKS_LIST}}
│                                                                               │
│   Shell Syntax:    {{HOOKS_SYNTAX_STATUS}} All hooks valid bash               │
│   State Paths:     {{HOOKS_PATH_STATUS}} All state paths valid                │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 11. INTEGRATIONS

```
┌─ 11. INTEGRATIONS ──────────────────────────────────────────────────────────────┐
│                                                                               │
│   Registry: integrations-registry.yaml {{INT_REG_STATUS}}                     │
│                                                                               │
│   IDE Integrations:                                                           │
{{INT_LIST}}
│                                                                               │
│   Manifest Valid:  {{INT_MANIFEST_STATUS}} All manifests valid YAML           │
│   Templates:       {{INT_TEMPLATE_STATUS}} All templates exist                │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 12. PATTERNS

```
┌─ 12. PATTERNS ──────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Total Patterns: {{PAT_TOTAL}}                                               │
│                                                                               │
│   Pattern Types:                                                              │
│   ├── System Patterns (P-XXX):  {{PAT_SYSTEM_COUNT}}                          │
│   ├── Cognitive Patterns:       {{PAT_COGNITIVE_COUNT}}                       │
│   └── Case Studies (CS-XXX):    {{PAT_CASE_COUNT}}                            │
│                                                                               │
│   Index:           {{PAT_INDEX_STATUS}} INDEX.md present                      │
│   Registry:        {{PAT_REG_STATUS}} patterns-registry.json valid            │
│   ID Format:       {{PAT_ID_STATUS}} All patterns follow P-XXX format         │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 13. ROUTING

```
┌─ 13. ROUTING ───────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Configuration Files:                                                        │
{{ROUTING_LIST}}
│                                                                               │
│   YAML Valid:      {{ROUTING_YAML_STATUS}} All configs valid YAML             │
│   Agent Refs:      {{ROUTING_AGENT_STATUS}} All agent references valid        │
│   Phase Numbers:   {{ROUTING_PHASE_STATUS}} All phases in [1-5]               │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 14. RULES

```
┌─ 14. RULES ─────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Total Rules: {{RULES_TOTAL}}                                                │
│                                                                               │
{{RULES_LIST}}
│                                                                               │
│   ID Format:       {{RULES_ID_STATUS}} All rules follow R-XXX format          │
│   YAML Valid:      {{RULES_YAML_STATUS}} All rules valid YAML                 │
│   Related Refs:    {{RULES_REF_STATUS}} All related patterns/agents exist     │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 15. WORKFLOWS

```
┌─ 15. WORKFLOWS ─────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Structure:                                                                  │
{{WORKFLOW_STRUCTURE}}
│                                                                               │
│   Total Workflow Files: {{WF_TOTAL}}                                          │
│                                                                               │
│   Markdown Valid:  {{WF_MD_STATUS}} All files valid markdown                  │
│   Phase Dirs:      {{WF_PHASE_STATUS}} All phase directories structured       │
│   Cross-refs:      {{WF_REF_STATUS}} All workflow references valid            │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 16. ERROR-LIBRARY

```
┌─ 16. ERROR-LIBRARY ─────────────────────────────────────────────────────────────┐
│                                                                               │
│   Index: index.json {{ERR_INDEX_STATUS}}                                      │
│   Schema: error.schema.json {{ERR_SCHEMA_STATUS}}                             │
│                                                                               │
│   Categories:                                                                 │
{{ERR_CATEGORIES}}
│                                                                               │
│   Total Errors: {{ERR_TOTAL}}                                                 │
│                                                                               │
│   JSON Valid:      {{ERR_JSON_STATUS}} All error files valid JSON             │
│   ID Format:       {{ERR_ID_STATUS}} All IDs follow CATEGORY-NNN format       │
│   Schema:          {{ERR_CONFORM_STATUS}} All errors conform to schema        │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 17. TIPS

```
┌─ 17. TIPS ──────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Total Tips: {{TIPS_TOTAL}}                                                  │
│                                                                               │
{{TIPS_LIST}}
│                                                                               │
│   Sequential:      {{TIPS_SEQ_STATUS}} Tips numbered sequentially (01-XX)     │
│   Markdown Valid:  {{TIPS_MD_STATUS}} All tips valid markdown                 │
│   Internal Links:  {{TIPS_LINK_STATUS}} No broken internal links              │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 18. TOOLS

```
┌─ 18. TOOLS ─────────────────────────────────────────────────────────────────────┐
│                                                                               │
│   Available Tools:                                                            │
{{TOOLS_LIST}}
│                                                                               │
│   Shell Scripts:   {{TOOLS_SH_STATUS}} All .sh files valid syntax             │
│   Dockerfiles:     {{TOOLS_DOCKER_STATUS}} All Dockerfiles valid              │
│   Dependencies:    {{TOOLS_DEPS_STATUS}} All requirements.txt valid           │
│   Documentation:   {{TOOLS_DOC_STATUS}} All tools have README.md              │
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 19. BROKEN LINKS CHECK

```
┌─ 19. BROKEN LINKS CHECK ────────────────────────────────────────────────────────┐
│                                                                               │
│   Scanned: {{LINK_SCANNED}} files                                             │
│                                                                               │
│   Internal Links (.md):    {{LINK_MD_STATUS}} {{LINK_MD_BROKEN}}/{{LINK_MD_TOTAL}}│
│   File References:         {{LINK_FILE_STATUS}} {{LINK_FILE_BROKEN}}/{{LINK_FILE_TOTAL}}│
│   Agent References:        {{LINK_AGENT_STATUS}} {{LINK_AGENT_BROKEN}}/{{LINK_AGENT_TOTAL}}│
│   Knowledge References:    {{LINK_KNOW_STATUS}} {{LINK_KNOW_BROKEN}}/{{LINK_KNOW_TOTAL}}│
│   Profile References:      {{LINK_PROF_STATUS}} {{LINK_PROF_BROKEN}}/{{LINK_PROF_TOTAL}}│
│                                                                               │
{{BROKEN_LINKS_DETAILS}}
│                                                                               │
└───────────────────────────────────────────────────────────────────────────────┘
```

### 20. RECOMMENDATIONS

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         RECOMMENDATIONS                                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
{{RECOMMENDATIONS}}
║                                                                               ║
║   Categories checked: 18                                                      ║
║   Total items validated: {{TOTAL_ITEMS}}                                      ║
║                                                                               ║
║   Current Phase: {{PHASE_NAME}} (Phase {{PHASE_NUM}})                         ║
║   Guardian Mode: {{GUARDIAN_MODE}}                                            ║
║   Sentinel: {{SENTINEL_STATE}}                                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

**Recommendation Types**:
- `✅ No critical issues found`
- `❌ Critical Issues (X):` - Must fix
- `⚠️ Warnings (X):` - Should review
- `📋 Suggested Next Steps:` - Actions to take

---

## Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `{{DATE}}` | Current date | `2026-01-20` |
| `{{PROJECT_NAME}}` | Project name from working.json | `DAST v2` |
| `{{BAR_*}}` | Progress bar (20 chars) | `████████████████████` |
| `{{PCT_*}}` | Percentage | `100` |
| `{{STATUS_*}}` | Status with icon | `✅ 30/30 valid` |
| `{{*_STATUS}}` | Check status icon | `✅` or `❌` or `⚠️` |
| `{{*_TOTAL}}` | Count total | `30` |
| `{{*_LIST}}` | Formatted list | Multi-line |
| `{{TOTAL_ITEMS}}` | Total items validated | `594` |

---

## Categories Reference (18 Total)

| # | Category | Description | Validation |
|---|----------|-------------|------------|
| 1 | COMMANDS | CLI command definitions | Index, files, orphans |
| 2 | AGENTS | Agent markdown files | Frontmatter, fields, triggers |
| 3 | SPECIALTIES | Domain specializations | Manifests, branches, refs |
| 4 | PROFILES | Tech stack profiles | Registry, knowledge refs |
| 5 | KNOWLEDGE | Domain documentation | Markdown, refs, orphans |
| 6 | CONFIG | YAML configurations | Required files, validity |
| 7 | MEMORY | Runtime state files | JSON validity, CB state |
| 8 | MCP | Model Context Protocol | Server availability |
| 9 | BIN | Entry point scripts | Shell syntax |
| 10 | HOOKS | Hook scripts | Shell syntax, paths |
| 11 | INTEGRATIONS | IDE integrations | Registry, manifests |
| 12 | PATTERNS | System patterns | P-XXX format, registry |
| 13 | ROUTING | Agent routing rules | YAML, agent refs, phases |
| 14 | RULES | Enforcement rules | R-XXX format, YAML |
| 15 | WORKFLOWS | Workflow definitions | Structure, cross-refs |
| 16 | ERROR-LIBRARY | Error definitions | JSON schema, ID format |
| 17 | TIPS | Onboarding tips | Sequential naming |
| 18 | TOOLS | Utility tools | Shell, Docker, deps |
