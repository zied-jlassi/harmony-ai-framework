# Rapport de Revue des Tests — {projet}

**Date** : {date}
**Scope** : {all | unit | integration | e2e | chemin}
**Auteur** : {user_name}
**Version analysée** : {git-hash ou version}

---

## Score qualité global : {score}/10

| Dimension | Score | Poids |
|-----------|-------|-------|
| Distribution pyramide | {n}/10 | 20% |
| Qualité des assertions | {n}/10 | 25% |
| Absence d'anti-patterns | {n}/10 | 30% |
| Couverture significative | {n}/10 | 25% |

---

## 1. Distribution des tests (pyramide)

**Actuelle :**
```
E2E          {pct}% — {n} tests
Integration  {pct}% — {n} tests
Unit         {pct}% — {n} tests
Total        {total} tests
```

**Cible recommandée :**
```
E2E          10% (~{n} tests)
Integration  20% (~{n} tests)
Unit         70% (~{n} tests)
```

**Statut** : ✅ Pyramide équilibrée / ⚠️ Déséquilibre / ❌ Ice cream cone

---

## 2. Anti-patterns détectés

### ❌ Critique — À corriger avant merge

| Anti-pattern | Fichier | Ligne | Description |
|-------------|---------|-------|-------------|
| Tests sans assertions | `{fichier}` | L{n} | `it('should...', () => {})` vide |
| Appel réseau réel | `{fichier}` | L{n} | `fetch()` sans msw/nock |

### ⚠️ Important — À corriger ce sprint

| Anti-pattern | Fichier | Ligne | Description |
|-------------|---------|-------|-------------|
| Test flaky (Date.now) | `{fichier}` | L{n} | Pas de vi.useFakeTimers() |
| Test couplé | `{fichier}` | L{n} | État partagé sans reset |

### ℹ️ Mineur — Amélioration recommandée

| Anti-pattern | Fichier | Description |
|-------------|---------|-------------|
| Assertion trop permissive | `{fichier}` | `toBeTruthy()` → préférer `toEqual(...)` |
| Test trop long | `{fichier}` | Test unitaire > 200ms |

---

## 3. Tests morts (désactivés)

| Fichier | Test désactivé | Désactivé depuis | Action |
|---------|---------------|-----------------|--------|
| `{fichier}` | `{test.skip(...)}` | {date git blame} | Supprimer ou réactiver |

---

## 4. Tests potentiellement flaky

| Fichier | Test | Cause potentielle | Correction |
|---------|------|------------------|------------|
| `{fichier}` | `{test name}` | Date non mockée | `vi.useFakeTimers()` |
| `{fichier}` | `{test name}` | Timeout arbitraire | Remplacer par `waitFor()` |

---

## 5. Couverture — analyse qualitative

**Métriques :**
```
Line coverage     : {pct}%  (seuil : 80%)  {✅|❌}
Branch coverage   : {pct}%  (seuil : 80%)  {✅|❌}
Function coverage : {pct}%  (seuil : 80%)  {✅|❌}
```

**Zones à risque non couvertes malgré un bon % :**
- {fichier} : gestion des erreurs réseau non testée
- {fichier} : logic de retry non couverte
- {fichier} : edge cases des données nulles

---

## 6. Plan d'action

### P1 — Critique (avant merge)
| Action | Fichier | Effort | Assigné |
|--------|---------|--------|---------|
| {action} | {fichier} | {XS|S|M|L} | {user} |

### P2 — Important (sprint courant)
| Action | Fichier | Effort |
|--------|---------|--------|
| {action} | {fichier} | {effort} |

### P3 — Amélioration (backlog)
| Action | Description | Effort |
|--------|-------------|--------|
| Rééquilibrer pyramide | Convertir {n} E2E en tests unitaires | {L} |

---

*Rapport généré par Harmony Framework — workflow test-architect-test-review*
