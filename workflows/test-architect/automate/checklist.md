# Checklist : Automatisation des Tests

## Prérequis
- [ ] Framework de test installé et configuré
- [ ] Outil de couverture configuré (v8/Istanbul/coverage.py/tarpaulin/JaCoCo)
- [ ] Tests existants passent (pas de tests en échec non liés au scope)

## Analyse de la couverture
- [ ] Commande de couverture exécutée avec succès ; line%, branch%, function% parsés
- [ ] Seuil cible identifié ({coverage_threshold}%)
- [ ] Fichiers sous le seuil et fichiers à 0% listés

## Priorisation par le risque (pas par le %)
- [ ] Fichiers récemment modifiés (git blame) traités en premier
- [ ] Logique métier critique identifiée (service, handler, use-case)
- [ ] Complexité cyclomatique évaluée ; API publique couverte en priorité
- [ ] Max 5 fichiers par exécution (focalisation)

## Génération des tests
- [ ] Un fichier de test par fichier source cible (même arborescence, suffixe correct)
- [ ] ≥ 2 cas par fonction (happy path + erreur) ; chaque branche couverte ; boundary values
- [ ] Dépendances externes mockées **sans over-mocking** (l'unité testée n'est pas mockée)
- [ ] Génération assistée par IA passée en **revue humaine** (assertions réelles, oracle correct, cas rares)
- [ ] Assertions spécifiques (pas `toBeTruthy()`/`toBeDefined()`), sur le comportement observable

## Qualité & stabilité
- [ ] Pas de `console.log`, pas de `sleep()`/délais arbitraires ; tests isolés
- [ ] Tous les tests générés compilent et **passent** au premier run
- [ ] Tests instables (flaky) détectés (3 exécutions), **mis en quarantaine** + ticket cause-racine (pas de retry masquant)

## Mesure d'amélioration
- [ ] Couverture relancée ; amélioration documentée (avant → après, delta %)
- [ ] Seuil {coverage_threshold}% atteint ou plan documenté ; flaky en quarantaine reportés
- [ ] Résultat mis à jour dans `.harmony/memory/working.json`

## Critères de sortie
- [ ] Tous les nouveaux tests passent ; aucune régression
- [ ] Couverture globale ≥ {coverage_threshold}% (ou plan documenté)
