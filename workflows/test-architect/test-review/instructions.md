# Workflow : Revue Qualité des Tests (Test Review)

> **But** — Auditer la qualité des tests existants : détection des *test smells*, mesure de l'**adéquation réelle** (au-delà du % de couverture, via le mutation testing) et recommandations actionnables. Principe : un test qui ne peut pas échouer ne vaut rien.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Scanner et inventorier les tests

Localiser les tests selon `{scope}` (all / unit / integration / e2e). Métriques de base : nombre de fichiers/cas de test, ratio test/code, distribution unit/integration/E2E, date de dernière modification.

## 2. Détecter les test smells (noms canoniques)

- **Ice Cream Cone** (pyramide inversée) : plus d'E2E que d'unitaires (E2E > 30% du total) → feedback lent.
- **Assertion Roulette** : multiples assertions sans message → cause d'échec impossible à isoler.
- **Eager Test / God Test** : un test couvrant trop (≥ 10 assertions) → maintenance difficile.
- **Mystery Guest** : dépendance à une ressource externe non visible (fichier, DB partagée) → fragile.
- **Tests sans assertion** : `it(...)` sans `expect()` → fausse couverture.
- **Couplage/ordre-dépendance** : état global partagé, `beforeAll` sans cleanup → résultats aléatoires.
- **Over-mocking** : plus de mocks que d'assertions, on mocke l'unité testée → teste l'implémentation, pas le comportement.
- **Flaky** : `Date.now()`/`Math.random()` sans mock, `setTimeout` sans fake timers, réseau réel sans msw/nock, `sleep()` arbitraire en E2E.
- **Tests lents** : unit > 100ms, integration > 2s, E2E > 30s.
- **Dead tests** : `skip`/`xit`/`@pytest.mark.skip` depuis > 30 jours (git blame).

## 3. Évaluer la qualité des assertions

Sur un échantillon représentatif :
- ✅ teste le **comportement observable** ; matchers spécifiques (`toEqual`, `toMatchObject`, `toContain`, `toBeCloseTo`) ; une responsabilité par test.
- ⚠️ à risque : `toBeTruthy()`/`toBeDefined()` (trop permissifs — passent avec 0/""/false), `not.toThrow()` sans vérifier le retour, `toHaveBeenCalled()` sans vérifier les arguments.
- ❌ aucune assertion.

Couverture des cas d'erreur : ratio nominal/erreur (idéal ~60/40), edge cases (null, undefined, vide, min/max, types incorrects).

## 4. Mesurer l'adéquation réelle (mutation testing)

La couverture de ligne **ne prouve pas** que les tests détectent les bugs. Mesurer l'adéquation par **mutation testing** :
- Outils : **Stryker** (JS/TS), **mutmut**/**cosmic-ray** (Python), **PIT** (Java).
- Le mutateur injecte des défauts (inverser une condition, changer un opérateur) ; un bon test « tue » la mutation (échoue). **Mutation score** = mutants tués / total.
- Cible : **≥ 70%** sur le code critique. Les mutants *survivants* révèlent des assertions faibles ou des branches non vérifiées.

Distinguer couverture significative (branches critiques, chemins d'erreur, cas limites métier) vs cosmétique (snapshots auto-générés, getters/setters sans logique). Pointer les zones à risque non couvertes malgré un bon % : erreurs réseau, timeout/retry, concurrence, données corrompues.

## 5. Scruter les tests générés par IA (2026)

Les tests produits par un assistant IA exigent une vigilance accrue :
- **Tautologies** : test qui ré-affirme l'implémentation (mocke tout puis vérifie le mock) → ne détecte aucun bug.
- **Oracle fabriqué** : l'assertion a été ajustée pour passer plutôt que pour spécifier le comportement attendu.
- **Couverture en trompe-l'œil** : beaucoup de lignes touchées, peu d'assertions réelles (mutation score bas malgré couverture haute).
- **Cas métier rares oubliés** : l'IA couvre le happy path, rate les exigences implicites.

Règle : tout test généré par IA passe la **revue humaine** + idéalement un contrôle mutation avant d'être considéré fiable.

## 6. Produire le rapport et les recommandations

Écrire dans `{output_report}` ou `docs/test-review-{date}.md` :
```markdown
# Rapport de Revue des Tests — {date}
## Résumé : score qualité {score}/10 | smells {n} | flaky {n} | dead {n} | mutation score {pct}%
## Distribution (pyramide/trophy) : unit {pct}% / integration {pct}% / e2e {pct}%
## Test smells détectés : {fichiers, lignes, exemples}
## Adéquation (mutation testing) : mutants survivants notables
## Recommandations : P1 (avant merge) · P2 (sprint) · P3 (backlog)
## Plan d'action : étapes + effort estimé
```

Afficher à `{user_name}` les 3 actions les plus prioritaires.
