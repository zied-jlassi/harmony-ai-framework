# Tip: Harmony Sentinel vous protège

Le **Sentinel** active un **circuit breaker** après N échecs.

```bash
/harmony sentinel         # Dashboard
/harmony sentinel --reset # Réinitialiser
```

| État | Signification |
|------|---------------|
| CLOSED | Normal |
| OPEN | Bloqué, diagnostic requis |

**Config:** `.harmony/local/autopilot-config.json`
```json
"circuit_breaker": {
  "max_failures_per_story": 10
}
```
