# Workflow : Automatisation des Tests et Couverture

> **But** — Analyser la couverture existante et générer les tests manquants pour atteindre les seuils de qualité. Ce workflow travaille sur le code existant. La couverture est un **moyen**, pas un but : viser une couverture *significative* (branches et chemins d'erreur), pas un pourcentage cosmétique.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Scanner la codebase et détecter le stack de test

Scope d'analyse `{scope}` : `changed` (git diff depuis HEAD), `all`, ou `path/to/module`. Détecter le framework de test : `package.json` (vitest/jest/playwright/cypress), `pyproject.toml`/`pytest.ini` (pytest), `go.mod` (go test), `Cargo.toml` (cargo test). Localiser les tests existants (`*.test.ts`, `*.spec.ts`, `test_*.py`, `*_test.go`, `#[test]`, `*Test.java`).

## 2. Analyser la couverture actuelle

Lancer la couverture selon le framework :

| Framework | Commande |
|-----------|----------|
| Vitest | `vitest run --coverage` |
| Jest | `jest --coverage` |
| pytest | `pytest --cov=src --cov-report=term-missing` |
| go test | `go test ./... -cover -coverprofile=coverage.out` |
| cargo | `cargo tarpaulin --out Html` |

Extraire line/branch/function coverage, fichiers sous le seuil `{coverage_threshold}`, fichiers à 0%. Si les tests ne s'exécutent pas → signaler et stopper.

## 3. Prioriser par le risque (pas par le %)

Trier les fichiers sous-couverts par priorité décroissante :
1. Fichiers récemment modifiés (git blame) — corrélés aux défauts
2. Logique métier critique (service, repository, handler, use-case)
3. Haute complexité cyclomatique (beaucoup de branches)
4. API publique exportée
5. Utilitaires partagés

Catégoriser le test manquant : unitaire (fonctions pures), intégration (dépendances/DB/API), **contrat (Pact)** (interfaces inter-services). Max 5 fichiers par exécution (focalisation).

## 4. Générer les tests manquants (IA + revue)

Règles de génération :
1. Un fichier source → un fichier de test (même arborescence)
2. Une fonction → ≥ 2 cas (happy path + erreur)
3. Chaque branche (if/else/switch) → un cas
4. Boundary values (0, -1, max, null, undefined, "")
5. Isolation : mocker DB/HTTP/filesystem/date — mais **sans over-mocking** (ne pas mocker l'unité testée)

**Template unitaire Vitest :**
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { {FunctionName} } from '../{source}'

describe('{FunctionName}', () => {
  beforeEach(() => vi.clearAllMocks())

  it('should {behavior} when {condition}', () => {
    const result = {FunctionName}({valid_input})
    expect(result).toEqual({expected})        // matcher spécifique, pas toBeTruthy
  })

  it('should throw {ErrorType} when {invalid}', () => {
    expect(() => {FunctionName}({invalid})).toThrow({ErrorType})
  })
})
```

**Génération assistée par IA — avec garde-fous (2026)** :
- L'IA accélère l'écriture (40-60% de temps en moins observé) mais produit des tests **tautologiques/superficiels** si non contrôlée.
- **Revue humaine obligatoire** : vérifier que l'assertion teste un comportement réel (pas `expect(x).toBeDefined()`), que l'oracle est correct, que les cas métier rares sont couverts.
- Préférer des assertions sur le **comportement observable**, sélecteurs résilients (rôles ARIA/data-testid) pour limiter la fragilité.

Lancer immédiatement les tests générés ; corriger uniquement les erreurs de compilation (types/imports), jamais l'oracle pour « faire passer ».

## 5. Gérer les tests instables (flaky) et rapporter

Politique anti-flaky (jamais de simple retry masquant) :
- Détecter l'instabilité (3 exécutions : un test qui alterne = flaky).
- **Quarantaine** : isoler le test flaky du gate bloquant, ouvrir un ticket cause-racine (timing, ordre, données partagées, réseau réel).
- Corriger la cause (fake timers, msw/nock, isolation, auto-wait Playwright) — pas un `retry` qui masque.

Comparer avant/après :
```
Couverture AVANT : {before}%   APRÈS : {after}%   (+{delta}%)
Seuil : {threshold}%   Statut : {ATTEINT|EN_COURS|INSUFFISANT}
Flaky en quarantaine : {n}
```

Lister les branches encore non couvertes (priorité risque). Mettre à jour `.harmony/memory/working.json` si une story est en cours.
