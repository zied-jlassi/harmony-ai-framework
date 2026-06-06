# Workflow Init - Project Setup Instructions

<critical>The workflow execution engine is governed by: {project-root}/.harmony/core/tasks/workflow.xml</critical>
<critical>You MUST have already loaded and processed: workflow-init/workflow.yaml</critical>
<critical>Communicate in {communication_language} with {user_name}</critical>
<critical>This workflow handles BOTH new projects AND legacy projects following the Harmony Method</critical>

<workflow>

<step n="1" goal="Scan for existing work">
<output>Welcome to Harmony Method, {user_name}!</output>

<action>Perform comprehensive scan for existing work:

- Harmony artifacts: PRD, epics, architecture, UX, brief, research, brainstorm
- Implementation: stories, sprint-status, workflow-status
- Codebase: source directories, package files, git repo
- Check both {output_folder} and {sprint_artifacts} locations
  </action>

<action>Categorize into one of these states:

- CLEAN: No artifacts or code (or scaffold only)
- PLANNING: Has PRD/spec but no implementation
- ACTIVE: Has stories or sprint status
- LEGACY: Has code but no Harmony artifacts
- UNCLEAR: Mixed state needs clarification
  </action>

<ask>What's your project called? {{#if project_name}}(Config shows: {{project_name}}){{/if}}</ask>
<action>Store project_name</action>
<template-output>project_name</template-output>
</step>

<step n="2" goal="Choose setup path">
<check if="state == CLEAN">
  <output>Perfect! Fresh start detected.</output>
  <action>Continue to step 3</action>
</check>

<check if="state == ACTIVE AND workflow_status exists">
  <output>✅ You already have workflow tracking at: {{workflow_status_path}}

To check progress: Load any Harmony agent and run /harmony:workflows:workflow-status

Happy building! 🚀</output>
<action>Exit workflow (already initialized)</action>
</check>

<check if="state != CLEAN">
  <output>Found existing work:
{{summary_of_findings}}</output>

<ask>How would you like to proceed?

1. **Continue** - Work with existing artifacts
2. **Archive & Start Fresh** - Move old work to archive
3. **Express Setup** - I know exactly what I need
4. **Guided Setup** - Walk me through options

Choice [1-4]</ask>

  <check if="choice == 1">
    <action>Set continuing_existing = true</action>
    <action>Store found artifacts</action>
    <action>Continue to step 7 (detect track from artifacts)</action>
  </check>

  <check if="choice == 2">
    <ask>Archive existing work? (y/n)</ask>
    <action if="y">Move artifacts to {output_folder}/archive/</action>
    <output>Ready for fresh start!</output>
    <action>Continue to step 3</action>
  </check>

  <check if="choice == 3">
    <action>Jump to step 3 (express path)</action>
  </check>

  <check if="choice == 4">
    <action>Continue to step 4 (guided path)</action>
  </check>
</check>

<check if="state == CLEAN">
  <ask>Setup approach:

1. **Express** - I know what I need
2. **Guided** - Show me the options

Choice [1 or 2]:</ask>

  <check if="choice == 1">
    <action>Continue to step 3 (express)</action>
  </check>

  <check if="choice == 2">
    <action>Continue to step 4 (guided)</action>
  </check>
</check>
</step>

<step n="3" goal="Express setup path">
<ask>Is this for:
1. **New project** (greenfield)
2. **Existing codebase** (brownfield)

Choice [1/2]:</ask>
<action>Set field_type based on choice</action>

<ask>Planning approach:

1. **Harmony Method** - Full planning for complex projects
2. **Enterprise Method** - Extended planning with security/DevOps

Choice [1/2]:</ask>
<action>Map to selected_track: method/enterprise</action>

<output>🚀 **For Quick Flow (minimal planning, straight to code):**
Load the **quick-flow-solo-dev** agent instead - use Quick Flow agent for faster development</output>

<template-output>field_type</template-output>
<template-output>selected_track</template-output>
<action>Jump to step 6 (discovery options)</action>
</step>

<step n="4" goal="Guided setup - understand project">
<ask>Tell me about what you're working on. What's the goal?</ask>
<action>Store user_description</action>

<action>Analyze for field type indicators:

- Brownfield: "existing", "current", "enhance", "modify"
- Greenfield: "new", "build", "create", "from scratch"
- If codebase exists, default to brownfield unless user indicates scaffold
  </action>

<check if="field_type unclear AND codebase exists">
  <ask>I see existing code. Are you:
1. **Modifying** existing codebase (brownfield)
2. **Starting fresh** - code is just scaffold (greenfield)

Choice [1/2]:</ask>
<action>Set field_type based on answer</action>
</check>

<action if="field_type not set">Set based on codebase presence</action>

<action>Check for game development keywords</action>
<check if="game_detected">
<output>🎮 **GAME DEVELOPMENT DETECTED**

For game development, install the BMGD module:

```bash
harmony init
```

Continue with software workflows? (y/n)</output>
<ask>Choice:</ask>
<action if="n">Exit workflow</action>
</check>

<template-output>user_description</template-output>
<template-output>field_type</template-output>
<action>Continue to step 5</action>
</step>

<step n="5" goal="Guided setup - select track">
<output>Based on your project, here are your Harmony Method planning options:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**1. Harmony Method** 🎯 {{#if recommended}}(RECOMMENDED){{/if}}

- Full planning: PRD + UX + Architecture
- Best for: Products, platforms, complex features
- Benefit: AI agents have complete context for better results

**2. Enterprise Method** 🏢

- Extended: Method + Security + DevOps + Testing
- Best for: Enterprise, compliance, mission-critical
- Benefit: Comprehensive planning for complex systems

**🚀 For Quick Flow (minimal planning, straight to code):**
Load the **quick-flow-solo-dev** agent instead - use Quick Flow agent for faster development

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{{#if brownfield}}
💡 Architecture creates focused solution design from your codebase, keeping AI agents on track.
{{/if}}</output>

<ask>Which Harmony Method approach fits best?

1. Harmony Method {{#if recommended}}(recommended){{/if}}
2. Enterprise Method
3. Help me decide
4. Switch to Quick Flow (use quick-flow-solo-dev agent)

Choice [1/2/3/4]:</ask>

<check if="choice == 4">
  <output>🚀 **Switching to Quick Flow!**

Load the **quick-flow-solo-dev** agent instead:

- Start a new chat
- Load the quick-flow-solo-dev agent
- Use Quick Flow for minimal planning and faster development

Quick Flow is perfect for:

- Simple features and bug fixes
- Rapid prototyping
- When you want to get straight to code

Happy coding! 🚀</output>
<action>Exit workflow</action>
</check>

<check if="choice == 3">
  <ask>What concerns you about choosing?</ask>
  <action>Provide tailored guidance based on concerns</action>
  <action>Loop back to choice</action>
</check>

<action>Map choice to selected_track</action>
<template-output>selected_track</template-output>
</step>

<step n="6" goal="Discovery workflows selection (unified)">
<action>Determine available discovery workflows based on:
- field_type (greenfield gets product-brief option)
- selected_track (method/enterprise options)
</action>

<check if="field_type == greenfield AND selected_track in [method, enterprise]">
  <output>Optional discovery workflows can help clarify your vision:</output>
  <ask>Select any you'd like to include:

1. 🧠 **Brainstorm** - Creative exploration and ideation
2. 🔍 **Research** - Technical/competitive analysis
3. 📋 **Product Brief** - Strategic product planning (recommended)

Enter numbers (e.g., "1,3" or "all" or "none"): </ask>
</check>

<check if="field_type == brownfield AND selected_track in [method, enterprise]">
  <output>Optional discovery workflows:</output>
  <ask>Include any of these?

1. 🧠 **Brainstorm** - Creative exploration
2. 🔍 **Research** - Domain analysis

Enter numbers (e.g., "1,2" or "none"): </ask>
</check>

<action>Parse selections and set:

- brainstorm_requested
- research_requested
- product_brief_requested (if applicable)
  </action>

<template-output>brainstorm_requested</template-output>
<template-output>research_requested</template-output>
<template-output>product_brief_requested</template-output>

<check if="brownfield">
  <output>💡 **Note:** For brownfield projects, run document-project workflow first to analyze your codebase.</output>
</check>
</step>

<step n="7" goal="Detect track from artifacts" if="continuing_existing OR migrating_legacy">
<action>Analyze artifacts to detect track:
- Has PRD → Harmony Method
- Has Security/DevOps → Enterprise Method
- Has tech-spec only → Suggest switching to quick-flow-solo-dev agent
</action>

<output>Detected: **{{detected_track}}** based on {{found_artifacts}}</output>
<ask>Correct? (y/n)</ask>

<ask if="n">Which Harmony Method track instead?

1. Harmony Method
2. Enterprise Method
3. Switch to Quick Flow (use quick-flow-solo-dev agent)

Choice:</ask>

<action>Set selected_track</action>
<template-output>selected_track</template-output>
</step>

<step n="8" goal="Generate workflow path">
<action>Load path file: {path_files}/{{selected_track}}-{{field_type}}.yaml</action>
<action>Build workflow_items from path file</action>
<action>Scan for existing completed work and update statuses</action>
<action>Set generated date</action>

<template-output>generated</template-output>
<template-output>workflow_path_file</template-output>
<template-output>workflow_items</template-output>
</step>

<step n="9" goal="Create tracking file">
<output>Your Harmony workflow path:

**Track:** {{selected_track}}
**Type:** {{field_type}}
**Project:** {{project_name}}

{{#if brownfield}}Prerequisites: document-project{{/if}}
{{#if has_discovery}}Discovery: {{list_selected_discovery}}{{/if}}

{{workflow_path_summary}}
</output>

<ask>Create workflow tracking file? (y/n)</ask>

<check if="y">
  <action>Generate YAML from template with all variables</action>
  <action>Save to {output_folder}/hf-workflow-status.yaml</action>
  <action>Identify next workflow and agent</action>

<output>✅ **Created:** {output_folder}/hf-workflow-status.yaml

**Next:** {{next_workflow_name}}
**Agent:** {{next_agent}}
**Command:** /harmony:workflows:{{next_workflow_id}}

{{#if next_agent not in [analyst, pm]}}
💡 Start new chat with **{{next_agent}}** agent first.
{{/if}}

To check progress: /harmony:workflows:workflow-status

Happy building! 🚀</output>
</check>

</step>

</workflow>
