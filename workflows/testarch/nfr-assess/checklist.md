# Checklist : Évaluation NFR

## Prérequis
- [ ] NFR identifiées (depuis story, PRD, SLA, ou seuils Harmony par défaut)
- [ ] Chaque NFR a un identifiant traçable (NFR-001, NFR-002...)
- [ ] Environnement de test/staging disponible (pour tests de charge et sécurité)

## Performance (NFR-PERF)
- [ ] Outil de test de charge sélectionné (k6 / Gatling / Artillery / JMeter / Locust)
- [ ] Scénarios de charge définis (nominal, pic, stress)
- [ ] Seuils définis : p95 < {seuil}ms, p99 < {seuil}ms, RPS cible
- [ ] Tests de charge exécutés
- [ ] Résultats : p50, p95, p99, throughput (RPS), taux d'erreur documentés
- [ ] Core Web Vitals mesurés si SPA (LCP, FID/INP, CLS, TTFB)
- [ ] Score Lighthouse Performance ≥ 80 si applicable
- [ ] Soak test (30 min charge nominale) exécuté pour détecter fuites mémoire

## Sécurité (NFR-SEC)
- [ ] Analyse SAST exécutée (npm audit / Bandit / gosec / cargo audit / Snyk)
- [ ] 0 vulnérabilité critique ou haute non résolue
- [ ] OWASP Top 10 vérifié (injection, auth, misconfig, composants vulnérables...)
- [ ] Secrets non commités vérifiés (git-secrets / truffleHog)
- [ ] HTTPS forcé, headers de sécurité présents (CSP, HSTS, X-Frame-Options)
- [ ] Données sensibles non présentes dans les logs
- [ ] DAST exécuté (OWASP ZAP) si environnement disponible

## Accessibilité (NFR-A11Y)
- [ ] Audit Axe automatisé exécuté sur toutes les pages principales
- [ ] 0 violation WCAG 2.1 niveau AA critique
- [ ] Score Lighthouse Accessibilité ≥ 90
- [ ] Navigation au clavier testée (Tab, Shift+Tab, Enter, Escape)
- [ ] Attributs `alt` présents sur toutes les images significatives
- [ ] Contraste texte/fond ≥ 4.5:1 (texte normal), ≥ 3:1 (grand texte)
- [ ] Attribut `lang` présent sur `<html>`
- [ ] Pa11y scan exécuté en complément si applicable

## Fiabilité (NFR-REL)
- [ ] Comportement sous timeout réseau testé (graceful degradation)
- [ ] Circuit breaker fonctionnel (service indisponible → fallback)
- [ ] Timeout configuré sur tous les appels externes (pas de blocage infini)
- [ ] Validation des inputs → rejet explicite des données invalides
- [ ] Logs d'erreur présents pour toutes les exceptions non gérées
- [ ] SLA uptime vérifié si monitoring disponible

## Scalabilité (NFR-SCALE)
- [ ] Spike test : charge x10 soudaine sans crash
- [ ] Stress test : point de rupture identifié
- [ ] Pas de régression de performance sous 2x la charge nominale
- [ ] Horizontal scaling vérifié si applicable

## Rapport
- [ ] Rapport NFR écrit dans `docs/nfr-report-{date}.md`
- [ ] Tableau de synthèse : toutes les NFR avec statut ✅/❌
- [ ] Actions correctives pour les NFR en échec
- [ ] Plan de remédiation inclus
- [ ] Résultats enregistrés dans `.harmony/memory/working.json`
