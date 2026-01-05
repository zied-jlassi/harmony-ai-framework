# .harmony/local - Configuration & Customization

This directory contains local configuration files that override framework defaults.

## Why .harmony/local?

- ✅ Framework code in `framework/` stays read-only
- ✅ Your configurations in `.harmony/local/` don't conflict with framework updates
- ✅ Easy to customize without modifying framework
- ✅ Safe to version control (ignore patterns in place)

## Configuration Files

### autopilot-config.json

Override Sprint Autopilot parameters:

```json
{
  "circuit_breaker": {
    "max_failures_per_story": 10,    // ← Change this
    "max_failures_per_phase": 5      // ← Or this
  },
  "api_budget": {
    "api_calls_limit": 10000,        // ← Increase budget
    "warning_threshold_percent": 80  // ← Change warning level
  }
}
```

**To use**: Framework automatically reads this file at runtime.

## Examples

### Example 1: Increase API Budget

```json
{
  "api_budget": {
    "api_calls_limit": 20000
  }
}
```

### Example 2: Stricter Circuit Breaker

```json
{
  "circuit_breaker": {
    "max_failures_per_story": 5,
    "max_failures_per_phase": 2
  }
}
```

### Example 3: Custom Completion Signals

```json
{
  "completion_signals": {
    "developer": [
      "Implementation complete",
      "READY FOR TESTING",
      "feature implemented"
    ]
  }
}
```

## Priority Order

1. `.harmony/local/autopilot-config.json` (highest priority - your overrides)
2. Framework defaults (lowest priority - framework code)

Any value in local config overrides framework defaults.

## Memory & State

State files are also stored here:
- `working.json` - Sprint/story state
- `workflow-state.json` - Phase/agent state
- `circuit-breaker.json` - Safety tracking
- `error-journal.json` - Error history

These are created automatically.

## Not in Framework

Nothing in `.harmony/` is part of the framework. This folder is:
- ✅ Completely local (not committed to git)
- ✅ Yours to customize
- ✅ Safe to modify
- ✅ Ignored by framework updates
