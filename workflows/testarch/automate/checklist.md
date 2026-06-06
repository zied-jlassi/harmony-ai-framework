# Checklist : Automatisation des Tests

## Prérequis
- [ ] Framework de test installé et configuré
- [ ] Outil de couverture configuré (v8/Istanbul/coverage.py/tarpaulin/JaCoCo)
- [ ] Tests existants passent (pas de tests en échec non liés au scope)

## Analyse de la couverture
- [ ] Commande de couverture exécutée avec succès
- [ ] Rapport de couverture parsé : line%, branch%, function%
- [ ] Seuil cible identifié ({coverage_threshold}%)
- [ ] Fichiers sous le seuil listés et triés par priorité
- [ ] Fichiers sans aucun test identifiés (0% coverage)

## Priorisation des fichiers
- [ ] Fichiers récemment modifiés (git blame) traités en premier
- [ ] Fichiers de logique métier critiques identifiés (service, handler, use-case)
- [ ] Complexité cyclomatique évaluée pour prioriser les fichiers complexes
- [ ] Fichiers publics (API de la bibliothèque) couverts en priorité

## Génération des tests
- [ ] Fichier de test créé pour chaque fichier source cible
- [ ] Convention de nommage respectée (même chemin, suffixe `.test.ts` / `_test.py`)
- [ ] Structure Arrange / Act / Assert respectée
- [ ] Tests unitaires : toutes les dépendances externes mockées (vi.mock / pytest.mock)
- [ ] Tests d'intégration : dépendances avec comportement testé via test doubles
- [ ] Happy path couvert pour chaque fonction publique
- [ ] Cas d'erreur couverts (throw, rejet de promesse, retour null/vide)
- [ ] Boundary values testés pour les fonctions avec validation

## Qualité des tests générés
- [ ] Assertions spécifiques utilisées (pas uniquement `toBeTruthy()`)
- [ ] Pas de `console.log` dans les tests
- [ ] Pas de `sleep()` / délais arbitraires
- [ ] Tests isolés (pas de partage d'état entre tests)
- [ ] Tous les tests générés compilent sans erreur
- [ ] Tous les tests générés **passent** au premier run

## Mesure d'amélioration
- [ ] Couverture relancée après génération
- [ ] Amélioration documentée : avant → après (delta %)
- [ ] Seuil {coverage_threshold}% atteint ou plan pour l'atteindre
- [ ] Résultat mis à jour dans `.harmony/memory/working.json`

## Critères de sortie
- [ ] Tous les nouveaux tests passent
- [ ] Couverture globale ≥ {coverage_threshold}% (ou plan documenté)
- [ ] Aucune régression sur les tests existants
