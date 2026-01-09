# Harmony Costs - API Cost Tracking

> Track and analyze API usage costs per session, agent, and model.

---

## What It Shows

| Metric | Description |
|--------|-------------|
| Total Cost | Session total in USD and EUR |
| By Agent | Cost breakdown per agent (developer, tester, etc.) |
| By Model | Cost breakdown per model (sonnet, opus, haiku) |
| Token Usage | Input/output tokens consumed |
| Exchange Rate | Real-time USD/EUR rate (daily cached) |

---

## Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 Session Cost Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Total Cost:    $0.0234 USD (0.0215 €)
  Exchange Rate: 1 USD = 0.92 EUR
  API Calls:     15
  Input Tokens:  45000
  Output Tokens: 12000

  By Agent:
    developer: $0.0156 (0.0144 €) - 8 calls
    tester: $0.0045 (0.0041 €) - 4 calls
    review: $0.0033 (0.0030 €) - 3 calls

  By Model:
    claude-sonnet-4: $0.0189 (0.0174 €)
    claude-haiku: $0.0045 (0.0041 €)

  Currency preference: USD
  Config: .harmony/local/autopilot-config.json
```

---

## Usage

```bash
# Commands
bash .harmony/lib/cost-tracker.sh --summary      # Full dashboard
bash .harmony/lib/cost-tracker.sh --cost         # Total cost only
bash .harmony/lib/cost-tracker.sh --agents       # Per-agent JSON
bash .harmony/lib/cost-tracker.sh --export       # Export to CSV (stdout)
bash .harmony/lib/cost-tracker.sh --export costs.csv  # Export to file
bash .harmony/lib/cost-tracker.sh --reset        # Start new session
bash .harmony/lib/cost-tracker.sh --estimate sonnet 1000 500  # Estimate cost
```

---

## Model Costs (per 1K tokens)

| Model | Input | Output | Tier |
|-------|-------|--------|------|
| claude-haiku | $0.00025 | $0.00125 | Budget |
| claude-sonnet-4 | $0.003 | $0.015 | Standard |
| claude-opus-4 | $0.015 | $0.075 | Premium |

*Source: Anthropic pricing (January 2026)*

---

## Currency Configuration

Set your preferred currency in `.harmony/local/autopilot-config.json`:

```json
{
  "cost_tracking": {
    "currency": "EUR"
  }
}
```

Supported currencies: `USD` (default), `EUR`

Exchange rate is fetched once daily from exchangerate-api.com and cached.

---

## Files

| File | Description |
|------|-------------|
| `.harmony/lib/cost-tracker.sh` | Cost tracking module |
| `.harmony/memory/session-costs.json` | Current session data |
| `.harmony/memory/.exchange-rate-cache.json` | Daily EUR rate cache |
| `.harmony/local/autopilot-config.json` | Currency preference |

---

## Integration

Cost tracking integrates with:
- **Token Monitor** - Automatic cost estimation on API calls
- **Sentinel** - Cost alerts in circuit breaker
- **Reports** - Include costs in session reports

---

## API (for lib integration)

```bash
source .harmony/lib/cost-tracker.sh

# Track usage
track_usage "claude-sonnet-4" 1000 500 "developer"

# Get data
get_session_cost              # Total cost as string
get_agent_costs               # JSON: {"agent": cost}
get_agent_cost "developer"    # Cost for specific agent
get_call_count                # Number of API calls
get_total_tokens              # "input:output" string
get_session_summary           # Human-readable dashboard

# Currency
get_eur_rate                  # Current EUR/USD rate
usd_to_eur 10.00              # Convert USD to EUR
format_cost 0.05 EUR          # "0.0460 €"
format_cost_dual 0.05         # "$0.0500 (0.0460 €)"
get_preferred_currency        # "USD" or "EUR"

# Control
init_cost_tracking            # Initialize session file
reset_session_costs           # Start new session
export_costs_csv [file]       # Export CSV
```

---

## See Also

- [Tokens](tokens.md) - Token usage monitoring
- [Sentinel](sentinel.md) - Error tracking and circuit breaker
- [Report](report.md) - Full coherence reports
