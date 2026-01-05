# OWASP Top 10 - Gaming Platform Checklist

> Checklist de sécurité OWASP adaptée à la plateforme de jeux éducatifs

## A01:2021 - Broken Access Control

### Risques spécifiques Gaming
- Enfant accédant aux paramètres parent
- Parent accédant aux données d'une autre famille
- Manipulation des scores d'autres joueurs

### Contrôles obligatoires

```
[x] PlayerGuard sur tous les endpoints /players/*
[x] FamilyGuard pour accès aux données player
[x] ParentOnlyGuard pour /settings/*, /reports/*
[x] Vérification playerId dans JWT vs params
[x] Pas d'ID séquentiels (utiliser UUID)
[x] Tests E2E pour chaque scénario d'accès
```

### Tests à implémenter

```typescript
describe('Access Control', () => {
  it('should prevent child accessing parent settings', async () => {
    const childToken = await getChildToken();
    await request(app)
      .get('/api/settings/parental')
      .set('Authorization', `Bearer ${childToken}`)
      .expect(403);
  });

  it('should prevent accessing other family data', async () => {
    const family1Token = await getFamilyToken(1);
    const family2PlayerId = await getPlayerId(2);
    await request(app)
      .get(`/api/players/${family2PlayerId}/scores`)
      .set('Authorization', `Bearer ${family1Token}`)
      .expect(403);
  });
});
```

---

## A02:2021 - Cryptographic Failures

### Risques spécifiques Gaming
- Données enfants non chiffrées
- Mots de passe en clair
- Tokens JWT faibles

### Contrôles obligatoires

```
[x] AES-256-GCM pour données enfants au repos
[x] Argon2id pour mots de passe (cost factor 3)
[x] JWT avec RS256 (pas HS256 en production)
[x] TLS 1.3 obligatoire
[x] Rotation des clés tous les 90 jours
[x] Pas de secrets dans le code (env vars)
```

### Configuration minimale

```typescript
// jwt.config.ts
const jwtConfig = {
  algorithm: 'RS256',
  expiresIn: '1h',        // Access token
  refreshExpiresIn: '7d', // Refresh token
  issuer: 'gaming.enfant-app.fr'
};

// encryption.config.ts
const encryptionConfig = {
  algorithm: 'aes-256-gcm',
  keyLength: 32,
  ivLength: 16,
  authTagLength: 16
};
```

---

## A03:2021 - Injection

### Risques spécifiques Gaming
- SQL injection via scores
- NoSQL injection via filtres
- XSS via noms de joueurs

### Contrôles obligatoires

```
[x] Prisma ORM (queries paramétrées automatiques)
[x] Validation DTO avec class-validator
[x] Sanitization HTML sur tous les inputs texte
[x] CSP headers configurés
[x] Pas de eval() ou new Function()
```

### Validation patterns

```typescript
// DTOs avec validation stricte
import { IsString, IsInt, Min, Max, Matches } from 'class-validator';

export class SubmitScoreDto {
  @IsString()
  @Matches(/^[a-f0-9-]{36}$/) // UUID format
  gameId: string;

  @IsInt()
  @Min(0)
  @Max(999999)
  score: number;

  @IsInt()
  @Min(1)
  @Max(3600) // Max 1 heure
  duration: number;
}

export class UpdateDisplayNameDto {
  @IsString()
  @Matches(/^[a-zA-Z0-9À-ÿ\s]{2,20}$/) // Alphanumeric + accents
  displayName: string;
}
```

---

## A04:2021 - Insecure Design

### Risques spécifiques Gaming
- Pas de rate limiting sur scores
- Possibilité de triche
- Exposition de données via API

### Contrôles obligatoires

```
[x] Rate limiting par endpoint et par user
[x] Anti-cheat: validation côté serveur
[x] Pagination obligatoire (max 100)
[x] Pas de données sensibles dans réponses
[x] Timeout sessions enfants
```

### Anti-cheat basique

```typescript
// Validation cohérence score vs temps de jeu
export class AntiCheatValidator {
  validateScoreSubmission(dto: SubmitScoreDto, game: Game): boolean {
    // Score maximum théorique pour le temps joué
    const maxPossibleScore = game.pointsPerSecond * dto.duration;
    if (dto.score > maxPossibleScore * 1.1) { // 10% marge
      this.flagSuspicious(dto, 'SCORE_TOO_HIGH');
      return false;
    }

    // Temps minimum pour ce score
    const minTimeForScore = dto.score / game.maxPointsPerSecond;
    if (dto.duration < minTimeForScore * 0.9) {
      this.flagSuspicious(dto, 'TIME_TOO_SHORT');
      return false;
    }

    return true;
  }
}
```

---

## A05:2021 - Security Misconfiguration

### Risques spécifiques Gaming
- Debug mode en production
- Headers de sécurité manquants
- CORS trop permissif

### Contrôles obligatoires

```
[x] NODE_ENV=production en prod
[x] Helmet.js configuré
[x] CORS whitelist strict
[x] Pas de stack traces en prod
[x] Audit npm régulier
```

### Configuration Helmet

```typescript
// main.ts
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https://cdn.enfant-app.fr"],
      mediaSrc: ["'self'", "https://audio.enfant-app.fr"],
      connectSrc: ["'self'", "https://api.enfant-app.fr"],
      frameSrc: ["'none'"],
      objectSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
}));
```

---

## A06:2021 - Vulnerable Components

### Risques spécifiques Gaming
- Dépendances npm vulnérables
- Versions obsolètes de frameworks

### Contrôles obligatoires

```
[x] npm audit dans CI/CD
[x] Dependabot activé
[x] Pas de dépendances deprecated
[x] Lock file (package-lock.json) versionné
[x] Review des nouvelles dépendances
```

### GitHub Actions

```yaml
# .github/workflows/security.yml
security-audit:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - run: npm ci
    - run: npm audit --audit-level=high
    - run: npx snyk test
```

---

## A07:2021 - Auth Failures

### Risques spécifiques Gaming
- Brute force PIN parental
- Session hijacking
- Token leakage

### Contrôles obligatoires

```
[x] Lockout après 5 tentatives PIN
[x] Refresh token rotation
[x] Logout invalide tous les tokens
[x] Tokens liés à device fingerprint
[x] Session timeout configurable
```

---

## A08:2021 - Data Integrity Failures

### Risques spécifiques Gaming
- Manipulation des scores
- Modification des badges
- Falsification progression

### Contrôles obligatoires

```
[x] Scores calculés côté serveur uniquement
[x] Badges attribués par événements serveur
[x] Logs d'audit pour toute modification
[x] Intégrité vérifiable (hash)
```

---

## A09:2021 - Logging Failures

### Risques spécifiques Gaming
- Pas de trace des accès données enfants
- Impossible de détecter les abus

### Contrôles obligatoires

```
[x] Log tous les événements sécurité
[x] Log accès aux données enfants
[x] Rétention 90 jours minimum (RGPD)
[x] Alertes sur patterns suspects
[x] Logs non modifiables
```

---

## A10:2021 - SSRF

### Risques spécifiques Gaming
- Intégration TTS externe
- Webhooks parents
- CDN médias

### Contrôles obligatoires

```
[x] Whitelist domaines externes
[x] Pas d'URL user-controlled pour fetch
[x] Validation URLs webhooks
[x] Timeout sur requêtes externes
```

---

## Checklist Pré-Release

```
[ ] Tous les contrôles A01-A10 vérifiés
[ ] Penetration test effectué
[ ] npm audit clean (0 high/critical)
[ ] RGPD compliance validée
[ ] Backup/restore testé
[ ] Monitoring sécurité actif
[ ] Plan incident à jour
```

---

*OWASP Gaming Checklist - BMAD Gaming Platform*
