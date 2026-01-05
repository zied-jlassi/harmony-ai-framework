# Expérience Projet Symfony - Auto-Enrichi par Sentinel

> Ce dossier est **automatiquement enrichi** par Harmony Sentinel.
> Chaque erreur documentée devient une leçon apprise.

---

## Comment ça Fonctionne

```
┌─────────────────────────────────────────────────────────────────┐
│                    CYCLE D'APPRENTISSAGE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. ERREUR RENCONTRÉE                                           │
│     └─ Bug Symfony, erreur Doctrine, problème config            │
│                                                                  │
│  2. SENTINEL DOCUMENTE                                          │
│     └─ /harmony --mode sentinel --learn                         │
│     └─ Ajoute dans error-journal.json                           │
│                                                                  │
│  3. SYNC VERS PROFILE                                           │
│     └─ Tags Symfony → Copié ici automatiquement                 │
│     └─ Devient "pitfall" documenté                              │
│                                                                  │
│  4. PRÉVENTION FUTURE                                           │
│     └─ Guardian/Sentinel vérifie avant chaque dev               │
│     └─ Alerte si pattern similaire détecté                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tags Surveillés

- `symfony`
- `php`
- `doctrine`
- `twig`
- `api`
- `security`
- `forms`
- `validation`

---

## Exemple d'Entrée Auto-Générée

```markdown
## ERR-055: Cache Doctrine non vidé après migration

**Date**: 2026-01-02
**Sévérité**: MEDIUM
**Module**: doctrine

### Symptôme
Entité non trouvée après ajout d'une nouvelle propriété.
Erreur: "Unknown column 'new_field'"

### Cause Racine
Le cache Doctrine (proxy classes) n'était pas régénéré après la migration.

### Solution
Toujours vider le cache après une migration.

\`\`\`bash
# ❌ CAUSAIT LE BUG
php bin/console doctrine:migrations:migrate

# ✅ SOLUTION
php bin/console doctrine:migrations:migrate
php bin/console cache:clear
php bin/console doctrine:cache:clear-metadata
\`\`\`

### Règle de Prévention
Ajouter au Makefile ou script de déploiement:
\`\`\`makefile
migrate:
    php bin/console doctrine:migrations:migrate --no-interaction
    php bin/console cache:clear
\`\`\`
```

---

## Commandes Sentinel

```bash
# Documenter une erreur manuellement
/harmony --mode sentinel --learn

# Voir les erreurs Symfony
/harmony --mode sentinel --report --tags symfony

# Sync vers ce dossier
/harmony --mode sentinel --sync-profile symfony
```

---

*Ce dossier se remplit automatiquement. Ne modifiez pas manuellement.*
