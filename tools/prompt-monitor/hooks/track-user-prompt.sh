#!/bin/bash
# Harmony Prompt Monitor - User Prompt Hook (UserPromptSubmit)
# Captures user prompts when submitted to Claude Code
#
# This hook is called BEFORE Claude processes the user's message.
# Data is sent asynchronously to not block Claude.

MONITOR_URL="${HARMONY_MONITOR_URL:-http://localhost:8080}"

# Read JSON from stdin with timeout (0.1s) to prevent hanging
INPUT=$(timeout 0.1 cat 2>/dev/null || echo "{}")

# Extract user prompt (silence jq errors if input is not valid JSON)
USER_PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)

# Skip empty prompts
if [ -z "$USER_PROMPT" ]; then
    exit 0
fi

# Format prompt with [User] prefix
FORMATTED_PROMPT="[User] $USER_PROMPT"

# Send to monitor (async, don't block Claude)
curl -s -X POST "$MONITOR_URL/api/track" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
        --arg prompt "$FORMATTED_PROMPT" \
        '{
            prompt: $prompt,
            response: "(pending...)",
            tool_name: "UserPrompt",
            agent: "user"
        }')" \
    > /dev/null 2>&1 &

# Exit 0 to allow prompt to proceed
exit 0
