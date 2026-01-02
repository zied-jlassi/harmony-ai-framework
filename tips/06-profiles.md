# Tip: Configurez votre boîte à outils

Harmony **auto-détecte** votre stack et active les bons outils.

```bash
/harmony init
```

## Détection automatique

| Fichier détecté | Outils activés |
|-----------------|----------------|
| `package.json` | nodejs, npm scripts |
| `tsconfig.json` | typescript, types |
| `nest-cli.json` | nestjs, modules, guards |
| `prisma/schema.prisma` | prisma, migrations |
| `angular.json` | angular, components |

## Votre boîte à outils

```
Profiles activés → Agents adaptés → Knowledge chargé
     ↓                   ↓               ↓
  nestjs            Developer       API patterns
  prisma            Architect       SQL optimization
  typescript        Tester          Type testing
```

## Specialties (optionnel)

Ajoutez une expertise métier :

```bash
/harmony specialties --add gaming    # Jeux, scores, leaderboards
/harmony specialties --add security  # OWASP, pentest, RGPD
/harmony specialties --add ai        # RAG, LLM, embeddings
```

> Comme un garagiste qui choisit ses outils selon la voiture !
