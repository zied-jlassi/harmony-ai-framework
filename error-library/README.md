# Error Library

> Bibliothèque mondiale d'erreurs/solutions - AutoLearning collectif

## Mécanisme et Workflow

### Principe: Apprendre par l'Erreur

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE D'AUTOLEARNING                         │
│                                                                 │
│   1. ERREUR       2. ANALYSE        3. DOCUMENT      4. PARTAGE │
│   ─────────       ──────────        ──────────       ────────── │
│   Bug rencontré → Cause root    →   JSON structuré → MCP Memory │
│   pendant dev      identifiée       versionné        + fichiers │
│                                                                 │
│   5. PROTECTION                                                 │
│   ─────────────                                                 │
│   Prochaine session → Claude cherche → Solution trouvée → ÉVITÉ │
└─────────────────────────────────────────────────────────────────┘
```

### Workflow de Synchronisation MCP

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Fichiers JSON   │     │    Sync Tool     │     │   MCP Memory     │
│  (error-library) │ ──▶ │  (sync-mcp.sh)   │ ──▶ │   (persistent)   │
└──────────────────┘     └──────────────────┘     └──────────────────┘
        │                         │                        │
        │ Source of truth         │ Génère JSON           │ Stockage
        │ Versionné               │ pour Claude           │ cross-session
        │ Contributable           │                       │
        └─────────────────────────┴────────────────────────┘

Étapes:
1. mcp__memory__search_nodes("Error_BASH") → Vérifie existence
2. Si absent → mcp__memory__create_entities avec toutes les erreurs
3. Si présent → Compare VERSION, met à jour si fichier plus récent
4. Relations créées vers BashPatterns, JsPatterns, etc.
```

### Chargement On-Demand

Le chargement se fait **uniquement quand nécessaire** (pas à chaque session):

| Déclencheur | Action |
|-------------|--------|
| Erreur détectée | `suggest_solution "error message"` |
| Avant développement | Charger patterns de la catégorie |
| Nouvelle session + MCP | Sync si version différente |

## Quick Index

| ID | Erreur | Sévérité |
|----|--------|----------|
| [BASH-001](errors/bash/BASH-001.json) | `((VAR++))` crash avec set -e | critical |
| [BASH-002](errors/bash/BASH-002.json) | `[0-9]{4}` regex non supporté | critical |
| [BASH-003](errors/bash/BASH-003.json) | Exit code perdu avec set -e | critical |
| [BASH-004](errors/bash/BASH-004.json) | Fonction attend fichier pas string | medium |
| [BASH-005](errors/bash/BASH-005.json) | Fonction retourne exit code pas string | medium |

## Usage Rapide

```bash
# Charger le loader
source framework/lib/error-library-loader.sh

# Lister toutes les erreurs
list_errors

# Chercher une erreur
search_errors "set -e"

# Voir solution
get_error_solution "BASH-001"

# Stats
error_library_stats
```

## Sync MCP Memory

```bash
# Générer JSON pour MCP
bash framework/error-library/tools/sync-mcp.sh

# Claude peut ensuite appeler:
# mcp__memory__create_entities(...)
```

Voir [SYNC-PROCEDURE.md](SYNC-PROCEDURE.md) pour la procédure complète.

## Contribuer

1. Créer `errors/<category>/<CAT>-XXX.json`
2. Suivre le schema: `schema/error.schema.json`
3. Mettre à jour `errors/<category>/index.json`
4. PR

### Format

```json
{
  "id": "BASH-006",
  "title": "Description courte",
  "category": "bash",
  "severity": "critical|high|medium|low",
  "version": "1.0.0",
  "error": "Ce qui se passe",
  "cause": "Pourquoi",
  "solution": "Comment corriger",
  "example_bad": "Code erroné",
  "example_good": "Code correct",
  "tags": ["tag1", "tag2"],
  "discovered": "2026-01-05",
  "source": "Où découvert"
}
```

## Structure

```
error-library/
├── index.json           # Index principal
├── README.md            # Ce fichier
├── SYNC-PROCEDURE.md    # Procédure MCP
├── schema/
│   └── error.schema.json
├── errors/
│   ├── bash/            # 5 erreurs
│   ├── javascript/      # À venir
│   ├── typescript/      # À venir
│   └── python/          # À venir
└── tools/
    └── sync-mcp.sh
```

## Stats

- **Version**: 1.0.0
- **Erreurs**: 5
- **Catégories**: 1 (bash)
- **Dernière MAJ**: 2026-01-05

---

> *"Chaque erreur documentée est une erreur évitée pour tous."*
