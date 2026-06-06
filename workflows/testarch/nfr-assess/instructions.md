# Workflow : Évaluation des Exigences Non-Fonctionnelles (NFR)

<critical>Ce workflow évalue et teste les exigences non-fonctionnelles selon 5 dimensions : Performance, Sécurité, Accessibilité, Fiabilité et Scalabilité. Chaque NFR est référencée par un identifiant traçable (NFR-001, NFR-002...).</critical>

<workflow>

<step n="1" goal="Identifier et inventorier les NFR du projet">
<action>Communiquer en {communication_language} avec {user_name}</action>

<action>Extraire les NFR des sources disponibles :</action>
- Story ou PRD courant (`{working_memory}:current_story`)
- Fichier de spécifications techniques
- SLA définis (contrats, accords de niveau de service)
- Contraintes réglementaires (RGPD, WCAG, PCI-DSS, HIPAA)

<action>Si aucune NFR explicite → appliquer les seuils Harmony par défaut :</action>

| ID | Catégorie | Seuil par défaut |
|----|-----------|-----------------|
| NFR-001 | Performance — Temps de réponse API | p95 < 200ms, p99 < 500ms |
| NFR-002 | Performance — Throughput | ≥ 100 RPS sans dégradation |
| NFR-003 | Accessibilité | WCAG 2.1 niveau AA |
| NFR-004 | Sécurité | OWASP Top 10 — 0 vulnérabilité critique/haute |
| NFR-005 | Fiabilité | Uptime ≥ 99.5%, pas d'erreur 5xx non gérée |
| NFR-006 | Scalabilité | Pas de régression de perf sous 10x charge nominale |
| NFR-007 | Taille de bundle (SPA) | < 200KB JS initial (gzippé) |
| NFR-008 | Core Web Vitals | LCP < 2.5s, FID < 100ms, CLS < 0.1 |

<action>Adapter les seuils au contexte projet si `{nfr_type}` est spécifié</action>
</step>

<step n="2" goal="Tests de Performance (si nfr_type = performance ou all)">
<action>Sélectionner l'outil de test de charge selon le contexte :</action>

| Outil | Usage recommandé | Format de script |
|-------|-----------------|-----------------|
| **k6** | APIs REST, microservices, SPA (léger, scriptable JS) | JavaScript |
| **Gatling** | Applications Java/Scala, rapports HTML riches | Scala/Java |
| **Artillery** | Node.js, WebSockets, scénarios complexes | YAML/JavaScript |
| **JMeter** | Applications legacy, GUI disponible, protocoles variés | XML/GUI |
| **Locust** | Applications Python, scénarios distribués | Python |

<action>Concevoir les scénarios de charge :</action>
```javascript
// Exemple k6 — Scénario multi-étapes
export const options = {
  stages: [
    { duration: '2m', target: 50 },   // Montée progressive
    { duration: '5m', target: 100 },   // Charge nominale
    { duration: '2m', target: 200 },   // Pic de charge
    { duration: '1m', target: 0 },     // Descente
  ],
  thresholds: {
    http_req_duration: ['p(95)<200', 'p(99)<500'],
    http_req_failed: ['rate<0.01'],    // < 1% d'erreurs
  },
}
```

<action>Exécuter les tests et analyser :</action>
- Temps de réponse (p50, p95, p99)
- Throughput (RPS réel vs cible)
- Taux d'erreur sous charge
- Saturation des ressources (CPU, mémoire)
- Core Web Vitals si applicable (Lighthouse CI)
</step>

<step n="3" goal="Tests de Sécurité (si nfr_type = security ou all)">
<action>Exécuter une analyse SAST (Static Application Security Testing) :</action>

| Stack | Outil SAST |
|-------|-----------|
| JavaScript/TypeScript | `npm audit`, ESLint avec plugins sécurité, Semgrep |
| Python | Bandit, Safety, Semgrep |
| Java | SpotBugs, PMD, Snyk |
| Go | gosec |
| Rust | `cargo audit` |

<action>Vérifier les OWASP Top 10 :</action>
```
A01 — Broken Access Control      → Tests d'autorisation : accès avec rôle insuffisant
A02 — Cryptographic Failures     → Vérifier HTTPS, chiffrement at-rest, hachage mdp (bcrypt/argon2)
A03 — Injection (SQL, NoSQL, OS) → Tests avec payloads d'injection sur tous les inputs
A04 — Insecure Design            → Revue d'architecture des flux d'authentification
A05 — Security Misconfiguration  → Headers HTTP (CSP, HSTS, X-Frame-Options), CORS
A06 — Vulnerable Components      → `npm audit`, `pip-audit`, Snyk
A07 — Auth & Session Failures    → Tests JWT (expiration, signature), session fixation
A08 — Software Integrity Failures → Vérification des checksums des dépendances
A09 — Security Logging Failures  → Présence de logs d'audit pour actions sensibles
A10 — SSRF                       → Tests de requêtes vers ressources internes
```

<action>Analyse DAST si environnement de test disponible :</action>
```bash
# OWASP ZAP — Scan automatisé
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://staging.example.com \
  -r zap-report.html
```

<action>Vérifier la gestion des données sensibles :</action>
- Aucune clé API/secret dans le code source (`git-secrets`, `truffleHog`)
- Variables d'environnement pour les credentials
- Sanitization des inputs utilisateur
- Pas de données sensibles dans les logs
</step>

<step n="4" goal="Tests d'Accessibilité (si nfr_type = accessibility ou all)">
<action>Évaluer la conformité WCAG 2.1 niveau AA :</action>

**Outils automatisés :**
```javascript
// Playwright + axe-core
import { checkA11y } from 'axe-playwright'

test('page principale conforme WCAG 2.1 AA', async ({ page }) => {
  await page.goto('/')
  await checkA11y(page, null, {
    runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21aa'] }
  })
})
```

| Outil | Usage |
|-------|-------|
| **Axe** (axe-core) | Tests automatisés intégrés à Playwright/Cypress |
| **Lighthouse** | Audit complet depuis Chrome DevTools ou CI |
| **Pa11y** | Scan de pages en ligne de commande |
| **NVDA/VoiceOver** | Test manuel avec lecteur d'écran (recommandé) |

**Critères WCAG 2.1 AA à vérifier :**
- 1.1.1 — Alternatives textuelles pour images (`alt` attribut)
- 1.4.3 — Contraste minimum 4.5:1 pour le texte normal
- 2.1.1 — Navigation complète au clavier (Tab, Enter, Escape)
- 2.4.7 — Focus visible sur les éléments interactifs
- 3.1.1 — Langue de la page déclarée (`lang` attribut)
- 4.1.2 — Rôles ARIA corrects sur les composants custom

**Score Lighthouse cible :** Accessibilité ≥ 90
</step>

<step n="5" goal="Tests de Fiabilité et Scalabilité (si nfr_type = reliability ou all)">
<action>Tests de fiabilité :</action>
```
Scénarios à tester :
  - Timeout réseau → comportement graceful (retry, fallback, message utilisateur)
  - Service indisponible → circuit breaker actif
  - Base de données lente → timeout configuré, pas de blocage infini
  - Données corrompues → validation et rejet explicite
  - Redémarrage applicatif → reprise sans perte d'état critique
```

<action>Tests de scalabilité :</action>
- Soak test : charge nominale sur 30 minutes (détecter fuites mémoire)
- Stress test : monter jusqu'au point de rupture (identifier le max RPS)
- Spike test : pic soudain de trafic x10, retour à la normale
- Chaos testing si infrastructure le permet (kill process, saturer CPU)

<action>Vérifier les SLA définis :</action>
- Uptime calculé sur les 30 derniers jours (si monitoring disponible)
- Temps moyen de récupération après incident (MTTR)
- Nombre d'erreurs 5xx / total requêtes
</step>

<step n="6" goal="Produire le rapport NFR">
<action>Écrire le rapport dans `{output_report}` ou `docs/nfr-report-{date}.md`</action>

**Format du rapport :**
```markdown
# Rapport NFR — {project} — {date}

## Synthèse

| NFR-ID | Catégorie | Cible | Mesuré | Statut |
|--------|-----------|-------|--------|--------|
| NFR-001 | Performance p95 | < 200ms | {valeur}ms | ✅/❌ |
| NFR-003 | Accessibilité | WCAG 2.1 AA | Score: {n} | ✅/❌ |
| NFR-004 | Sécurité OWASP | 0 critique | {n} critique | ✅/❌ |

## Détail par catégorie
{résultats détaillés avec graphiques ASCII si pertinent}

## Actions correctives requises
{liste priorisée des corrections avec effort estimé}

## Plan de remédiation
{roadmap pour atteindre tous les seuils}
```

<action>Mettre à jour `.harmony/memory/working.json` avec les résultats NFR</action>
<action>Afficher à {user_name} les NFR en échec et les actions prioritaires</action>
</step>

</workflow>
