#!/bin/bash
# =============================================================================
# hook-ui.sh — Shared visible-status helper for Harmony hooks
# =============================================================================
# Purpose: give the user PROOF that a guard/hook actually triggered.
#
# Claude Code hook output contract (verified against official docs):
#   - stdout of a non-blocking (exit 0) PreToolUse/PostToolUse hook is NOT shown
#     in the transcript — EXCEPT a JSON `systemMessage`, which is displayed to
#     the user as a status/warning line.
#   - stderr is the debug channel (shown to Claude on exit 2 / block).
#
# Contract enforced here:
#   stdout = AT MOST one JSON object (systemMessage)  → user-visible proof
#   stderr = decorative / debug text                  → never breaks JSON
#
# Toggle: HARMONY_HOOK_UI=off  silences user-visible status (debug still on stderr).
# =============================================================================

# Is user-visible status enabled? (default: on)
hook_ui_enabled() { [[ "${HARMONY_HOOK_UI:-on}" != "off" ]]; }

# Emit a user-visible status line (JSON systemMessage on stdout, exit-0 path).
# Prints nothing if UI disabled. Call AT MOST once per hook (stdout must stay
# valid JSON). Usage: hook_status "🛡️ Rules: clean (no interdiction)"
hook_status() {
    hook_ui_enabled || return 0
    local msg="$1"
    if command -v jq &>/dev/null; then
        jq -nc --arg m "$msg" '{systemMessage:$m}'
    else
        # Minimal JSON escaping fallback (no jq)
        msg=${msg//\\/\\\\}; msg=${msg//\"/\\\"}
        printf '{"systemMessage":"%s"}\n' "$msg"
    fi
}

# Decorative / debug output → stderr only (keeps stdout JSON-clean).
# Usage: hook_debug "Detailed box / colors / explanation…"
hook_debug() { printf '%b\n' "$*" >&2; }

# Block the action (exit 2) with a reason on stderr (shown to Claude).
# Caller may prefer to exit 2 itself; this is a convenience.
# Usage: hook_block "🛑 BLOCKED: rm -rf / is destructive"
hook_block() {
    printf '%b\n' "$*" >&2
    exit 2
}
