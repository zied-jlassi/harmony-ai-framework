# Matrice de Traçabilité — {projet}

**Date** : {date}
**Scope** : {full | story-id}
**Auteur** : {user_name}
**Version** : {git-hash}

---

## Métriques de couverture

| Métrique | Valeur | Seuil | Statut |
|----------|--------|-------|--------|
| Exigences totales | {total} | — | — |
| Exigences couvertes | {covered} | — | — |
| **Taux de couverture** | **{pct}%** | **≥ {threshold}%** | **✅/❌** |
| Couverture explicite (tags) | {pct}% | — | — |
| Couverture déduite (sémantique) | {pct}% | — | — |
| Tests orphelins | {n} | 0 recommandé | ⚠️ |

**QUALITY GATE** : {✅ PASS | ❌ FAIL — {pct}% < seuil {threshold}%}

---

## Vue 1 : Exigences → Tests

| ID Exigence | Type | Description | Tests couvrants | Statut |
|-------------|------|-------------|-----------------|--------|
| CA-1-2-01 | AC | {description} | `auth.test.ts#L45`, `login.e2e.ts#L12` | ✅ Couvert |
| CA-1-2-02 | AC | {description} | `auth.test.ts#L78` | ✅ Couvert |
| CA-1-3-01 | AC | {description} | — | 🔴 NON COUVERT |
| NFR-PERF-01 | NFR | p95 < 200ms | `perf.k6.js` | ✅ Couvert |
| NFR-SEC-01 | NFR | OWASP Top 10 | `security.test.ts` | ✅ Couvert |
| CA-2-1-05 | AC | {description} | — | 🟡 DÉDUIT (partiel) |

---

## Vue 2 : Tests → Exigences

| Fichier de test | Nom du test | Exigences couvertes | Type couverture |
|-----------------|-------------|--------------------|--------------:|
| `tests/unit/auth.test.ts` | should login with valid credentials | CA-1-2-01 | Explicite |
| `tests/unit/auth.test.ts` | should logout and clear session | CA-1-2-02 | Explicite |
| `tests/e2e/checkout.e2e.ts` | complete purchase flow | CA-3-1-01, CA-3-1-02 | Explicite |
| `tests/unit/utils.test.ts` | should format date correctly | ⚠️ Aucune exigence | Orphelin |
| `tests/integration/payment.test.ts` | should process payment | CA-3-2-01 | Déduit |

---

## Exigences non couvertes

### 🔴 Critiques (bloquer le déploiement)

| ID | Description | Risque | Tests recommandés |
|----|-------------|--------|-------------------|
| {CA-n} | {description} | Sécurité / Auth | `tests/unit/{service}.test.ts` |
| {NFR-n} | {description} | Performance critique | `tests/perf/{endpoint}.k6.js` |

### 🟡 Importantes (corriger avant release)

| ID | Description | Risque | Tests recommandés |
|----|-------------|--------|-------------------|
| {CA-n} | {description} | Fonctionnel majeur | `tests/integration/{feature}.test.ts` |

### ⚪ Mineures (backlog)

| ID | Description | Tests recommandés |
|----|-------------|-------------------|
| {CA-n} | {description} | `tests/unit/{helper}.test.ts` |

---

## Tests orphelins à analyser

| Fichier | Test | Statut recommandé |
|---------|------|-------------------|
| `{fichier}` | `{test name}` | Supprimer (feature supprimée) |
| `{fichier}` | `{test name}` | Documenter l'exigence correspondante |

---

## Intégration CI

```yaml
# Quality gate — échoue si couverture < seuil
# Voir .github/workflows/tests.yml ou .gitlab-ci.yml
coverage_check:
  threshold: {threshold}%
  current: {pct}%
  status: {PASS | FAIL}
```

---

*Matrice générée par Harmony Framework — workflow test-architect-trace*
