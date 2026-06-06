# OWASP Top 10 Checklists

> Module de l'agent `/hf-agent-security`
> **Commandes**: `audit`, `audit-code`, `audit-rbac`

---

## OWASP Top 10 (2021/2024)

### A01 - Broken Access Control (1er)
```typescript
// OBLIGATOIRE - Guards sur TOUS les endpoints
@UseGuards(JwtAuthGuard, RolesGuard, PlayerGuard)
@Roles(UserRole.FAMILY_ADMIN)
@PlayerProtected({ resourceIdParam: 'id', entityType: 'resource' })
```

### A02 - Cryptographic Failures
```typescript
// Checklist
- [ ] HTTPS enforced (TLS 1.3)
- [ ] Sensitive data encrypted at rest (AES-256)
- [ ] Password hashing (bcrypt 10+ rounds ou Argon2id)
- [ ] No secrets in logs
```

### A03 - Injection
```typescript
// SECURISE - Prisma parametre
const user = await prisma.user.findFirst({
  where: { email: userInput }
});

// DANGEREUX - SQL brut
const user = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = '${userInput}'
`;
```

### A04 - Insecure Design
```typescript
// Security by Design
- [ ] Threat modeling effectue
- [ ] Validation cote serveur TOUJOURS
- [ ] Rate limiting sur endpoints sensibles
- [ ] Input validation avec class-validator
```

### A05 - Security Misconfiguration
```typescript
// Configuration securisee
- [ ] Helmet headers actives
- [ ] CORS configure strictement
- [ ] Debug mode desactive en production
- [ ] Error messages generiques
- [ ] Remove X-Powered-By header
```

### A06 - Vulnerable Components
```typescript
// Audit regulier
npm audit --audit-level=critical
npm outdated
// Verifier CVE sur snyk.io
```

### A07 - Identification & Authentication Failures
```typescript
// Checklist
- [ ] JWT avec expiration courte (15min)
- [ ] Refresh token rotation
- [ ] Brute force protection (rate limiting)
- [ ] MFA pour comptes sensibles
- [ ] Password policy forte
```

### A08 - Software & Data Integrity Failures
```typescript
// Verifications
- [ ] SRI (Subresource Integrity) pour CDN
- [ ] Package-lock.json versionne
- [ ] Signature des images Docker
- [ ] CI/CD pipeline securise
```

### A09 - Security Logging & Monitoring Failures
```typescript
// Logging obligatoire
- [ ] Echecs d'authentification logues
- [ ] Actions admin logues
- [ ] Alertes sur activites suspectes
- [ ] Logs centralises (ELK/Loki)
```

### A10 - Server-Side Request Forgery (SSRF)
```typescript
// Protection
- [ ] Whitelist des URLs autorisees
- [ ] Validation stricte des inputs URL
- [ ] Bloquer acces metadata cloud (169.254.169.254)
- [ ] Pas de redirections non validees
```

---

## Comptes Partages et Tracabilite

```
+-----------------------------------------------------------------+
|          RISQUE: COMPTES PARTAGES                               |
+-----------------------------------------------------------------+
|                                                                  |
|  PROBLEMES                                                       |
|  +-- Pas d'imputabilite (qui a fait quoi?)                      |
|  +-- Impossible de revoquer un seul utilisateur                 |
|  +-- MFA inutile si credentials partages                        |
|  +-- Audit logs non exploitables                                |
|  +-- Non-conformite RGPD (tracabilite requise)                  |
|                                                                  |
|  SCENARIOS COURANTS                                              |
|  +-- "Compte admin" partage entre developpeurs                  |
|  +-- Compte de service utilise manuellement                     |
|  +-- Credentials dans documentation/wiki                        |
|  +-- "Compte de test" utilise en production                     |
|                                                                  |
+-----------------------------------------------------------------+
```

### Checklist Anti-Partage de Comptes

```
+-----------------------------------------------------------------+
|          CHECKLIST COMPTES & TRACABILITE                        |
+-----------------------------------------------------------------+
|                                                                  |
|  PRINCIPE: 1 COMPTE = 1 PERSONNE                                |
|                                                                  |
|  PREVENTION TECHNIQUE                                            |
|  [ ] MFA obligatoire pour tous les comptes admin                |
|  [ ] Session unique (deconnexion si login ailleurs)             |
|  [ ] Detection connexions simultanees -> alerte                 |
|  [ ] IP/Device fingerprinting                                   |
|  [ ] Expiration session courte pour comptes sensibles           |
|                                                                  |
|  AUDIT & TRACABILITE                                            |
|  [ ] Toutes actions admin loguees avec userId                   |
|  [ ] Logs non modifiables (append-only)                         |
|  [ ] Retention logs suffisante (RGPD: duree justifiee)          |
|  [ ] Alertes sur actions sensibles (delete, export, etc.)       |
|                                                                  |
|  COMPTES DE SERVICE                                              |
|  [ ] Comptes de service != comptes humains                      |
|  [ ] Pas de login interactif pour comptes de service            |
|  [ ] Rotation automatique des credentials                       |
|  [ ] Scope minimal (principe du moindre privilege)              |
|                                                                  |
|  SENSIBILISATION                                                 |
|  [ ] Formation utilisateurs privilegies                         |
|  [ ] Politique de securite signee                               |
|  [ ] Sanctions en cas de partage (mention dans contrat)         |
|                                                                  |
+-----------------------------------------------------------------+
```

### Implementation NestJS: Detection Sessions Multiples

```typescript
// Guard pour detecter les sessions simultanees
@Injectable()
export class SingleSessionGuard implements CanActivate {
  constructor(
    private readonly redis: RedisService,
    private readonly logger: Logger,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const currentSessionId = request.headers['x-session-id'];

    // Recuperer la session active en Redis
    const activeSessionId = await this.redis.get(`user:${user.id}:session`);

    if (activeSessionId && activeSessionId !== currentSessionId) {
      // Alerte: tentative de connexion simultanee
      this.logger.warn({
        event: 'CONCURRENT_SESSION_DETECTED',
        userId: user.id,
        activeSession: activeSessionId,
        attemptedSession: currentSessionId,
        ip: request.ip,
        userAgent: request.headers['user-agent'],
      });

      // Option 1: Bloquer la nouvelle session
      throw new ForbiddenException('Session already active on another device');

      // Option 2: Invalider l'ancienne session (decommenter si prefere)
      // await this.redis.set(`user:${user.id}:session`, currentSessionId);
      // await this.notifyOldSession(user.id, activeSessionId);
    }

    return true;
  }
}

// Service d'audit des actions admin
@Injectable()
export class AuditService {
  async logAdminAction(
    userId: string,
    action: string,
    resource: string,
    details: Record<string, any>,
    request: Request,
  ): Promise<void> {
    const auditEntry = {
      timestamp: new Date().toISOString(),
      userId,
      action,
      resource,
      details,
      metadata: {
        ip: request.ip,
        userAgent: request.headers['user-agent'],
        sessionId: request.headers['x-session-id'],
      },
    };

    // Log immutable (append-only)
    await this.prisma.auditLog.create({
      data: auditEntry,
    });

    // Alerte si action sensible
    if (['DELETE', 'EXPORT', 'BULK_UPDATE'].includes(action)) {
      await this.alertService.notifySecurityTeam({
        type: 'SENSITIVE_ACTION',
        ...auditEntry,
      });
    }
  }
}
```

---

## Checklist Securite Node.js/NestJS

```
+-----------------------------------------------------------------+
|              SECURITE NODE.JS / NESTJS                          |
+-----------------------------------------------------------------+
|                                                                  |
|  INJECTION PREVENTION                                            |
|  [ ] Prisma/TypeORM parametre (pas de SQL brut)                 |
|  [ ] class-validator sur tous les DTOs                          |
|  [ ] class-transformer pour sanitization                        |
|  [ ] Pas de eval(), Function(), vm.runInContext()               |
|                                                                  |
|  AUTHENTIFICATION                                                |
|  [ ] bcrypt >= 10 rounds ou Argon2id                            |
|  [ ] JWT secret >= 256 bits                                     |
|  [ ] Access token <= 15 minutes                                 |
|  [ ] Refresh token rotation                                     |
|  [ ] Rate limiting (@nestjs/throttler)                          |
|                                                                  |
|  HEADERS SECURITE                                                |
|  [ ] Helmet middleware active                                   |
|  [ ] CORS strict (origins whitelist)                            |
|  [ ] X-Content-Type-Options: nosniff                            |
|  [ ] X-Frame-Options: DENY                                      |
|                                                                  |
|  PROTOTYPE POLLUTION                                             |
|  [ ] Object.freeze sur prototypes sensibles                     |
|  [ ] Validation JSON stricte                                    |
|  [ ] Pas de merge recursif non securise                         |
|                                                                  |
|  FILE UPLOAD                                                     |
|  [ ] Multer avec limits (fileSize, files)                       |
|  [ ] Validation MIME type cote serveur                          |
|  [ ] Stockage hors webroot                                      |
|  [ ] Renommage fichiers (UUID)                                  |
|                                                                  |
|  LOGGING & MONITORING                                            |
|  [ ] Architect/Pino configure                                     |
|  [ ] Pas de secrets dans les logs                               |
|  [ ] Audit trail pour actions sensibles                         |
|  [ ] Alertes sur erreurs auth repetees                          |
|                                                                  |
+-----------------------------------------------------------------+
```

### Configuration NestJS Securisee

```typescript
// main.ts - Configuration securisee NestJS
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Helmet pour headers securite
  app.use(helmet());

  // CORS strict
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || [],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  });

  // Validation globale
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,           // Strip properties non decorees
    forbidNonWhitelisted: true, // Erreur si proprietes inconnues
    transform: true,           // Auto-transform types
    transformOptions: {
      enableImplicitConversion: false, // Pas de conversion implicite
    },
  }));

  // Prefixe API versionne
  app.setGlobalPrefix('api/v1');

  await app.listen(process.env.PORT || 3000);
}
```

---

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Node.js Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html)
- [OWASP NodeGoat](https://owasp.org/www-project-node.js-goat/)
