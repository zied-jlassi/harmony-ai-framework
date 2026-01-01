# Circuit Breaker Protocol

> **Version**: 1.0 (STORY-221)
> **Pattern**: Protection contre boucles infinies et echecs en cascade

## Etats du Circuit

| Etat | Description | Actions Autorisees |
|------|-------------|-------------------|
| **CLOSED** | Normal | Toutes operations |
| **OPEN** | Bloque (3 echecs) | Reset uniquement |
| **HALF-OPEN** | Test recovery | 1 operation test |

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER PROTOCOL                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  AVANT CHAQUE OPERATION CRITIQUE:                               │
│                                                                  │
│  1. Verifier .harmony/memory/circuit-breaker.json                  │
│     └─ Si state = "OPEN" → STOP + Demander reset                │
│     └─ Si state = "CLOSED" → Continuer                          │
│                                                                  │
│  APRES ECHEC:                                                   │
│                                                                  │
│  2. Incrementer failure_count                                   │
│  3. Logger dans history avec timestamp + error                  │
│  4. Si failure_count >= 3:                                      │
│     └─ Passer state a "OPEN"                                    │
│     └─ Afficher "⚠️ Circuit OPEN - 3 echecs consecutifs"        │
│     └─ Lister les erreurs pour diagnostic                       │
│                                                                  │
│  APRES SUCCES:                                                  │
│                                                                  │
│  5. Remettre failure_count a 0                                  │
│  6. Mettre a jour last_success                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Messages Utilisateur

| Situation | Message |
|-----------|---------|
| Retry 1/3 | `⚠️ [Retry 1/3] Operation echouee, nouvelle tentative...` |
| Retry 2/3 | `⚠️ [Retry 2/3] Second echec, derniere tentative...` |
| Circuit OPEN | `🛑 Circuit OPEN - 3 echecs consecutifs. Diagnostic requis.` |
| Reset | `✅ Circuit reset - Operations autorisees` |

## Operations Trackees

- `file_write` - Ecriture de fichiers
- `code_implementation` - Implementation de code
- `test_execution` - Execution de tests
- `build` - Compilation/build
- `deploy` - Deploiement

## Commande Reset

```
/reset-circuit
```

Reset le circuit breaker a l'etat CLOSED et failure_count a 0.

## Integration Agent

Ajouter dans la section "Pre-execution checks" de chaque agent:

```markdown
### Circuit Breaker Check

1. Lire `.harmony/memory/circuit-breaker.json`
2. Si `state === "OPEN"`:
   - Afficher erreurs recentes depuis `history`
   - Demander diagnostic et correction
   - Attendre `/reset-circuit` avant de continuer
3. Si `state === "CLOSED"`: Continuer normalement
```
