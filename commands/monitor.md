# /harmony monitor

> Team Learning Journal - Track and improve your prompting skills

## Overview

The Prompt Monitor is a real-time dashboard that tracks all your Claude Code interactions, analyzes prompt effectiveness, and provides learning insights to help you become a better AI collaborator.

## Prerequisites

**Python 3.8+** is required for the Prompt Monitor.

```bash
# Install Python dependencies
pip3 install -r .harmony/tools/prompt-monitor/requirements.txt

# Or install manually
pip3 install fastapi uvicorn aiosqlite pydantic httpx
```

## Quick Start

```bash
# Install monitor and configure hook
harmony monitor install

# Start the dashboard
harmony monitor start

# Open in browser
harmony monitor open
```

## Commands

| Command | Description |
|---------|-------------|
| `harmony monitor install` | Install monitor and configure auto-tracking hook |
| `harmony monitor start` | Start the monitor server (port 8080) |
| `harmony monitor stop` | Stop the monitor server |
| `harmony monitor restart` | Restart the monitor server |
| `harmony monitor status` | Check if monitor is running + stats |
| `harmony monitor open` | Open dashboard in browser |
| `harmony monitor hook` | Reconfigure Claude Code hook |
| `harmony monitor reset` | Reset all history data (prompts confirmation) |
| `harmony monitor reset --force` | Reset without confirmation |

## Dashboard Features

### Real-time Metrics
- **Total Requests**: Number of interactions tracked
- **Total Cost**: Cumulative API cost
- **Avg Clarity**: Average prompt clarity score (0-100)
- **Avg Quality**: Average response quality score (0-100)
- **Avg Alignment**: Prompt-response alignment score

### Alignment Categories
- **OPTIMAL**: Clear prompt + Clear response (goal!)
- **IMPRESSIVE**: Vague prompt + Clear response (AI helped)
- **PROBLEM**: Clear prompt + Vague response (investigate)
- **EXPECTED**: Vague prompt + Vague response (improve prompt)

### Learning Mode

Click any request to see detailed analysis:

1. **Mental Model Visualization**
   - Visual breakdown of your prompt's structure
   - Context, Specificity, Examples, Constraints scores
   - Status: ✓ BON PROMPT | ⚠ A AMELIORER | ✗ TROP VAGUE

2. **Thinking Patterns**
   - Missing Context: You assume AI knows your context
   - Implicit Requirements: Unexpressed expectations
   - Abstract Thinking: Need concrete examples

3. **Why Response Differs**
   - Ambiguity detected in prompt
   - No clear question found
   - Mismatch between expectation and output

4. **Learning Tips** (by level)
   - 🔰 Fundamental: Basic prompt structure
   - 📈 Intermediate: Context improvement
   - 🎯 Advanced: Example-driven prompting
   - 🔬 Diagnostic: Response analysis

## Prompt Scoring Algorithm

### Clarity Score (0-100)
| Factor | Weight | How to Improve |
|--------|--------|----------------|
| Length | 20 | 50-500 characters optimal |
| Context | 20 | Add "Given that...", "In the context of..." |
| Specificity | 25 | Use "How do I X using Y?" not "How to X?" |
| Examples | 20 | Include code samples or expected output |
| Constraints | 15 | Use "must", "should not", "using only" |

### Quality Score (0-100)
| Factor | Weight | Indicator |
|--------|--------|-----------|
| Completeness | 30 | Response length and detail |
| Structure | 30 | Code blocks, lists, formatting |
| Concreteness | 25 | Actionable steps and commands |
| Vagueness | -25 | Penalty for uncertain language |

## API Endpoints

For custom integrations:

```bash
# Track a request
curl -X POST http://localhost:8080/api/track \
  -H "Content-Type: application/json" \
  -d '{"prompt": "your prompt", "response": "ai response"}'

# Get dashboard data
curl http://localhost:8080/api/dashboard

# Get request detail with learning insights
curl http://localhost:8080/api/requests/1/detail

# Reset all data
curl -X DELETE "http://localhost:8080/api/reset?confirm=true"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HARMONY_MONITOR_PORT` | 8080 | Dashboard port |
| `HARMONY_MONITOR_URL` | http://localhost:8080 | API URL for hook |

## Auto-Tracking Hook

The monitor automatically configures a Claude Code hook that captures all tool interactions:

```json
// ~/.claude/settings.json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "*",
      "command": "~/.harmony/tools/prompt-monitor/hooks/track-interaction.sh"
    }]
  }
}
```

**Note**: Restart Claude Code after installation for the hook to take effect.

## Best Practices

1. **Start each session**: Run `harmony monitor start` before coding
2. **Review regularly**: Check dashboard after complex tasks
3. **Learn from PROBLEM category**: Investigate why clear prompts got vague responses
4. **Use improved prompts**: Copy suggested prompts from Learning Mode
5. **Team reviews**: Share dashboard for collective learning

## See Also

- [/harmony costs](costs.md) - API cost tracking
- [Patterns](../patterns/P-014-react-respond.md) - Prompt patterns
