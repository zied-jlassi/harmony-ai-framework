# Checklist : Revue Qualité des Tests

## Prérequis
- [ ] Tests existants localisés selon le scope défini
- [ ] Rapport de couverture disponible ou générable
- [ ] Accès aux résultats CI récents (tests flaky détectables)

## Inventaire et métriques de base
- [ ] Fichiers et cas de test comptés ; distribution unit / integration / E2E
- [ ] Ratio tests/code évalué ; couverture line/branch/function mesurée

## Détection des test smells (noms canoniques)
- [ ] **Ice Cream Cone** : E2E < 30% du total (sinon rééquilibrage documenté)
- [ ] **Assertion Roulette** : multiples assertions sans message → à corriger
- [ ] **Eager/God Test** : aucun test avec ≥ 10 assertions
- [ ] **Mystery Guest** : pas de dépendance externe cachée (fichier, DB partagée)
- [ ] **Tests sans assertion** : chaque test a ≥ 1 `expect()`/`assert`
- [ ] **Couplage/ordre** : pas d'état global partagé sans reset ; `beforeEach`/cleanup présents
- [ ] **Over-mocking** : l'unité testée n'est pas mockée ; assertion sur le résultat (pas que `toHaveBeenCalled`)
- [ ] **Flaky** : pas de `Date.now()`/`Math.random()`/`setTimeout` réels sans mock ; pas de réseau réel sans msw/nock ; pas de `sleep()`
- [ ] **Tests lents** : unit ≤ 100ms, integration ≤ 2s, E2E ≤ 30s
- [ ] **Dead tests** : pas de `.skip`/`xit` depuis > 30 jours ; pas de tests commentés

## Qualité des assertions
- [ ] Matchers spécifiques (`toEqual`, `toMatchObject`, `toContain`, `toBeCloseTo`)
- [ ] Évitement de `toBeTruthy()`/`toBeDefined()` quand plus précis possible
- [ ] Assertions sur les arguments des mocks ; cas d'erreur vérifient type ET message

## Adéquation réelle (mutation testing)
- [ ] Mutation testing exécuté (Stryker / mutmut / PIT) sur le code critique
- [ ] **Mutation score ≥ 70%** ; mutants survivants notables analysés (assertions faibles, branches non vérifiées)
- [ ] Couverture significative vs cosmétique distinguée (snapshots, getters/setters sans logique)

## Scrutiny des tests générés par IA
- [ ] Tautologies détectées (test qui ré-affirme l'implémentation, mock vérifiant le mock)
- [ ] Oracle non « fabriqué pour passer » ; couverture en trompe-l'œil identifiée (mutation score bas)
- [ ] Cas métier rares vérifiés ; tout test IA passé en revue humaine

## Rapport produit
- [ ] Rapport dans `docs/test-review-{date}.md` : smells (fichiers/lignes), mutation score, recommandations P1/P2/P3
- [ ] Plan d'action avec effort estimé

## Critères de sortie
- [ ] Aucun smell critique (P1) non documenté ; score qualité calculé
- [ ] 3 actions prioritaires présentées à {user_name}
