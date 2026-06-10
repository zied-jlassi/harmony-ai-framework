# Workflow : Évaluation des Exigences Non-Fonctionnelles (NFR)

> **But** — Évaluer et tester les exigences non-fonctionnelles, structurées d'après le modèle de qualité produit **ISO/IEC 25010:2023** (9 caractéristiques). Chaque NFR reçoit un identifiant traçable (NFR-001…) avec une cible mesurable et un statut.

Communiquer en `{communication_language}` avec `{user_name}`.

## 1. Inventorier les NFR (modèle ISO/IEC 25010:2023)

Extraire les NFR des sources : story/PRD courant, spécifications techniques, SLA/SLO contractuels, contraintes réglementaires (RGPD, WCAG, PCI-DSS, HIPAA). Cadrer par les 9 caractéristiques (révision 2023 : ajout de **Safety**, *Usability* → **Interaction Capability**, *Portability* → **Flexibility**) :

| # | Caractéristique 25010:2023 | Exemples de NFR testables |
|---|----------------------------|---------------------------|
| 1 | Functional Suitability | complétude, exactitude fonctionnelle |
| 2 | Performance Efficiency | latence p95/p99, débit, usage ressources |
| 3 | Compatibility | navigateurs/OS, interopérabilité, coexistence |
| 4 | Interaction Capability | accessibilité (WCAG), Core Web Vitals, inclusivité |
| 5 | Reliability | dispo (SLO), tolérance aux pannes, récupérabilité |
| 6 | Security | authz/authn, confidentialité, intégrité, OWASP |
| 7 | Maintainability | modularité, testabilité, analysabilité |
| 8 | Flexibility | scalabilité, adaptabilité, installabilité |
| 9 | Safety | fail-safe, garde-fous, identification des risques |

Si aucun seuil explicite → appliquer les défauts Harmony :

| ID | Domaine | Seuil par défaut |
|----|---------|------------------|
| NFR-001 | Latence API | p95 < 200ms, p99 < 500ms |
| NFR-002 | Débit | ≥ 100 RPS sans dégradation |
| NFR-003 | Accessibilité | WCAG 2.2 niveau AA |
| NFR-004 | Sécurité | OWASP Top 10 — 0 vuln critique/haute |
| NFR-005 | Fiabilité (SLO) | dispo ≥ 99.9% (error budget 0.1%), 0 erreur 5xx non gérée |
| NFR-006 | Scalabilité | pas de régression de perf sous 10× charge nominale |
| NFR-007 | Bundle SPA | < 200KB JS initial (gzippé) |
| NFR-008 | Core Web Vitals | LCP < 2.5s, **INP < 200ms**, CLS < 0.1 |

> ⚠️ **INP a remplacé FID** comme Core Web Vital (depuis mars 2024) : mesurer **Interaction to Next Paint** (réactivité de toutes les interactions), cible < 200 ms.

## 2. Performance (Performance Efficiency)

Choisir l'outil de charge : **k6** (API/JS, léger), Gatling (JVM, rapports riches), Artillery (Node/WebSockets), JMeter (legacy/GUI), Locust (Python).

```javascript
// k6 — scénario multi-étapes avec seuils
export const options = {
  stages: [
    { duration: '2m', target: 50 },   // montée
    { duration: '5m', target: 100 },  // charge nominale
    { duration: '2m', target: 200 },  // pic
    { duration: '1m', target: 0 },    // descente
  ],
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'], // < 1% d'erreurs
  },
}
```

Analyser : p50/p95/p99, débit réel vs cible, taux d'erreur sous charge, saturation CPU/mémoire, Core Web Vitals via Lighthouse CI (LCP, **INP**, CLS).

## 3. Sécurité (Security)

SAST par stack : `npm audit`/Semgrep (JS/TS), Bandit/Safety/Semgrep (Python), SpotBugs/Snyk (Java), gosec (Go), `cargo audit` (Rust). Vérifier OWASP Top 10 (A01 accès, A02 crypto, A03 injection, A04 design, A05 misconfig, A06 composants vulnérables, A07 auth/session, A08 intégrité, A09 logging, A10 SSRF).

DAST si environnement dispo (OWASP ZAP baseline). Secrets : `git-secrets`/truffleHog, variables d'env, pas de secret en logs. **Supply chain** (moderne) : générer un **SBOM** (CycloneDX/SPDX), vérifier les dépendances signées et l'intégrité (A08). Déléguer l'audit approfondi à l'agent security.

## 4. Accessibilité (Interaction Capability)

Évaluer WCAG 2.2 AA — automatisé (axe-core via Playwright/Cypress, Lighthouse, Pa11y) + **manuel** (lecteur d'écran NVDA/VoiceOver, navigation clavier).

```javascript
import { checkA11y } from 'axe-playwright'
test('conforme WCAG 2.2 AA', async ({ page }) => {
  await page.goto('/')
  await checkA11y(page, null, { runOnly: { type: 'tag', values: ['wcag2a','wcag2aa','wcag22aa'] } })
})
```

Critères clés : alternatives textuelles, contraste ≥ 4.5:1, navigation clavier complète, focus visible, langue déclarée, rôles ARIA corrects. Score Lighthouse a11y ≥ 90.

## 5. Fiabilité & résilience (Reliability + Safety)

Définir SLI/SLO et **error budget** = 1 − SLO (ex. SLO 99.9% → budget 0.1% ≈ 1000 erreurs / 1M req sur 4 semaines). Le budget gouverne la cadence de release.

Tests de résilience (chaos engineering — hypothèse → injection → observation) :
```
- Timeout réseau        → dégradation gracieuse (retry borné, fallback, message)
- Service indisponible  → circuit breaker actif, pas de cascade
- Dépendance lente      → timeout configuré, pas de blocage infini
- Données corrompues    → validation + rejet explicite (fail-safe)
- Redémarrage           → reprise sans perte d'état critique (idempotence)
```

Scalabilité : soak (30 min, fuites mémoire), stress (point de rupture / max RPS), spike (×10 soudain). Mesurer MTTR, taux 5xx, consommation de l'error budget.

## 6. Produire le rapport NFR

Écrire le rapport dans `{output_report}` ou `docs/nfr-report-{date}.md` :
```markdown
# Rapport NFR — {project} — {date}

## Synthèse (par caractéristique ISO 25010:2023)
| NFR-ID | Caractéristique | Cible | Mesuré | Statut |
|--------|-----------------|-------|--------|--------|
| NFR-001 | Performance | p95 < 200ms | {v}ms | ✅/❌ |
| NFR-005 | Reliability (SLO) | 99.9% | {v}% | ✅/❌ |
| NFR-008 | Interaction (INP) | < 200ms | {v}ms | ✅/❌ |

## Détail par caractéristique
## Error budget : consommation et impact sur les releases
## Actions correctives priorisées (effort estimé)
```

Mettre à jour `.harmony/memory/working.json` avec les résultats. Afficher à `{user_name}` les NFR en échec et les actions prioritaires.
