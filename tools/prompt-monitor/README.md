# Harmony Prompt Monitor

Monitor and analyze prompt effectiveness to improve your interactions with LLMs.

## Features

- **Prompt Clarity Score** - Measures how clear and specific your prompts are
- **Response Quality Score** - Evaluates the quality of LLM responses
- **Alignment Score** - Correlates prompt clarity with response quality
- **Cost Tracking** - Track API costs per request and session
- **Trends & Insights** - Learn from your prompting patterns over time
- **Web Dashboard** - Real-time visualization of your metrics

## Installation

```bash
# From PyPI (when published)
pip install harmony-prompt-monitor

# From source
cd tools/harmony-prompt-monitor
pip install -e .
```

## Usage

### Web Dashboard

```bash
# Start the web server
harmony-monitor serve --port 8080

# Open http://localhost:8080 in your browser
```

### MCP Server (Claude Code Integration)

Add to your `.claude/settings.json`:

```json
{
  "mcpServers": {
    "harmony-monitor": {
      "command": "harmony-monitor",
      "args": ["mcp"]
    }
  }
}
```

### CLI

```bash
# Analyze a prompt
harmony-monitor analyze "How do I create a REST API?"

# Analyze prompt with response
harmony-monitor analyze "Create a login function" --response "Here's a function..."

# Show statistics
harmony-monitor stats --days 7
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Dashboard HTML |
| `/api/dashboard` | GET | Complete dashboard data |
| `/api/sessions` | GET | List sessions |
| `/api/sessions/{id}` | GET | Get session details |
| `/api/requests` | GET | List requests |
| `/api/track` | POST | Track a new request |
| `/api/stats/{session_id}` | GET | Session statistics |
| `/api/trends` | GET | Trend data |
| `/api/insights` | GET | Insights and tips |
| `/health` | GET | Health check |

## Metrics Explained

### Prompt Clarity Score (0-100)

Factors:
- **Length** (20 pts): Optimal 50-500 characters
- **Context** (20 pts): Background info provided
- **Specificity** (25 pts): Clear, targeted questions
- **Examples** (20 pts): Code samples included
- **Constraints** (15 pts): Explicit requirements

### Response Quality Score (0-100)

Factors:
- **Completeness** (30 pts): Substantial response
- **Structure** (30 pts): Code blocks, lists, formatting
- **Concreteness** (25 pts): Actionable suggestions
- **Vagueness** (-25 pts): Penalty for uncertain language

### Alignment Categories

| Category | Condition | Meaning |
|----------|-----------|---------|
| **Optimal** | Clarity ≥70, Quality ≥70 | Perfect interaction |
| **Impressive** | Clarity <50, Quality ≥70 | LLM exceeded expectations |
| **Problem** | Clarity ≥70, Quality <50 | Something went wrong |
| **Expected** | Clarity <50, Quality <50 | Vague in = vague out |

## Configuration

Environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `HARMONY_DIR` | `.harmony` | Base directory for data |
| `MONITOR_PORT` | `8080` | Web server port |
| `MONITOR_DB` | `.harmony/monitor/data.db` | SQLite database path |

## Development

```bash
# Install dev dependencies
pip install -e ".[dev]"

# Run tests
pytest

# Run with auto-reload
harmony-monitor serve --reload
```

## License

MIT
