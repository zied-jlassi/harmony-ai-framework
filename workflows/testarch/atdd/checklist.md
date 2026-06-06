# Checklist : ATDD — Acceptance Test Driven Development

## Prérequis
- [ ] Story chargée avec critères d'acceptation documentés
- [ ] Framework de test installé et configuré
- [ ] Environnement de test fonctionnel (les tests existants passent)

## Analyse des critères d'acceptation
- [ ] Tous les critères d'acceptation identifiés et listés
- [ ] Critères transformés en scénarios Given/When/Then
- [ ] Cas nominaux (happy path) couverts
- [ ] Cas d'erreur identifiés
- [ ] Cas limites (boundary) identifiés pour les fonctionnalités critiques
- [ ] NFR extraites et référencées (performance, sécurité, accessibilité)

## Phase RED — Tests créés et en échec
- [ ] Fichier de test d'acceptation créé dans `tests/acceptance/`
- [ ] Convention de nommage respectée : `{story-id}-{feature}.test.ts`
- [ ] Un test par critère d'acceptation minimum
- [ ] Structure Arrange / Act / Assert respectée
- [ ] Assertions spécifiques (pas de `toBeTruthy()` générique)
- [ ] Tous les tests nouvellement créés **échouent** (phase RED confirmée)
- [ ] Les tests échouent pour la bonne raison (assertion, pas erreur de syntaxe)
- [ ] Statut `atdd_status: RED` mis à jour dans la story

## Guidage de l'implémentation
- [ ] Liste des tests présentée à l'utilisateur comme guide d'implémentation
- [ ] Ordre d'implémentation recommandé (du plus simple au plus complexe)
- [ ] Dépendances techniques identifiées (services, DB, routes à créer)

## Phase GREEN — Implémentation validée
- [ ] Tous les tests d'acceptation **passent** (phase GREEN confirmée)
- [ ] Aucune régression dans les tests unitaires existants
- [ ] Couverture de code ≥ seuil configuré (défaut 80%)
- [ ] Temps d'exécution acceptable (< 30s pour les tests d'acceptation)
- [ ] Statut `atdd_status: GREEN` mis à jour dans la story

## Phase REFACTOR (optionnelle)
- [ ] Refactoring effectué sans modification des tests
- [ ] Tests passent toujours après refactoring
- [ ] Couverture maintenue ou améliorée

## Critères de sortie
- [ ] Tous les CA ont un test correspondant
- [ ] Tests en phase GREEN
- [ ] Story mise à jour avec référence aux tests
