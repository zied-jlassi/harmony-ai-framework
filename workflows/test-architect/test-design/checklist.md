# Checklist : Conception des Tests (Test Design)

## Prérequis
- [ ] Exigences chargées (story, PRD, spécifications, contrats d'API)
- [ ] Contexte métier compris (type de système, utilisateurs cibles)
- [ ] Risques identifiés (données sensibles, transactions critiques, intégrations)

## Stratégie
- [ ] Forme de couverture choisie et **justifiée par le risque** : Test Pyramid (backend) ou Testing Trophy (front/full-stack)
- [ ] Distribution cible définie (ex. 70/20/10) et documentée
- [ ] Positionnement shift-left (contrat/statique/unit au plus tôt) et shift-right (canary, RUM) défini

## Analyse & risque
- [ ] Toutes les fonctionnalités listées et **scorées** (risque = probabilité × impact, 1-9)
- [ ] NFR identifiées par caractéristique ISO/IEC 25010 (perf, sécurité, fiabilité, accessibilité…)
- [ ] Intégrations tierces et zones de risque technique (concurrence, données utilisateur) identifiées
- [ ] Priorisation appliquée : les premiers cas couvrent le maximum de risque

## Techniques de conception appliquées
- [ ] Partitionnement en classes d'équivalence sur les inputs
- [ ] Analyse des valeurs limites (BVA) pour les fonctions numériques
- [ ] Tables de décision pour les logiques multi-conditions
- [ ] Transitions d'état modélisées (transitions valides ET invalides) si applicable
- [ ] Tests combinatoires (pairwise) si explosion de paramètres
- [ ] Property-based identifié pour les fonctions pures complexes
- [ ] Contract testing (Pact) identifié pour les interfaces entre services
- [ ] Seuil de mutation testing visé (≥ 70% sur le code critique)

## Catalogue des cas de test
- [ ] ≥ 1 cas de test par critère d'acceptation
- [ ] Cas nominaux, d'erreur, limites, négatifs (sécurité) documentés
- [ ] Chaque cas a : ID, exigence couverte, technique, priorité (issue du score), type, préconditions, données, étapes, oracle
- [ ] Génération assistée par IA (si utilisée) passée en **revue humaine**

## Traçabilité & couverture
- [ ] Matrice **bidirectionnelle** exigence/AC ↔ cas de test créée
- [ ] Toutes les exigences ont ≥ 1 cas ; exigences Critiques/Élevées ≥ 2 (nominal + erreur)
- [ ] Couverture NFR (caractéristiques ISO 25010 + seuils) planifiée

## Document de plan de test
- [ ] Document `docs/test-design-{id}.md` créé (résumé, stratégie, catalogue, traçabilité, couverture NFR)
- [ ] Critères de sortie définis (couverture, mutation score, NFR)
- [ ] Estimation d'effort + ordre d'implémentation (par risque) inclus

## Critères de sortie
- [ ] 100% des exigences couvertes par ≥ 1 cas de test
- [ ] Document validé avec {user_name}
- [ ] Prêt pour l'implémentation (workflow automate ou ATDD)
