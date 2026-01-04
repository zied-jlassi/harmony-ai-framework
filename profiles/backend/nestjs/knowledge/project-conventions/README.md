# Conventions Projet - À Personnaliser

> Ce dossier contient les conventions SPÉCIFIQUES à votre projet.
> Ce qui est DIFFÉRENT des standards industrie.

---

## Comment Remplir

1. **Identifier** ce qui est unique à votre projet
2. **Documenter** les décisions d'équipe
3. **Expliquer** pourquoi (pas juste quoi)

---

## Fichiers à Créer

| Fichier | Contenu |
|---------|---------|
| `api-patterns.md` | Vos patterns API (si différents du standard) |
| `naming.md` | Conventions de nommage spécifiques |
| `security.md` | Règles de sécurité additionnelles |
| `integrations.md` | Comment votre stack s'intègre |

---

## Template de Convention

```markdown
# [Nom de la Convention]

## Contexte
Pourquoi cette convention existe (décision d'équipe, contrainte technique, etc.)

## Règle
Ce qu'il faut faire / ne pas faire

## Exemple
\`\`\`typescript
// ✅ BON
code correct...

// ❌ MAUVAIS
code incorrect...
\`\`\`

## Exceptions
Cas où cette règle ne s'applique pas
```

---

## Exemple: Pattern Search Resource

Si votre projet utilise POST au lieu de GET pour les listings :

```markdown
# Pattern Search Resource

## Contexte
Décision d'équipe pour éviter les paramètres sensibles dans les URLs/logs.

## Règle
Utiliser POST + Body pour tous les endpoints de listing/recherche.

## Exemple
\`\`\`typescript
// ✅ NOTRE CONVENTION
@Post()
async search(@Body() dto: SearchDto) {}

// ❌ STANDARD (on ne fait pas)
@Get()
async findAll(@Query() query: QueryDto) {}
\`\`\`
```

---

*Ce fichier sert de guide. Supprimez-le une fois vos conventions documentées.*
