# Expérience Projet React - Auto-Enrichi par Sentinel

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
│     └─ Bug React, erreur hooks, problème render                 │
│                                                                  │
│  2. SENTINEL DOCUMENTE                                          │
│     └─ /harmony --mode sentinel --learn                         │
│     └─ Ajoute dans error-journal.json                           │
│                                                                  │
│  3. SYNC VERS PROFILE                                           │
│     └─ Tags React → Copié ici automatiquement                   │
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

- `react`
- `javascript`
- `typescript`
- `frontend`
- `hooks`
- `jsx`
- `state`
- `nextjs`

---

## Exemple d'Entrée Auto-Générée

```markdown
## ERR-091: Infinite Loop avec useEffect

**Date**: 2026-01-03
**Sévérité**: HIGH
**Module**: dashboard

### Symptôme
Page freeze, navigateur ne répond plus, console remplie de logs.

### Cause Racine
useEffect sans dependency array ou avec objet/array recréé à chaque render.

### Solution
Toujours spécifier les dépendances correctement.

\`\`\`jsx
// ❌ CAUSAIT LE BUG
useEffect(() => {
  fetchData(options);  // options = {} créé chaque render
}, [options]);  // Nouvelle référence → re-run → boucle infinie

// ✅ SOLUTION 1: useMemo pour stabiliser la référence
const options = useMemo(() => ({ page, limit }), [page, limit]);
useEffect(() => {
  fetchData(options);
}, [options]);

// ✅ SOLUTION 2: Dépendre des primitives
useEffect(() => {
  fetchData({ page, limit });
}, [page, limit]);

// ✅ SOLUTION 3: Déplacer l'objet dans useEffect
useEffect(() => {
  const options = { page, limit };
  fetchData(options);
}, [page, limit]);
\`\`\`

### Règle de Prévention
- Toujours lister les dépendances primitives
- Utiliser useMemo pour les objets/arrays en dépendances
- Utiliser ESLint react-hooks/exhaustive-deps
```

---

## Commandes Sentinel

```bash
# Documenter une erreur manuellement
/harmony --mode sentinel --learn

# Voir les erreurs React
/harmony --mode sentinel --report --tags react

# Sync vers ce dossier
/harmony --mode sentinel --sync-profile react
```

---

*Ce dossier se remplit automatiquement. Ne modifiez pas manuellement.*
