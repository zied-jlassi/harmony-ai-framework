# Tip: Detection Automatique d'Intention (RouteLLM)

Harmony utilise un **modele leger** pour comprendre automatiquement vos intentions quand les mots-cles ne suffisent pas.

## Par defaut: Haiku

| Provider | Modele Router | Latence | Cout |
|----------|---------------|---------|------|
| **Claude** | haiku | ~400ms | $0.25/1M tokens |
| OpenAI | gpt-4o-mini | ~300ms | $0.15/1M tokens |
| Groq | llama-3.1-8b | ~100ms | Gratuit |

## Comment ca marche ?

```
Vous: "j'ai un probleme avec le formulaire"

1. Harmony cherche des mots-cles → aucun match clair
2. Haiku analyse: "bug UI, probablement dev task"
3. Route vers l'agent DEV automatiquement
```

## Configurer un autre modele

Creez `.harmony/config.yaml` dans votre projet:

```yaml
llm:
  # Router ultra-rapide avec Groq (gratuit)
  router:
    provider: "groq"
    model: "llama-3.1-8b-instant"
```

## Options disponibles

| Option | Description |
|--------|-------------|
| `provider: "groq"` | Utiliser Groq (gratuit, ultra-rapide) |
| `provider: "ollama"` | Modele local (RGPD, offline) |
| `disable_router: true` | Desactiver (keywords uniquement) |

## Documentation

- Config complete: `config/model-tiers.yaml`
- Documentation: `docs/design/MODEL-TIERS-SYSTEM.md`

> Le router est optimise pour etre rapide et economique. Il ne mobilise pas les gros modeles pour une simple classification.
