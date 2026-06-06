# /hf:security:guards — Gestion des guards de sécurité

Active, désactive et configure les hooks de protection Harmony.

## Action

Exécute le script engine avec les arguments fournis :

```bash
bash ${HARMONY_DIR}/lib/security-guards.sh $ARGUMENTS
```

Puis présente le résultat à l'utilisateur de façon claire.

## Guards disponibles

| Guard | Rôle | Modes |
|-------|------|-------|
| `supply-chain` | Vérifie les installations de packages (npm/pip/composer/cargo...) contre les vulnérabilités, typosquatting et sources non-officielles | `block` (bloque) / `warn` (alerte seulement) |
| `llm-sanitizer` | Filtre le contenu externe (WebFetch, curl, réponses LLM) contre les injections de prompt, exfiltration, secrets exposés | `external-only` (sources externes) / `strict` (+ lectures de fichiers) |

## Commandes

```bash
/hf:security:guards status                      # Afficher l'état actuel
/hf:security:guards on                          # Activer tous les guards
/hf:security:guards off                         # Désactiver tous les guards
/hf:security:guards on supply-chain             # Activer un guard spécifique
/hf:security:guards off llm-sanitizer           # Désactiver un guard spécifique
/hf:security:guards mode supply-chain warn      # Changer le mode
/hf:security:guards mode llm-sanitizer strict   # Mode strict (inclut Read)
```

## Override temporaire (sans modifier la config)

```bash
export HARMONY_GUARDS=off    # Désactive tout instantanément (CI, debug)
```

## Notes

- La config est persistée dans `${HARMONY_DIR}/local/security-guards.json`
- Quand un guard est désactivé, son hook sort en quelques millisecondes (zéro impact perf)
- Documentation complète : `${HARMONY_DIR}/docs/security-guards.md`
