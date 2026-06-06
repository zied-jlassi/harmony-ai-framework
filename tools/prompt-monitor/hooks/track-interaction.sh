#!/bin/bash
# Harmony Prompt Monitor - Claude Code Hook
# Captures tool interactions and sends to monitor API
#
# Usage: Add to .claude/settings.json:
# {
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "*",
#       "command": "/path/to/track-interaction.sh"
#     }]
#   }
# }

MONITOR_URL="${HARMONY_MONITOR_URL:-http://localhost:8080}"

# Read JSON from stdin with timeout (0.1s) to prevent hanging
INPUT=$(timeout 0.1 cat 2>/dev/null || echo "{}")

# Extract tool info
TOOL_NAME=$(echo "$INPUT" | jq -r 2>/dev/null '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -r 2>/dev/null '.tool_input // "{}"')

# Extract response based on tool type (Claude Code uses tool_response, not tool_result)
if [ "$TOOL_NAME" = "Read" ]; then
    TOOL_RESPONSE=$(echo "$INPUT" | jq -r 2>/dev/null '.tool_response.file.content // ""' | head -c 10000)
elif [ "$TOOL_NAME" = "Bash" ]; then
    TOOL_RESPONSE=$(echo "$INPUT" | jq -r 2>/dev/null '.tool_response.stdout // .tool_response // ""' | head -c 10000)
else
    TOOL_RESPONSE=$(echo "$INPUT" | jq -r 2>/dev/null '.tool_response | if type == "object" then (. | tostring) else . end // ""' | head -c 10000)
fi

# Skip if no meaningful data
if [ -z "$TOOL_INPUT" ] || [ "$TOOL_INPUT" = "{}" ]; then
    exit 0
fi

# Format prompt from tool input - capture more details
case "$TOOL_NAME" in
    Bash)
        PROMPT="[Bash] $(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.command // ""' | head -c 1000)"
        ;;
    Read)
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.file_path // ""')
        PROMPT="[Read] $FILE_PATH"
        ;;
    Write)
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.file_path // ""')
        CONTENT=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.content // ""' | head -c 3000)
        PROMPT="[Write] $FILE_PATH
--- Content (truncated) ---
$CONTENT"
        ;;
    Edit)
        FILE_PATH=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.file_path // ""')
        OLD_STR=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.old_string // ""' | head -c 1000)
        NEW_STR=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.new_string // ""' | head -c 1000)
        PROMPT="[Edit] $FILE_PATH
--- Old ---
$OLD_STR
--- New ---
$NEW_STR"
        ;;
    Grep)
        PATTERN=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.pattern // ""')
        PATH_ARG=$(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.path // "."')
        PROMPT="[Grep] $PATTERN in $PATH_ARG"
        ;;
    Glob)
        PROMPT="[Glob] $(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.pattern // ""')"
        ;;
    Task)
        PROMPT="[Task] $(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.prompt // ""' | head -c 2000)"
        ;;
    WebFetch)
        PROMPT="[WebFetch] $(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.url // ""')"
        ;;
    WebSearch)
        PROMPT="[WebSearch] $(echo "$TOOL_INPUT" | jq -r 2>/dev/null '.query // ""')"
        ;;
    *)
        PROMPT="[$TOOL_NAME] $(echo "$TOOL_INPUT" | jq -c 2>/dev/null '.' | head -c 1000)"
        ;;
esac

# Response - use extracted tool response
RESPONSE="$TOOL_RESPONSE"

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
