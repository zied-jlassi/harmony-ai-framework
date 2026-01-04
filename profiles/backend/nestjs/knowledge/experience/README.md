# Expérience Projet - Auto-Enrichi par Sentinel

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
│     └─ Bug, crash, problème en dev/prod                         │
│                                                                  │
│  2. SENTINEL DOCUMENTE                                          │
│     └─ /harmony --mode sentinel --learn                         │
│     └─ Ajoute dans error-journal.json                           │
│                                                                  │
│  3. SYNC VERS PROFILE                                           │
│     └─ Tags NestJS → Copié ici automatiquement                  │
│     └─ Devient "pitfall" documenté                              │
│                                                                  │
│  4. PRÉVENTION FUTURE                                           │
│     └─ Guardian/Sentinel vérifie avant chaque dev               │
│     └─ Alerte si pattern similaire détecté                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Fichiers Auto-Générés

| Fichier | Source | Description |
|---------|--------|-------------|
| `pitfalls.md` | error-journal.json | Erreurs avec tag "nestjs" |
| `solutions.md` | learned-patterns.json | Solutions validées |
| `anti-patterns.md` | anti-patterns.json | Ce qu'il ne faut plus faire |

---

## Exemple d'Entrée Auto-Générée

```markdown
## ERR-042: JWT Secret Hardcodé

**Date**: 2026-01-02
**Sévérité**: CRITICAL
**Module**: auth

### Symptôme
Token JWT rejeté en production mais fonctionne en dev.

### Cause Racine
Secret JWT hardcodé dans le code, différent de la variable d'environnement prod.

### Solution
Toujours utiliser ConfigService pour les secrets.

\`\`\`typescript
// ❌ CAUSAIT LE BUG
secret: 'my-hardcoded-secret'

// ✅ SOLUTION
secret: this.configService.get('JWT_SECRET')
\`\`\`

### Règle de Prévention
JAMAIS de secret en dur. Toujours ConfigService + validation Joi au démarrage.
```

---

## Commandes Sentinel

```bash
# Documenter une erreur manuellement
/harmony --mode sentinel --learn

# Voir les erreurs NestJS
/harmony --mode sentinel --report --tags nestjs

# Sync vers ce dossier
/harmony --mode sentinel --sync-profile nestjs
```

---

*Ce dossier se remplit automatiquement. Ne modifiez pas manuellement.*
