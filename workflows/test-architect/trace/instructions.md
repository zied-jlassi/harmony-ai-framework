# Workflow : Matrice de Traçabilité (Trace)

> **But** — Construire la matrice de traçabilité **bidirectionnelle** entre les exigences (stories, AC, NFR) et les tests qui les valident. Détecter les lacunes de couverture (une cellule vide = un maillon manquant) et **bloquer le CI** (quality gate) si le seuil minimum n'est pas atteint. La matrice est régénérée à chaque exécution plutôt que maintenue à la main (*living traceability*).

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Collecter les exigences

Charger les exigences selon `{scope}` :
- **`scope = story-id`** : `{sprint_artifacts}/{scope}*.md` → critères d'acceptation + NFR
- **`scope = full`** : tous les epics/stories de `{sprint_artifacts}/` + `sprint-status.yaml` + PRD

Normaliser chaque exigence en identifiant traçable :
```
{type}-{epic}-{story}-{seq}
  CA-1-2-01   → Critère d'acceptation, Epic 1, Story 2, n°1
  NFR-PERF-01 → NFR Performance n°1
```
Créer l'inventaire avec description courte. Idéal : exigences taguées **à la source** (requirements-as-code) pour fiabiliser la traçabilité.

## 2. Inventorier les tests existants

Scanner les fichiers de test : `**/*.test.ts|*.spec.ts` (JS/TS), `test_*.py|*_test.py` (Python), `*_test.go`, `*Test.java`, modules `#[cfg(test)]` (Rust). Pour chaque test, extraire : identifiant (chemin + describe/it), **références explicites** aux exigences, type (unit/integration/contract/e2e/nfr/acceptance).

```
// @requirement CA-1-2-01
# Covers: NFR-PERF-01
* Story: STORY-042
```

Si aucun tag explicite → correspondance **sémantique** comme approximation, marquée « déduit » vs « explicite ». L'IA peut **proposer** les tags manquants à partir des titres/AC ; **revue humaine** avant de les considérer fiables. Viser une traçabilité majoritairement explicite (le déduit est un signal de dette).

## 3. Construire la matrice bidirectionnelle

Vue **Exigences → Tests** (couverture) :
```
| Exigence ID | Description     | Tests couvrants                    | Statut        |
|-------------|-----------------|------------------------------------|---------------|
| CA-1-2-01   | Login email/mdp | auth.test.ts#L45, login.e2e.ts#L12 | ✅ Couvert     |
| CA-1-3-01   | Reset mdp       | ❌ AUCUN                            | 🔴 Non couvert |
| NFR-PERF-01 | API p95 < 200ms | perf.k6.js                         | ✅ Couvert     |
```

Vue **Tests → Exigences** (justification, détecte les orphelins) :
```
| Fichier       | Test                  | Exigences couvertes          |
|---------------|-----------------------|------------------------------|
| auth.test.ts  | should login…         | CA-1-2-01                    |
| utils.test.ts | should format date    | ⚠️ orphelin (aucune exigence) |
```

Métriques : total exigences, couvertes (%), non couvertes (%), tests orphelins, part **explicite** vs **déduite**.

## 4. Identifier lacunes et risques

Classer les exigences non couvertes par risque :
- **Critique (bloquer le déploiement)** : sécurité (OWASP, authz), réglementaire (RGPD, accessibilité légale), cœur de métier critique
- **Important (avant release)** : AC des stories en cours, NFR de perf sur chemins critiques
- **Mineur (backlog)** : features secondaires, NFR cosmétiques

Trier les tests orphelins : obsolètes (feature supprimée), doublons, régressions non documentées (à rattacher à une exigence).

## 5. Générer la matrice et intégrer au CI (quality gate)

Écrire la matrice dans `{output_matrix}` ou `docs/test-traceability.md` (template `trace-template.md`) + un rapport JSON machine-readable :
```json
{
  "generated": "{date}", "project": "{project_name}",
  "metrics": { "total_requirements": 42, "covered": 35, "coverage_pct": 83.3,
               "explicit_pct": 71.4, "threshold": 80, "status": "PASS", "orphaned_tests": 3 },
  "uncovered": [ { "id": "CA-1-3-01", "risk": "critical", "description": "Reset password" } ]
}
```

Si `{coverage_threshold}` non atteint → **échouer le quality gate** :
```
❌ QUALITY GATE FAILED — Traçabilité {coverage_pct}% < seuil {coverage_threshold}%
Exigences non couvertes :
  - CA-1-3-01 [CRITIQUE] : Reset password
  - CA-2-1-05 [IMPORTANT] : Gestion des erreurs paiement
Action : créer les tests manquants avant de merger.
```

Proposer à `{user_name}` les prochains tests à créer (ordre par risque). La matrice étant régénérée en CI, elle reste synchronisée par construction.
