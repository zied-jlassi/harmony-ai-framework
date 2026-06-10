# Checklist : Évaluation NFR (ISO/IEC 25010:2023)

## Prérequis
- [ ] NFR identifiées (story, PRD, SLA/SLO, ou seuils Harmony par défaut)
- [ ] Chaque NFR a un identifiant traçable (NFR-001…) et une cible mesurable
- [ ] Environnement de test/staging disponible (charge, sécurité)

## Performance Efficiency
- [ ] Outil de charge sélectionné (k6 / Gatling / Artillery / JMeter / Locust)
- [ ] Scénarios définis (nominal, pic, stress) avec seuils (p95 < {seuil}ms, p99, RPS cible)
- [ ] Résultats documentés : p50, p95, p99, throughput, taux d'erreur
- [ ] Core Web Vitals mesurés si SPA : LCP < 2.5s, **INP < 200ms** (INP remplace FID), CLS < 0.1
- [ ] Soak test (30 min charge nominale) exécuté (fuites mémoire)

## Security
- [ ] SAST exécuté (npm audit / Bandit / gosec / cargo audit / Semgrep)
- [ ] 0 vulnérabilité critique/haute non résolue ; OWASP Top 10 vérifié
- [ ] **SBOM** généré (CycloneDX/SPDX) ; dépendances intègres/signées (supply chain, A08)
- [ ] Secrets non commités (git-secrets/truffleHog) ; HTTPS + headers (CSP, HSTS) ; pas de secret en logs
- [ ] DAST (OWASP ZAP) exécuté si environnement dispo

## Interaction Capability (Accessibilité)
- [ ] Audit Axe automatisé sur les pages principales ; 0 violation **WCAG 2.2 AA** critique
- [ ] Score Lighthouse Accessibilité ≥ 90 ; navigation clavier testée
- [ ] `alt` sur images significatives ; contraste ≥ 4.5:1 ; `lang` sur `<html>` ; rôles ARIA corrects
- [ ] Test manuel lecteur d'écran (NVDA/VoiceOver) sur parcours clés

## Reliability + Safety
- [ ] SLI/SLO définis et **error budget** = 1 − SLO calculé (gouverne la cadence de release)
- [ ] Résilience (chaos) : timeout réseau → dégradation gracieuse ; service down → circuit breaker ; données corrompues → rejet (fail-safe)
- [ ] Timeout configuré sur tous les appels externes ; reprise sans perte d'état (idempotence)
- [ ] MTTR et taux 5xx mesurés si monitoring disponible

## Flexibility (Scalabilité)
- [ ] Spike test (×10 soudain) sans crash ; stress test (point de rupture identifié)
- [ ] Pas de régression de perf sous **10×** la charge nominale ; horizontal scaling vérifié si applicable

## Rapport
- [ ] Rapport NFR dans `docs/nfr-report-{date}.md` ; synthèse par caractéristique ISO 25010 avec statut ✅/❌
- [ ] Consommation de l'error budget reportée ; actions correctives priorisées (effort)
- [ ] Résultats enregistrés dans `.harmony/memory/working.json`
