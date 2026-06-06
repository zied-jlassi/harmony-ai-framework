# Checklist : Conception des Tests (Test Design)

## Prérequis
- [ ] Exigences chargées (story, PRD, spécifications)
- [ ] Contexte métier compris (type de système, utilisateurs cibles)
- [ ] Risques identifiés (données sensibles, transactions critiques, intégrations)

## Analyse des exigences
- [ ] Toutes les fonctionnalités listées et priorisées par risque
- [ ] Exigences fonctionnelles extraites et numérotées
- [ ] NFR identifiées (performance, sécurité, accessibilité, fiabilité)
- [ ] Intégrations tierces listées (paiement, email, API externe...)
- [ ] Zones de risque technique identifiées (concurrence, données utilisateur...)

## Techniques de conception appliquées
- [ ] Partitionnement en classes d'équivalence appliqué sur les inputs
- [ ] Analyse des valeurs limites (boundary values) pour les fonctions numériques
- [ ] Tables de décision créées pour les logiques multi-conditions
- [ ] Diagrammes de transition d'état modélisés si applicable
- [ ] Tests de propriétés identifiés pour les fonctions pures complexes
- [ ] Tests de contrat (Pact) identifiés pour les interfaces entre services

## Catalogue des cas de test
- [ ] Au moins 1 cas de test par critère d'acceptation
- [ ] Cas nominaux (happy path) documentés
- [ ] Cas d'erreur documentés (input invalide, état incorrect, service indisponible)
- [ ] Cas limites documentés pour les fonctionnalités critiques
- [ ] Cas négatifs documentés (accès non autorisé, données manquantes)
- [ ] Chaque cas de test a : ID unique, préconditions, données, étapes, résultat attendu

## Distribution pyramide
- [ ] Distribution cible définie : ≈ 70% unit / 20% integration / 10% E2E
- [ ] Tests unitaires listés pour les fonctions pures et logique métier
- [ ] Tests d'intégration listés pour les services et l'accès aux données
- [ ] Tests E2E listés pour les flux utilisateur critiques

## Matrice de couverture
- [ ] Matrice exigences → cas de test créée
- [ ] Toutes les exigences ont au moins 1 cas de test
- [ ] Exigences critiques ont ≥ 2 cas de test (nominal + erreur)
- [ ] Taux de couverture des exigences calculé

## Document de plan de test
- [ ] Document `docs/test-design-{id}.md` créé
- [ ] Résumé exécutif rédigé
- [ ] Stratégie documentée (outils, seuils, critères de sortie)
- [ ] Catalogue des cas de test complet
- [ ] Estimation du temps d'implémentation incluse

## Critères de sortie
- [ ] 100% des exigences couvertes par au moins un cas de test
- [ ] Document de plan de test validé avec {user_name}
- [ ] Prêt pour l'implémentation (workflow automate ou ATDD)
