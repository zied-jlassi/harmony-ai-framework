#!/bin/bash
# Harmony Prompt Monitor - Claude Code Hook (PostToolUse)
# Captures tool interactions and sends to monitor API
#
# This hook is called AFTER each tool execution.
# Data is sent asynchronously to not block Claude.

MONITOR_URL="${HARMONY_MONITOR_URL:-http://localhost:8080}"

# Read JSON from stdin
INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // "{}"')
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // ""' | head -c 2000)

# Skip if no meaningful data
if [ -z "$TOOL_INPUT" ] || [ "$TOOL_INPUT" = "{}" ]; then
    exit 0
fi

# Format prompt from tool input
case "$TOOL_NAME" in
    Bash)
        PROMPT="[Bash] $(echo "$TOOL_INPUT" | jq -r '.command // ""' | head -c 500)"
        ;;
    Read)
        PROMPT="[Read] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')"
        ;;
    Write)
        PROMPT="[Write] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')"
        ;;
    Edit)
        PROMPT="[Edit] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')"
        ;;
    Grep)
        PROMPT="[Grep] $(echo "$TOOL_INPUT" | jq -r '.pattern // ""')"
        ;;
    Glob)
        PROMPT="[Glob] $(echo "$TOOL_INPUT" | jq -r '.pattern // ""')"
        ;;
    Task)
        PROMPT="[Task] $(echo "$TOOL_INPUT" | jq -r '.prompt // ""' | head -c 500)"
        ;;
    WebFetch)
        PROMPT="[WebFetch] $(echo "$TOOL_INPUT" | jq -r '.url // ""')"
        ;;
    WebSearch)
        PROMPT="[WebSearch] $(echo "$TOOL_INPUT" | jq -r '.query // ""')"
        ;;
    *)
        PROMPT="[$TOOL_NAME] $(echo "$TOOL_INPUT" | jq -c '.' | head -c 500)"
        ;;
esac

# Truncate response
RESPONSE=$(echo "$TOOL_RESULT" | head -c 1500)

# Skip empty prompts
if [ -z "$PROMPT" ] || [ "$PROMPT" = "[$TOOL_NAME] " ]; then
    exit 0
fi

# Send to monitor (async, don't block Claude)
curl -s -X POST "$MONITOR_URL/api/track" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg prompt "$PROMPT" \
        --arg response "$RESPONSE" \
        --arg tool "$TOOL_NAME" \
        '{
            prompt: $prompt,
            response: $response,
            tool_name: $tool,
            agent: "claude-code"
        }')" \
    > /dev/null 2>&1 &

exit 0
