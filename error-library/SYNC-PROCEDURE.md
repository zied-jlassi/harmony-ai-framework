# Error Library - MCP Memory Sync Procedure

## Pour Claude: Procédure de synchronisation

Quand tu travailles sur un projet avec MCP Memory disponible, utilise cette procédure pour charger la bibliothèque d'erreurs.

### Étape 1: Vérifier si déjà chargé

```
Appeler: mcp__memory__search_nodes("Error_BASH")
```

Si des résultats → bibliothèque déjà chargée, passer à l'étape 3 (vérification version)
Si aucun résultat → passer à l'étape 2 (création)

### Étape 2: Charger les erreurs

Lire le fichier `framework/error-library/index.json` puis pour chaque catégorie, créer les entités:

```json
{
  "entities": [
    {
      "name": "Error_BASH-001",
      "entityType": "ErrorSolution",
      "observations": [
        "CRASH: ((VAR++)) avec set -e quand VAR=0",
        "CAUSE: ((0++)) retourne exit code 1",
        "SOLUTION: VAR=$((VAR + 1))",
        "VERSION: 1.0.0"
      ]
    },
    {
      "name": "Error_BASH-002",
      "entityType": "ErrorSolution",
      "observations": [
        "CRASH: [0-9]{4} regex ne fonctionne pas en bash",
        "CAUSE: Bash ERE ne supporte pas {n}",
        "SOLUTION: [0-9][0-9][0-9][0-9]",
        "VERSION: 1.0.0"
      ]
    }
  ]
}
```

Appeler: `mcp__memory__create_entities` avec ces données

### Étape 3: Vérifier les versions

Pour chaque erreur trouvée, comparer VERSION avec celle du fichier JSON.
Si fichier plus récent → `mcp__memory__add_observations` pour mettre à jour.

### Étape 4: Créer les relations

```json
{
  "relations": [
    {"from": "Error_BASH-001", "to": "BashPatterns", "relationType": "partOf"},
    {"from": "Error_BASH-002", "to": "BashPatterns", "relationType": "partOf"}
  ]
}
```

---

## Utilisation automatique

Quand Claude détecte une erreur bash pendant le développement:

1. Chercher dans MCP Memory: `mcp__memory__search_nodes("BASH error message keywords")`
2. Si trouvé → Afficher la solution
3. Si non trouvé → Chercher dans les fichiers JSON locaux
4. Si nouvelle erreur découverte → Proposer de l'ajouter à la bibliothèque

---

## Commandes rapides

| Action | Commande |
|--------|----------|
| Lister erreurs | `source lib/error-library-loader.sh && list_errors` |
| Chercher | `search_errors "set -e"` |
| Voir solution | `get_error_solution "BASH-001"` |
| Stats | `error_library_stats` |
| Générer MCP JSON | `bash tools/sync-mcp.sh` |

---

## Format entité MCP

```
Nom: Error_{ID}
Type: ErrorSolution
Observations:
  - "CRASH: {description courte}"
  - "CAUSE: {pourquoi ça arrive}"
  - "SOLUTION: {comment corriger}"
  - "VERSION: {semver}"
```
