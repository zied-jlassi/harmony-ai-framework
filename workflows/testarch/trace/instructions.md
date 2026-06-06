# Workflow : Matrice de Traçabilité (Trace)

<critical>Ce workflow construit la matrice de traçabilité bidirectionnelle entre les exigences (stories, AC, NFR) et les tests qui les valident. Il identifie les lacunes de couverture et peut bloquer le CI si le seuil minimum n'est pas atteint.</critical>

<workflow>

<step n="1" goal="Collecter les exigences">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Charger les sources d'exigences selon le scope `{scope}` :</action>

**Si `scope = story-id` :**
- Charger `{sprint_artifacts}/{scope}*.md`
- Extraire les critères d'acceptation (section `## Acceptance Criteria`)
- Extraire les NFR mentionnées

**Si `scope = full` :**
- Charger tous les fichiers d'epics et stories dans `{sprint_artifacts}/`
- Lire `{sprint_artifacts}/sprint-status.yaml` pour la liste complète
- Inclure le PRD/spécifications si disponibles

<action>Normaliser chaque exigence en identifiant traçable :</action>
```
Format ID : {type}-{epic}-{story}-{seq}
Exemples  :
  CA-1-2-01  → Critère d'acceptation, Epic 1, Story 2, n°1
  NFR-PERF-01 → NFR Performance n°1
  CA-3-5-02  → Critère d'acceptation, Epic 3, Story 5, n°2
```

<action>Créer l'inventaire des exigences avec leur description courte</action>
</step>

<step n="2" goal="Inventorier les tests existants">
<action>Scanner tous les fichiers de test selon les patterns reconnus :</action>
```
TypeScript/JavaScript : **/*.test.ts, **/*.spec.ts, **/*.test.js
Python               : **/test_*.py, **/*_test.py
Go                   : **/*_test.go
Rust                 : modules avec #[cfg(test)]
Java                 : **/*Test.java, **/*Spec.java
```

<action>Pour chaque test, extraire :</action>
- **Identifiant** : chemin du fichier + nom du describe/it
- **Références** explicites aux exigences (patterns à détecter) :
  ```
  // @requirement CA-1-2-01
  # Covers: NFR-PERF-01
  * Story: STORY-042
  // Test for AC: L'utilisateur peut se connecter
  ```
- **Mots-clés** : correspondances sémantiques avec les titres des AC (si aucun tag explicite)
- **Type** : unit | integration | e2e | nfr | acceptance

<action>Si des tags `@requirement` ou `@covers` ne sont pas présents → utiliser la correspondance sémantique comme approximation (indiquer comme "déduit" vs "explicite" dans la matrice)</action>
</step>

<step n="3" goal="Construire la matrice de traçabilité">
<action>Créer la matrice bidirectionnelle :</action>

**Vue Exigences → Tests (couverture) :**
```
| Exigence ID | Description | Tests couvrants | Statut |
|-------------|-------------|-----------------|--------|
| CA-1-2-01   | Login email/mdp | auth.test.ts#L45, login.e2e.ts#L12 | ✅ Couvert |
| CA-1-2-02   | Logout | auth.test.ts#L78 | ✅ Couvert |
| CA-1-3-01   | Reset mdp | ❌ AUCUN | 🔴 Non couvert |
| NFR-PERF-01 | API p95 < 200ms | perf.k6.js | ✅ Couvert |
```

**Vue Tests → Exigences (justification) :**
```
| Fichier de test | Test name | Exigences couvertes |
|-----------------|-----------|---------------------|
| auth.test.ts    | should login with valid credentials | CA-1-2-01 |
| auth.test.ts    | should logout and clear session | CA-1-2-02 |
| utils.test.ts   | should format date | ⚠️ Aucune exigence (test orphelin) |
```

<action>Calculer les métriques de traçabilité :</action>
```
Total exigences          : {total}
Exigences couvertes      : {covered} ({pct}%)
Exigences non couvertes  : {uncovered} ({pct}%)
Tests orphelins          : {orphaned} (tests sans exigence associée)
Couverture explicite     : {explicit_pct}% (via tags @requirement)
Couverture déduite       : {inferred_pct}% (via correspondance sémantique)
```
</step>

<step n="4" goal="Identifier les lacunes et risques">
<action>Classer les exigences non couvertes par niveau de risque :</action>

**Critique (bloquer le déploiement) :**
- Exigences de sécurité (OWASP, authentification, autorisation)
- Exigences réglementaires (RGPD, accessibilité légale)
- Fonctionnalités cœur de métier marquées comme critiques

**Important (à corriger avant release) :**
- Critères d'acceptation des stories en cours
- NFR de performance sur les chemins critiques

**Mineur (backlog) :**
- Features secondaires, cas d'usage rares
- NFR cosmétiques (temps de chargement d'images, animations)

<action>Identifier les tests orphelins (tests sans exigence associée) :</action>
- Tests potentiellement obsolètes (feature supprimée)
- Tests en double (deux tests pour la même chose)
- Tests de régression non documentés (à rattacher à une exigence)
</step>

<step n="5" goal="Générer la matrice et intégrer au CI">
<action>Écrire la matrice dans `{output_matrix}` ou `docs/test-traceability.md`</action>

<action>Utiliser le template de matrice Harmony (trace-template.md)</action>

<action>Générer également un rapport JSON machine-readable :</action>
```json
{
  "generated": "{date}",
  "project": "{project_name}",
  "metrics": {
    "total_requirements": 42,
    "covered": 35,
    "coverage_pct": 83.3,
    "threshold": 80,
    "status": "PASS",
    "orphaned_tests": 3
  },
  "uncovered": [
    { "id": "CA-1-3-01", "risk": "critical", "description": "..." }
  ]
}
```

<action>Si `{coverage_threshold}` non atteint → générer un message d'erreur CI :</action>
```
❌ QUALITY GATE FAILED
Traçabilité : {coverage_pct}% < seuil {coverage_threshold}%
Exigences non couvertes ({count}) :
  - CA-1-3-01 [CRITIQUE] : Reset password
  - CA-2-1-05 [IMPORTANT] : Gestion des erreurs paiement

Action requise : créer les tests manquants avant de merger.
```

<action>Proposer à {user_name} les prochains tests à créer (ordre par risque)</action>
</step>

</workflow>
