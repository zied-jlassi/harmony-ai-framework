# Tip: Harmony Sentinel vous protège

Le **Sentinel** surveille les erreurs et active un **circuit breaker** après 3 échecs consécutifs.

```bash
/harmony sentinel         # Voir le dashboard
/harmony sentinel --reset # Réinitialiser si bloqué
```

| État | Signification |
|------|---------------|
| CLOSED | Normal, tout fonctionne |
| OPEN | Bloqué après 3 erreurs, diagnostic requis |

> Ce tip ne s'affichera plus après cette session.
