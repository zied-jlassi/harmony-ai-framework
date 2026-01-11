#!/bin/bash
# Harmony Prompt Monitor - Installation and Management
# Part of Harmony Framework
#
# Can run standalone or as part of Harmony Framework.
# Detects Claude Code session and configures hook automatically.
#
# Commands:
#   install  - Install monitor dependencies and hook
#   start    - Start the monitor server
#   stop     - Stop the monitor server
#   restart  - Restart the monitor server
#   status   - Check if monitor is running
#   open     - Open dashboard in browser
#   hook     - Reconfigure Claude Code hook
#   reset    - Reset all history data

# Detect monitor directory (standalone or harmony-installed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check locations in order: 1) alongside script, 2) harmony installed, 3) dev path
if [[ -d "$SCRIPT_DIR/../tools/prompt-monitor" ]]; then
    MONITOR_DIR="$SCRIPT_DIR/../tools/prompt-monitor"
elif [[ -d "${HARMONY_DIR:-$HOME/.harmony}/tools/prompt-monitor" ]]; then
    MONITOR_DIR="${HARMONY_DIR:-$HOME/.harmony}/tools/prompt-monitor"
elif [[ -d "$SCRIPT_DIR/../../tools/harmony-prompt-monitor" ]]; then
    # Development path
    MONITOR_DIR="$SCRIPT_DIR/../../tools/harmony-prompt-monitor"
else
    MONITOR_DIR="$HOME/.harmony/tools/prompt-monitor"
fi

MONITOR_PORT="${HARMONY_MONITOR_PORT:-8080}"
MONITOR_PID_FILE="/tmp/harmony-monitor.pid"
MONITOR_LOG="/tmp/harmony-monitor.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

monitor_install() {
    echo -e "${CYAN}[Harmony] Installing Prompt Monitor...${NC}"

    # Check Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}Error: Python 3 is required${NC}"
        return 1
    fi

    # Create directory
    mkdir -p "$MONITOR_DIR"

    # Copy monitor files from framework
    FRAMEWORK_MONITOR="$(dirname "${BASH_SOURCE[0]}")/../tools/prompt-monitor"
    if [ -d "$FRAMEWORK_MONITOR" ]; then
        cp -r "$FRAMEWORK_MONITOR"/* "$MONITOR_DIR/"
    else
        echo -e "${YELLOW}Warning: Monitor files not found in framework${NC}"
        echo -e "Installing from pip..."
    fi

    # Install Python dependencies
    echo -e "${CYAN}Installing Python dependencies...${NC}"
    pip3 install --user fastapi uvicorn aiosqlite pydantic 2>/dev/null || {
        echo -e "${YELLOW}Warning: Some dependencies may need manual installation${NC}"
    }

    # Install hook
    monitor_install_hook

    echo -e "${GREEN}[Harmony] Prompt Monitor installed!${NC}"
    echo -e "  Start: ${CYAN}harmony monitor start${NC}"
    echo -e "  Dashboard: ${CYAN}http://localhost:$MONITOR_PORT${NC}"
}

monitor_install_hook() {
    echo -e "${CYAN}[Harmony] Configuring Claude Code hook...${NC}"

    local HOOK_SCRIPT="$MONITOR_DIR/hooks/track-interaction.sh"
    local SETTINGS_FILE="$HOME/.claude/settings.json"

    # Create hook script
    mkdir -p "$MONITOR_DIR/hooks"
    cat > "$HOOK_SCRIPT" << 'HOOK_EOF'
#!/bin/bash
# Harmony Prompt Monitor - Auto-tracking Hook
MONITOR_URL="${HARMONY_MONITOR_URL:-http://localhost:8080}"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // "{}"')
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // ""' | head -c 2000)

[ -z "$TOOL_INPUT" ] || [ "$TOOL_INPUT" = "{}" ] && exit 0

case "$TOOL_NAME" in
    Bash) PROMPT="[Bash] $(echo "$TOOL_INPUT" | jq -r '.command // ""' | head -c 500)" ;;
    Read) PROMPT="[Read] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')" ;;
    Write) PROMPT="[Write] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')" ;;
    Edit) PROMPT="[Edit] $(echo "$TOOL_INPUT" | jq -r '.file_path // ""')" ;;
    Grep) PROMPT="[Grep] $(echo "$TOOL_INPUT" | jq -r '.pattern // ""')" ;;
    Glob) PROMPT="[Glob] $(echo "$TOOL_INPUT" | jq -r '.pattern // ""')" ;;
    Task) PROMPT="[Task] $(echo "$TOOL_INPUT" | jq -r '.prompt // ""' | head -c 500)" ;;
    WebFetch) PROMPT="[WebFetch] $(echo "$TOOL_INPUT" | jq -r '.url // ""')" ;;
    WebSearch) PROMPT="[WebSearch] $(echo "$TOOL_INPUT" | jq -r '.query // ""')" ;;
    *) PROMPT="[$TOOL_NAME] $(echo "$TOOL_INPUT" | jq -c '.' | head -c 500)" ;;
esac

RESPONSE=$(echo "$TOOL_RESULT" | head -c 1500)
[ -z "$PROMPT" ] || [ "$PROMPT" = "[$TOOL_NAME] " ] && exit 0

curl -s -X POST "$MONITOR_URL/api/track" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg p "$PROMPT" --arg r "$RESPONSE" --arg t "$TOOL_NAME" \
        '{prompt:$p,response:$r,tool_name:$t,agent:"claude-code"}')" \
    > /dev/null 2>&1 &
exit 0
HOOK_EOF
    chmod +x "$HOOK_SCRIPT"

    # Update Claude settings
    if [ -f "$SETTINGS_FILE" ]; then
        # Check if hook already exists
        if grep -q "track-interaction.sh" "$SETTINGS_FILE" 2>/dev/null; then
            echo -e "${YELLOW}Hook already configured${NC}"
            return 0
        fi

        # Add hook to existing settings
        local TEMP_FILE=$(mktemp)
        jq --arg hook "$HOOK_SCRIPT" '.hooks.PostToolUse = [{"matcher": "*", "command": $hook}]' \
            "$SETTINGS_FILE" > "$TEMP_FILE" 2>/dev/null && mv "$TEMP_FILE" "$SETTINGS_FILE"
    else
        # Create new settings file
        mkdir -p "$HOME/.claude"
        cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "PostToolUse": [
      {"matcher": "*", "command": "$HOOK_SCRIPT"}
    ]
  }
}
EOF
    fi

    echo -e "${GREEN}Hook configured!${NC}"
    echo -e "${YELLOW}Restart Claude Code for hook to take effect${NC}"
}

monitor_start() {
    if monitor_is_running; then
        echo -e "${YELLOW}[Harmony] Monitor already running on port $MONITOR_PORT${NC}"
        echo -e "  Dashboard: ${CYAN}http://localhost:$MONITOR_PORT${NC}"
        return 0
    fi

    echo -e "${CYAN}[Harmony] Starting Prompt Monitor on port $MONITOR_PORT...${NC}"
    echo -e "${CYAN}  Monitor dir: $MONITOR_DIR${NC}"

    # Check if monitor exists
    if [[ ! -d "$MONITOR_DIR" ]]; then
        echo -e "${RED}Error: Monitor directory not found: $MONITOR_DIR${NC}"
        echo -e "${YELLOW}Run: harmony monitor install${NC}"
        return 1
    fi

    # Check for harmony_monitor package
    if [[ ! -d "$MONITOR_DIR/harmony_monitor" ]]; then
        echo -e "${RED}Error: harmony_monitor package not found${NC}"
        return 1
    fi

    cd "$MONITOR_DIR" || return 1

    # Start server in background
    nohup python3 -m uvicorn harmony_monitor.api:app \
        --host 0.0.0.0 --port "$MONITOR_PORT" \
        > "$MONITOR_LOG" 2>&1 &

    echo $! > "$MONITOR_PID_FILE"
    sleep 2

    if monitor_is_running; then
        echo -e "${GREEN}[Harmony] Monitor started!${NC}"
        echo -e "  Dashboard: ${CYAN}http://localhost:$MONITOR_PORT${NC}"
        echo -e "  Logs: ${CYAN}$MONITOR_LOG${NC}"

        # Check if Claude Code is running and suggest hook
        if pgrep -f "claude" > /dev/null 2>&1; then
            echo -e "${YELLOW}  Claude detected! Run 'harmony monitor hook' to enable auto-tracking${NC}"
        fi
    else
        echo -e "${RED}Failed to start monitor. Check logs: $MONITOR_LOG${NC}"
        cat "$MONITOR_LOG" 2>/dev/null | tail -10
        return 1
    fi
}

monitor_stop() {
    if [ -f "$MONITOR_PID_FILE" ]; then
        local PID=$(cat "$MONITOR_PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            rm -f "$MONITOR_PID_FILE"
            echo -e "${GREEN}[Harmony] Monitor stopped${NC}"
            return 0
        fi
    fi

    # Try to find and kill by port
    local PID=$(lsof -t -i:$MONITOR_PORT 2>/dev/null | head -1)
    if [ -n "$PID" ]; then
        kill "$PID" 2>/dev/null
        echo -e "${GREEN}[Harmony] Monitor stopped${NC}"
    else
        echo -e "${YELLOW}[Harmony] Monitor not running${NC}"
    fi
}

monitor_status() {
    if monitor_is_running; then
        echo -e "${GREEN}[Harmony] Monitor is RUNNING${NC}"
        echo -e "  URL: http://localhost:$MONITOR_PORT"
        echo -e "  PID: $(cat "$MONITOR_PID_FILE" 2>/dev/null || lsof -t -i:$MONITOR_PORT 2>/dev/null | head -1)"

        # Get stats
        local STATS=$(curl -s "http://localhost:$MONITOR_PORT/api/dashboard" 2>/dev/null)
        if [ -n "$STATS" ]; then
            local TOTAL=$(echo "$STATS" | jq -r '.current_session.total_requests // 0')
            local COST=$(echo "$STATS" | jq -r '.current_session.total_cost // 0')
            echo -e "  Requests: $TOTAL"
            echo -e "  Cost: \$$COST"
        fi
    else
        echo -e "${RED}[Harmony] Monitor is STOPPED${NC}"
        echo -e "  Start with: harmony monitor start"
    fi
}

monitor_open() {
    if ! monitor_is_running; then
        echo -e "${YELLOW}Starting monitor first...${NC}"
        monitor_start
    fi

    local URL="http://localhost:$MONITOR_PORT"

    # Try to open browser
    if command -v xdg-open &> /dev/null; then
        xdg-open "$URL" 2>/dev/null &
    elif command -v open &> /dev/null; then
        open "$URL" 2>/dev/null &
    else
        echo -e "Open in browser: ${CYAN}$URL${NC}"
    fi
}

monitor_reset() {
    if ! monitor_is_running; then
        echo -e "${RED}[Harmony] Monitor not running${NC}"
        echo -e "  Start with: harmony monitor start"
        return 1
    fi

    echo -e "${YELLOW}[Harmony] Resetting all monitor data...${NC}"
    echo -e "${YELLOW}  This will delete all tracked requests and sessions.${NC}"

    # Ask for confirmation unless --force is passed
    if [[ "$1" != "--force" && "$1" != "-f" ]]; then
        read -p "Are you sure? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo -e "${CYAN}Reset cancelled${NC}"
            return 0
        fi
    fi

    # Call reset API with confirmation
    local result=$(curl -s -X DELETE "http://localhost:$MONITOR_PORT/api/reset?confirm=true" 2>/dev/null)

    if echo "$result" | grep -q '"status":"reset_complete"'; then
        echo -e "${GREEN}[Harmony] Monitor data reset successfully!${NC}"
        echo -e "  All requests and sessions have been cleared."
    else
        echo -e "${RED}[Harmony] Reset failed${NC}"
        echo -e "  Response: $result"
        return 1
    fi
}

monitor_is_running() {
    if [ -f "$MONITOR_PID_FILE" ]; then
        local PID=$(cat "$MONITOR_PID_FILE")
        if kill -0 "$PID" 2>/dev/null; then
            return 0
        fi
    fi

    # Check by port
    lsof -i:$MONITOR_PORT &>/dev/null
}

# Main command handler
monitor_main() {
    local CMD="${1:-status}"

    case "$CMD" in
        install)
            monitor_install
            ;;
        start)
            monitor_start
            ;;
        stop)
            monitor_stop
            ;;
        restart)
            monitor_stop
            sleep 1
            monitor_start
            ;;
        status)
            monitor_status
            ;;
        open)
            monitor_open
            ;;
        hook)
            monitor_install_hook
            ;;
        reset)
            monitor_reset "$2"
            ;;
        *)
            echo "Harmony Prompt Monitor"
            echo ""
            echo "Usage: harmony monitor <command>"
            echo ""
            echo "Commands:"
            echo "  install  - Install monitor and configure hook"
            echo "  start    - Start the monitor server"
            echo "  stop     - Stop the monitor server"
            echo "  restart  - Restart the monitor server"
            echo "  status   - Check monitor status"
            echo "  open     - Open dashboard in browser"
            echo "  hook     - Reconfigure Claude Code hook"
            echo "  reset    - Reset all history data (--force to skip confirmation)"
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    monitor_main "$@"
fi
