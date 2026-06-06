# Infrastructure Security - Docker, CVE, SIEM, WAF, Egress

> Module de l'agent `/hf-agent-security`
> **Commandes**: `audit-docker`, `audit-infra`, `audit-siem`, `audit-waf`, `audit-egress`

---

## Securite Docker & Conteneurs

### Recommandations ANSSI Docker (ANSSI-FT-082)

```
+-----------------------------------------------------------------+
|              16 RECOMMANDATIONS ANSSI DOCKER                    |
+-----------------------------------------------------------------+
|                                                                  |
|  R1. Ne pas utiliser --privileged                               |
|  R2. Monter volumes avec droits minimaux (ro/rw)                |
|  R3. Eviter --network host                                      |
|  R4. Activer user namespace remapping                           |
|  R5. Ne pas executer en root dans le conteneur                  |
|  R6. Limiter les capabilities (drop ALL, add specific)          |
|  R7. Utiliser seccomp profiles                                  |
|  R8. Activer AppArmor/SELinux                                   |
|  R9. Limiter ressources (--memory, --cpus)                      |
|  R10. Scanner images avant deploiement                          |
|  R11. Utiliser images officielles/verifiees                     |
|  R12. Ne pas stocker secrets dans l'image                       |
|  R13. Mettre a jour regulierement                               |
|  R14. Activer Docker Content Trust                              |
|  R15. Isoler les reseaux Docker                                 |
|  R16. Auditer avec docker-bench-security                        |
|                                                                  |
+-----------------------------------------------------------------+
```

### Configuration Docker Securisee

```dockerfile
# Dockerfile securise
FROM node:20-alpine

# Non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Pas de secrets dans l'image
# Utiliser multi-stage build

WORKDIR /app
COPY --chown=appuser:appgroup . .

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["node", "dist/main.js"]
```

```yaml
# docker-compose.yml securise
services:
  app:
    image: myapp:latest
    read_only: true
    security_opt:
      - no-new-privileges:true
      - seccomp:seccomp-profile.json
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    networks:
      - backend
    # Ne JAMAIS exposer sur 0.0.0.0
    ports:
      - "127.0.0.1:3000:3000"
```

### CIS Docker Benchmark v1.7.0 Checklist

```
+-----------------------------------------------------------------+
|                  CIS DOCKER BENCHMARK v1.7.0                    |
+-----------------------------------------------------------------+
|                                                                  |
|  HOST CONFIGURATION                                              |
|  [ ] Partition separee pour /var/lib/docker                     |
|  [ ] Seuls utilisateurs de confiance dans groupe docker         |
|  [ ] Auditd active pour daemon Docker                           |
|  [ ] Docker daemon non expose sur le reseau                     |
|                                                                  |
|  DAEMON CONFIGURATION                                            |
|  [ ] Rootless mode si possible                                  |
|  [ ] TLS pour Docker API (si exposee)                           |
|  [ ] Log level = info                                           |
|  [ ] Live restore active                                        |
|  [ ] Userland proxy desactive                                   |
|                                                                  |
|  IMAGES                                                          |
|  [ ] Images de base officielles uniquement                      |
|  [ ] Images scannees (Trivy, Snyk)                              |
|  [ ] Content Trust active (DOCKER_CONTENT_TRUST=1)              |
|  [ ] Pas de secrets en dur                                      |
|  [ ] COPY au lieu de ADD                                        |
|                                                                  |
|  RUNTIME                                                         |
|  [ ] --privileged INTERDIT                                      |
|  [ ] Pas de SSH dans les conteneurs                             |
|  [ ] Volumes sensibles non montes                               |
|  [ ] PIDs limites (--pids-limit)                                |
|                                                                  |
+-----------------------------------------------------------------+
```

### Outil d'Audit Docker

```bash
# Docker Bench Security
docker run --rm --net host --pid host --userns host --cap-add audit_control \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /etc:/etc:ro \
  docker/docker-bench-security
```

---

## CVE Critiques Recentes (2024-2025)

### Container Escape - "Leaky Vessels"

| CVE | Composant | CVSS | Impact |
|-----|-----------|------|--------|
| **CVE-2024-21626** | runC | 8.6 (High) | Container escape via file descriptor leak |
| **CVE-2024-23651** | BuildKit | High | Symlink attack vers host |
| **CVE-2024-23652** | BuildKit | High | Bind mount manipulation |
| **CVE-2024-23653** | BuildKit | High | Privilege escalation at build time |

**Remediation:**
```bash
# Mettre a jour runC >= 1.1.12
runc --version
# Mettre a jour Docker >= 25.0.1
docker --version
```

### Node.js CVE Critiques (2024-2025)

| CVE | Version | CVSS | Impact |
|-----|---------|------|--------|
| **CVE-2024-27980** | All | High | BatBadBut - Code execution via child_process |
| **CVE-2025-27210** | 20.x, 22.x, 24.x | High | Path traversal Windows |
| **CVE-2025-27209** | 24.x | High | HashDoS via rapidhash collisions |
| **CVE-2024-22019** | All | High | HTTP chunked encoding DoS |

**Remediation:**
```bash
node --version
nvm install --lts
```

### NestJS CVE Critiques

| CVE | Composant | CVSS | Impact |
|-----|-----------|------|--------|
| **CVE-2025-54782** | @nestjs/devtools-integration | Critical | RCE via CSRF + sandbox escape |
| **CVE-2024-29409** | @nestjs/common | Medium | Code injection via Content-Type |
| **CVE-2025-47944** | @nestjs/platform-express | High | Multer dependency vulnerability |

### Supply Chain Attacks npm (2024-2025)

```
ALERTE CRITIQUE - Septembre 2025
-----------------------------------------------------------
18 packages compromis via phishing
2.6 MILLIARDS de telechargements hebdomadaires affectes

Packages touches:
- ansi-styles (371M/semaine)
- debug (358M)
- chalk (300M)
- supports-color (287M)
- strip-ansi (261M)
-----------------------------------------------------------
```

**Protection Supply Chain:**
```bash
npm ci --ignore-scripts
npm audit --audit-level=high
npm sbom --sbom-format cyclonedx
```

---

## Supervision Securite (SOC/SIEM)

### Constat: Logs Non Exploites

```
+-----------------------------------------------------------------+
|          RISQUE: LOGS SANS SUPERVISION ACTIVE                   |
+-----------------------------------------------------------------+
|                                                                  |
|  SITUATION TYPIQUE                                               |
|  +-- Logs centralises (ELK, CloudWatch, etc.)                   |
|  +-- Utilises pour debug                                        |
|  +-- Exploites pour securite                                    |
|  +-- Personne ne regarde les alertes                            |
|                                                                  |
|  CONSEQUENCES                                                    |
|  +-- Detection tardive des incidents (jours/semaines)           |
|  +-- Attaquants persistants non detectes                        |
|  +-- Exfiltration de donnees invisible                          |
|  +-- Non-conformite RGPD (obligation de notification 72h)       |
|  +-- Impossibilite de forensics post-incident                   |
|                                                                  |
+-----------------------------------------------------------------+
```

### Checklist Supervision Securite

```
+-----------------------------------------------------------------+
|          CHECKLIST SUPERVISION SECURITE                         |
+-----------------------------------------------------------------+
|                                                                  |
|  COLLECTE                                                        |
|  [ ] Logs applicatifs (auth, erreurs, actions)                  |
|  [ ] Logs infrastructure (Docker, systeme, reseau)              |
|  [ ] Logs base de donnees (requetes lentes, erreurs)            |
|  [ ] Metriques (CPU, memoire, connexions)                       |
|  [ ] Format structure (JSON) avec timestamp UTC                 |
|                                                                  |
|  EVENEMENTS A LOGGER OBLIGATOIREMENT                            |
|  [ ] Authentification (succes ET echecs)                        |
|  [ ] Changements de permissions/roles                           |
|  [ ] Acces aux donnees sensibles                                |
|  [ ] Modifications de configuration                             |
|  [ ] Exports de donnees                                         |
|  [ ] Erreurs 4xx/5xx avec contexte                              |
|  [ ] Connexions reseau inhabituelles                            |
|                                                                  |
|  REGLES D'ALERTE (exemples)                                     |
|  [ ] > 5 echecs auth en 5 min -> Alerte brute force             |
|  [ ] Login depuis nouveau pays -> Alerte (ou MFA)               |
|  [ ] Export > 1000 lignes -> Notification admin                 |
|  [ ] Erreur 500 repetee -> Alerte immediate                     |
|  [ ] Acces hors heures ouvrees -> Log + review                  |
|                                                                  |
|  REPONSE                                                         |
|  [ ] Procedure d'escalade documentee                            |
|  [ ] Contacts d'urgence a jour                                  |
|  [ ] Playbooks pour incidents courants                          |
|  [ ] Tests reguliers du systeme d'alerte                        |
|                                                                  |
|  RETENTION (RGPD)                                               |
|  [ ] Duree de conservation justifiee et documentee              |
|  [ ] Logs securite: 1-3 ans recommande                          |
|  [ ] Purge automatique apres expiration                         |
|  [ ] Archivage chiffre pour forensics                           |
|                                                                  |
+-----------------------------------------------------------------+
```

### Implementation: Alertes avec Loki + Grafana

```yaml
# docker-compose.yml - Stack monitoring
services:
  loki:
    image: grafana/loki:2.9.0
    ports:
      - "127.0.0.1:3100:3100"
    volumes:
      - ./loki-config.yaml:/etc/loki/config.yaml
      - loki-data:/loki

  promtail:
    image: grafana/promtail:2.9.0
    volumes:
      - /var/log:/var/log:ro
      - ./promtail-config.yaml:/etc/promtail/config.yaml
    depends_on:
      - loki

  grafana:
    image: grafana/grafana:latest
    ports:
      - "127.0.0.1:3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana-provisioning:/etc/grafana/provisioning
```

```typescript
// Service de logging securite NestJS
import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class SecurityLogService {
  private readonly logger = new Logger('SECURITY');

  logAuthAttempt(userId: string, success: boolean, metadata: AuthMetadata) {
    this.logger.log({
      event: success ? 'AUTH_SUCCESS' : 'AUTH_FAILURE',
      userId,
      timestamp: new Date().toISOString(),
      ip: metadata.ip,
      userAgent: metadata.userAgent,
      method: metadata.method,
    });

    if (!success) {
      this.checkBruteForce(userId, metadata.ip);
    }
  }

  logDataAccess(userId: string, resource: string, action: string, count: number) {
    this.logger.log({
      event: 'DATA_ACCESS',
      userId,
      resource,
      action,
      recordCount: count,
      timestamp: new Date().toISOString(),
    });

    if (action === 'EXPORT' && count > 1000) {
      this.alertService.notify({
        severity: 'MEDIUM',
        message: `Large data export: ${count} records by user ${userId}`,
      });
    }
  }
}
```

### Regles d'Alerte Grafana (LogQL)

```yaml
# grafana-alerting-rules.yaml
groups:
  - name: security-alerts
    rules:
      # Alerte brute force
      - alert: BruteForceDetected
        expr: |
          sum(count_over_time({app="api"} |= "AUTH_FAILURE" [5m])) by (ip) > 5
        for: 1m
        labels:
          severity: high

      # Export massif
      - alert: LargeDataExport
        expr: |
          {app="api"} |= "DATA_ACCESS" | json | action="EXPORT" | recordCount > 1000
        labels:
          severity: medium

      # Erreurs 500 repetees
      - alert: HighErrorRate
        expr: |
          sum(count_over_time({app="api"} |= "ERROR" | json | status=~"5.." [5m])) > 10
        for: 2m
        labels:
          severity: critical
```

---

## WAF & Inspection Applicative

### Checklist WAF

```
+-----------------------------------------------------------------+
|          CHECKLIST WAF (Web Application Firewall)               |
+-----------------------------------------------------------------+
|                                                                  |
|  REGLES DE BASE                                                  |
|  [ ] OWASP Core Rule Set (CRS) active                           |
|  [ ] Blocage injections SQL                                     |
|  [ ] Blocage XSS                                                |
|  [ ] Blocage path traversal                                     |
|  [ ] Blocage command injection                                  |
|                                                                  |
|  RATE LIMITING                                                   |
|  [ ] Limite requetes/IP                                         |
|  [ ] Limite requetes/endpoint                                   |
|  [ ] Slowloris protection                                       |
|                                                                  |
|  CONFIGURATION                                                   |
|  [ ] Mode detection -> blocking en production                   |
|  [ ] Logs des requetes bloquees                                 |
|  [ ] Whitelist endpoints specifiques si necessaire              |
|  [ ] Mise a jour regles reguliere                               |
|                                                                  |
+-----------------------------------------------------------------+
```

### Configuration ModSecurity (Nginx)

```nginx
# nginx.conf
modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/main.conf;

# main.conf
SecRuleEngine On
SecRequestBodyAccess On
SecResponseBodyAccess On
SecResponseBodyMimeType text/plain text/html text/xml application/json

# OWASP CRS
Include /etc/nginx/modsec/owasp-crs/crs-setup.conf
Include /etc/nginx/modsec/owasp-crs/rules/*.conf
```

### AWS WAF Configuration

```typescript
// Configuration AWS WAF via CDK
const webAcl = new wafv2.CfnWebACL(this, 'ApiWaf', {
  scope: 'REGIONAL',
  defaultAction: { allow: {} },
  rules: [
    {
      name: 'AWSManagedRulesCommonRuleSet',
      priority: 1,
      overrideAction: { none: {} },
      statement: {
        managedRuleGroupStatement: {
          vendorName: 'AWS',
          name: 'AWSManagedRulesCommonRuleSet',
        },
      },
    },
    {
      name: 'AWSManagedRulesSQLiRuleSet',
      priority: 2,
      overrideAction: { none: {} },
      statement: {
        managedRuleGroupStatement: {
          vendorName: 'AWS',
          name: 'AWSManagedRulesSQLiRuleSet',
        },
      },
    },
    {
      name: 'RateLimitRule',
      priority: 3,
      action: { block: {} },
      statement: {
        rateBasedStatement: {
          limit: 2000,
          aggregateKeyType: 'IP',
        },
      },
    },
  ],
});
```

---

## Egress Filtering (Flux Sortants)

### Risque: Reverse Shell / Exfiltration

```
+-----------------------------------------------------------------+
|          RISQUE: FLUX SORTANTS NON CONTROLES                    |
+-----------------------------------------------------------------+
|                                                                  |
|  SCENARIOS D'ATTAQUE                                             |
|  +-- Reverse shell vers serveur attaquant                       |
|  +-- Exfiltration donnees via DNS/HTTPS                         |
|  +-- Communication C2 (Command & Control)                       |
|  +-- Cryptomining utilisant ressources                          |
|                                                                  |
|  SANS FILTRAGE EGRESS                                            |
|  +-- Tout conteneur peut appeler n'importe quelle IP            |
|  +-- Impossible de detecter exfiltration                        |
|  +-- Attaquant peut maintenir acces persistant                  |
|                                                                  |
+-----------------------------------------------------------------+
```

### Checklist Egress Filtering

```
+-----------------------------------------------------------------+
|          CHECKLIST FILTRAGE SORTANT                             |
+-----------------------------------------------------------------+
|                                                                  |
|  RESEAU                                                          |
|  [ ] Whitelist des destinations autorisees                      |
|  [ ] Bloquer tout par defaut (deny all)                         |
|  [ ] Proxy pour requetes HTTP/HTTPS sortantes                   |
|  [ ] DNS interne uniquement                                     |
|                                                                  |
|  DOCKER                                                          |
|  [ ] Reseaux internes (internal: true)                          |
|  [ ] Pas d'acces direct internet pour DB                        |
|  [ ] Seul le reverse proxy accede a l'exterieur                 |
|                                                                  |
|  MONITORING                                                      |
|  [ ] Logs de toutes les connexions sortantes                    |
|  [ ] Alertes sur destinations inconnues                         |
|  [ ] Volume de donnees sortantes surveille                      |
|                                                                  |
+-----------------------------------------------------------------+
```

### Configuration Docker Network Isolation

```yaml
# docker-compose.yml - Isolation reseau
networks:
  # Reseau INTERNE - pas d'acces internet
  backend:
    internal: true
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16

  # Reseau FRONTEND - acces internet limite
  frontend:
    driver: bridge

services:
  # Base de donnees - JAMAIS d'acces internet
  postgres:
    networks:
      - backend
    # Pas de ports exposes vers l'hote

  # API - acces internet pour webhooks uniquement
  api:
    networks:
      - backend
      - frontend
    environment:
      - ALLOWED_OUTBOUND_HOSTS=api.stripe.com,hooks.slack.com

  # Nginx - seul point d'entree/sortie
  nginx:
    networks:
      - frontend
    ports:
      - "443:443"
```

---

## References

- [ANSSI Docker](https://cyber.gouv.fr/sites/default/files/2020/12/docker_fiche_technique.pdf)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [MITRE ATT&CK Containers](https://attack.mitre.org/matrices/enterprise/containers/)
- [Node.js Security Releases](https://nodejs.org/en/blog/vulnerability/)
- [OWASP ModSecurity CRS](https://coreruleset.org/)
