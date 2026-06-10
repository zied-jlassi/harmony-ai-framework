# Rapport d'Évaluation NFR — {project}

**Date** : {date}
**Version** : {version}
**Auteur** : {user_name}
**Sprint** : {sprint-id}
**Environnement testé** : {environment}

---

## Synthèse exécutive

| NFR-ID | Catégorie | Seuil cible | Résultat mesuré | Statut |
|--------|-----------|-------------|-----------------|--------|
| NFR-PERF-01 | Performance — p95 | < 200ms | {valeur}ms | ✅/❌ |
| NFR-PERF-02 | Performance — Throughput | ≥ 100 RPS | {valeur} RPS | ✅/❌ |
| NFR-PERF-03 | Core Web Vitals — LCP | < 2.5s | {valeur}s | ✅/❌ |
| NFR-PERF-04 | Core Web Vitals — INP | < 200ms | {valeur}ms | ✅/❌ |
| NFR-PERF-05 | Core Web Vitals — CLS | < 0.1 | {valeur} | ✅/❌ |
| NFR-SEC-01 | Sécurité OWASP Top 10 | 0 critique/haute | {n} critique, {n} haute | ✅/❌ |
| NFR-SEC-02 | Vulnérabilités dépendances + SBOM | 0 critique | {n} critique | ✅/❌ |
| NFR-A11Y-01 | Accessibilité WCAG 2.2 AA | 0 violation critique | {n} violation | ✅/❌ |
| NFR-A11Y-02 | Score Lighthouse A11Y | ≥ 90 | {score} | ✅/❌ |
| NFR-REL-01 | Disponibilité (SLO) | ≥ 99.9% (error budget 0.1%) | {valeur}% | ✅/❌ |
| NFR-REL-02 | Erreurs 5xx | < 0.1% | {valeur}% | ✅/❌ |

**Statut global** : ✅ CONFORME / ❌ NON CONFORME ({n}/{total} NFR validées)

---

## 1. Performance

### Métriques de charge ({outil_test_charge})

**Paramètres du test :**
- Outil : {k6 | Gatling | Artillery | JMeter | Locust}
- Durée : {durée}
- Charge nominale : {rps} RPS
- Charge pic : {rps_pic} RPS

**Résultats :**
```
Temps de réponse :
  p50 : {valeur}ms
  p90 : {valeur}ms
  p95 : {valeur}ms  ← Seuil : < {seuil}ms  {✅|❌}
  p99 : {valeur}ms  ← Seuil : < {seuil}ms  {✅|❌}
  max : {valeur}ms

Débit :
  RPS moyen     : {valeur}
  RPS max atteint : {valeur}  ← Seuil : ≥ {seuil}  {✅|❌}

Erreurs :
  Taux d'erreur : {valeur}%  ← Seuil : < 1%  {✅|❌}
  Erreurs 5xx   : {count}
  Timeouts      : {count}
```

### Core Web Vitals (si applicable)

| Métrique | Valeur | Seuil | Statut |
|----------|--------|-------|--------|
| LCP (Largest Contentful Paint) | {valeur}s | < 2.5s | ✅/❌ |
| INP (Interaction to Next Paint) | {valeur}ms | < 200ms | ✅/❌ |
| CLS (Cumulative Layout Shift) | {valeur} | < 0.1 | ✅/❌ |
| TTFB (Time to First Byte) | {valeur}ms | < 600ms | ✅/❌ |

Score Lighthouse Performance : **{score}/100**

---

## 2. Sécurité

### Analyse SAST

**Outil** : {npm audit | Bandit | gosec | cargo audit | Snyk | Semgrep}

| Sévérité | Nombre | Statut |
|----------|--------|--------|
| Critique | {n} | {✅ 0 | ❌} |
| Haute | {n} | {✅ 0 | ❌} |
| Moyenne | {n} | ⚠️ À corriger |
| Faible | {n} | ℹ️ Informatif |

### OWASP Top 10

| Catégorie | Vérifié | Résultat |
|-----------|---------|----------|
| A01 — Broken Access Control | ✅ | {OK | NOK} |
| A02 — Cryptographic Failures | ✅ | {OK | NOK} |
| A03 — Injection | ✅ | {OK | NOK} |
| A04 — Insecure Design | ✅ | {OK | NOK} |
| A05 — Security Misconfiguration | ✅ | {OK | NOK} |
| A06 — Vulnerable Components | ✅ | {OK | NOK} |
| A07 — Auth & Session Failures | ✅ | {OK | NOK} |
| A09 — Security Logging | ✅ | {OK | NOK} |

### DAST (si exécuté)
**Outil** : OWASP ZAP
**Alertes** : {n} haute, {n} moyenne, {n} faible

---

## 3. Accessibilité

### Audit automatisé (Axe / Lighthouse)

**Score Lighthouse Accessibilité** : **{score}/100** ← Seuil : ≥ 90 {✅|❌}

**Violations Axe (WCAG 2.2 AA) :**

| Règle WCAG | Description | Éléments affectés | Sévérité |
|------------|-------------|-------------------|----------|
| {1.4.3} | {Contraste insuffisant} | {n} éléments | {critique|modérée|mineure} |

**Critères manuels vérifiés :**
- [ ] Navigation au clavier complète
- [ ] Focus visible sur tous les éléments interactifs
- [ ] Texte alternatif sur toutes les images
- [ ] Formulaires accessibles (labels, erreurs)

---

## 4. Fiabilité

| Scénario testé | Comportement observé | Résultat |
|----------------|---------------------|----------|
| Timeout réseau (5s) | {comportement} | ✅/❌ |
| Service DB indisponible | {comportement} | ✅/❌ |
| Service externe indisponible | {comportement} | ✅/❌ |
| Input invalide | {comportement} | ✅/❌ |

---

## 5. Actions correctives requises

### Priorité 1 — Bloquer le déploiement
{Liste des NFR critiques en échec avec actions concrètes}

### Priorité 2 — Corriger avant release
{Liste des NFR importantes en échec}

### Priorité 3 — Plan d'amélioration
{Liste des NFR à améliorer à moyen terme}

---

*Rapport généré par Harmony Framework — workflow test-architect-nfr-assess*
