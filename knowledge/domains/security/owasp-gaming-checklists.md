# OWASP Checklists - Gaming Educational Platform

> Checklists OWASP adaptees aux jeux educatifs pour enfants

---

## OWASP Top 10 (2021/2024) - Contexte Gaming Enfants

### A01 - Broken Access Control (Critique)

```typescript
// OBLIGATOIRE - Guards sur TOUS les endpoints
@UseGuards(JwtAuthGuard, RolesGuard, SchoolGuard, AgeGuard)
@Roles(UserRole.STUDENT, UserRole.TEACHER)
@Controller('games')
export class GamesController {
  // Verification supplementaire: l'enfant a-t-il acces a ce jeu?
  @Get(':gameId/play')
  async playGame(
    @Param('gameId') gameId: string,
    @CurrentUser() user: User,
  ) {
    // Verifier que le jeu est approprie pour l'age
    await this.gameService.validateAgeAccess(gameId, user.birthDate);
    // Verifier que l'ecole a acces a ce jeu
    await this.gameService.validateSchoolAccess(gameId, user.schoolId);
  }
}
```

**Checklist Gaming:**
- [ ] Guards sur tous les endpoints de jeu
- [ ] Verification age pour chaque jeu
- [ ] Verification ecole/classe pour acces
- [ ] Pas d'acces entre eleves de differentes ecoles
- [ ] Scores visibles uniquement dans sa classe/ecole

### A02 - Cryptographic Failures

```typescript
// Checklist Crypto Gaming
- [ ] HTTPS obligatoire (TLS 1.3)
- [ ] Donnees enfants chiffrees au repos (AES-256)
- [ ] Pas de donnees personnelles dans localStorage
- [ ] JWT avec secret >= 256 bits
- [ ] Pas de secrets dans le code frontend
```

**Specifique Gaming:**
```typescript
// NE JAMAIS stocker en clair:
// - Scores avec identifiant enfant
// - Progression avec nom/prenom
// - Statistiques nominatives

// CHIFFRER:
const encryptedProgress = encrypt({
  level: 5,
  score: 1500,
  // PAS de donnees personnelles ici
}, ENCRYPTION_KEY);
```

### A03 - Injection

```typescript
// SECURISE - Prisma parametre
const scores = await prisma.score.findMany({
  where: {
    gameId: userInput, // Prisma protege automatiquement
  },
});

// DANGEREUX - NE JAMAIS FAIRE
const scores = await prisma.$queryRaw`
  SELECT * FROM scores WHERE game_id = '${userInput}'
`; // INJECTION POSSIBLE!

// Validation input jeu
class SubmitAnswerDto {
  @IsUUID()
  gameSessionId: string;

  @IsString()
  @MaxLength(100)
  @Matches(/^[a-zA-Z0-9\s]+$/) // Caracteres surs uniquement
  answer: string;
}
```

### A04 - Insecure Design

```
+---------------------------------------------------------------+
|          SECURITY BY DESIGN - GAMING ENFANTS                   |
+---------------------------------------------------------------+
|                                                                |
|  PRINCIPES                                                     |
|  +-- Defense en profondeur                                    |
|  +-- Moindre privilege par defaut                             |
|  +-- Validation a chaque couche                               |
|  +-- Fail-safe (echec securise)                               |
|                                                                |
|  SPECIFIQUE ENFANTS                                            |
|  +-- Pas de chat entre enfants (ou modere)                    |
|  +-- Pas de contenu genere par utilisateurs                   |
|  +-- Pas de liens vers l'exterieur                            |
|  +-- Pas de publicite                                         |
|  +-- Pas de tracking tiers                                    |
|                                                                |
+---------------------------------------------------------------+
```

### A05 - Security Misconfiguration

```typescript
// Configuration securisee NestJS Gaming
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Headers securite
  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'"], // Pas de scripts externes
        imgSrc: ["'self'", 'data:', 'blob:'], // Images locales uniquement
        connectSrc: ["'self'"], // Pas de connexions externes
        frameSrc: ["'none'"], // Pas d'iframes
      },
    },
  }));

  // CORS strict - uniquement nos domaines
  app.enableCors({
    origin: [
      'https://app.gaming-edu.com',
      'https://admin.gaming-edu.com',
    ],
    credentials: true,
  });

  // Pas d'informations de version
  app.getHttpAdapter().getInstance().disable('x-powered-by');
}
```

### A06 - Vulnerable Components

```bash
# Audit regulier OBLIGATOIRE
npm audit --audit-level=high
npm outdated

# CI/CD - Bloquer si vulnerabilites critiques
npm audit --audit-level=critical || exit 1

# Verifier CVE sur:
# - snyk.io
# - github.com/advisories
```

### A07 - Identification & Authentication Failures

```typescript
// Configuration auth gaming
const authConfig = {
  // JWT court pour enfants (session limitee)
  accessTokenExpiry: '15m',
  refreshTokenExpiry: '7d',

  // Rate limiting strict sur login
  loginAttempts: {
    max: 5,
    windowMs: 15 * 60 * 1000, // 15 minutes
    blockDuration: 60 * 60 * 1000, // 1 heure de blocage
  },

  // Pas de "remember me" pour enfants
  rememberMe: false,

  // Session unique (pas de connexion simultanee)
  singleSession: true,
};

// Validation mot de passe adapte enfants
const passwordRules = {
  minLength: 8,
  // Pas trop complexe pour les enfants
  // mais suffisamment securise
  requireUppercase: true,
  requireNumber: true,
  requireSpecial: false, // Trop difficile pour enfants
};
```

### A08 - Software & Data Integrity

```typescript
// Verification integrite des assets de jeu
const assetIntegrity = {
  // Hash de chaque asset
  'game-sprites.png': 'sha256-abc123...',
  'game-sounds.mp3': 'sha256-def456...',
};

async function loadGameAsset(assetName: string): Promise<Buffer> {
  const asset = await fetchAsset(assetName);
  const hash = crypto.createHash('sha256').update(asset).digest('hex');

  if (hash !== assetIntegrity[assetName]) {
    throw new SecurityError('Asset integrity check failed');
  }

  return asset;
}
```

### A09 - Security Logging & Monitoring

```typescript
// Logging securite gaming - SANS donnees enfants
@Injectable()
export class GameSecurityLogger {
  logSuspiciousActivity(event: SecurityEvent) {
    this.logger.warn({
      type: event.type,
      // ID anonymise, PAS de nom/prenom
      userId: hashUserId(event.userId),
      gameId: event.gameId,
      action: event.action,
      ip: event.ip,
      timestamp: new Date().toISOString(),
      // PAS de donnees personnelles
    });

    // Alerter si comportement suspect
    if (this.isHighRisk(event)) {
      this.alertSecurityTeam(event);
    }
  }

  private isHighRisk(event: SecurityEvent): boolean {
    return [
      'REPEATED_AUTH_FAILURE',
      'SCORE_MANIPULATION_ATTEMPT',
      'DATA_EXPORT_REQUEST',
      'ADMIN_ACTION',
    ].includes(event.type);
  }
}
```

### A10 - Server-Side Request Forgery (SSRF)

```typescript
// Protection SSRF - Pas de requetes vers URLs utilisateur
// Dans le contexte gaming: pas d'import d'avatars externes

// INTERDIT
async uploadAvatarFromUrl(url: string) {
  // SSRF possible!
  const image = await fetch(url);
}

// AUTORISE
async uploadAvatar(file: Express.Multer.File) {
  // Fichier uploade directement, pas d'URL
  validateImageFile(file);
  return saveAvatar(file);
}
```

---

## Checklist Securite Specifique Jeux Educatifs

```markdown
## Checklist Securite Gaming Enfants

### Authentification
- [ ] JWT avec expiration courte (15min)
- [ ] Session unique (pas multi-device)
- [ ] Rate limiting sur login (5 tentatives/15min)
- [ ] Pas de "remember me" pour comptes enfants
- [ ] Deconnexion automatique apres inactivite (30min)

### Autorisation
- [ ] Verification age pour chaque jeu
- [ ] Isolation par ecole/classe
- [ ] Pas d'acces croise entre etablissements
- [ ] Scores visibles uniquement dans son groupe

### Donnees Enfants
- [ ] Chiffrement au repos (AES-256)
- [ ] Pas de donnees dans localStorage
- [ ] Anonymisation dans les logs
- [ ] Pas d'export de donnees nominatives
- [ ] Retention limitee (fin annee scolaire)

### Communication
- [ ] Pas de chat non modere
- [ ] Pas de messages entre enfants
- [ ] Pas de contenu genere par utilisateurs
- [ ] Pas de liens externes

### Tracking
- [ ] Pas de cookies tiers
- [ ] Pas d'analytics identifiant
- [ ] Pas de publicite
- [ ] Pas de partage avec reseaux sociaux

### Interface
- [ ] Pas de liens de paiement
- [ ] Pas de dark patterns
- [ ] Actions irreversibles confirmees
- [ ] Messages adaptes a l'age
```

---

## Implementation Guards Gaming

```typescript
// guards/age.guard.ts
@Injectable()
export class AgeGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const gameId = request.params.gameId;

    const game = await this.gameService.findById(gameId);

    // Calculer age de l'enfant
    const age = this.calculateAge(user.birthDate);

    // Verifier que le jeu est adapte
    if (age < game.minAge || age > game.maxAge) {
      throw new ForbiddenException('Jeu non adapte a ton age');
    }

    return true;
  }

  private calculateAge(birthDate: Date): number {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }

    return age;
  }
}

// guards/school.guard.ts
@Injectable()
export class SchoolGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    const resourceId = request.params.id;

    // Verifier que la ressource appartient a l'ecole de l'utilisateur
    const resource = await this.getResource(resourceId);

    if (resource.schoolId !== user.schoolId) {
      throw new ForbiddenException('Acces non autorise');
    }

    return true;
  }
}
```

---

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Children Safety](https://owasp.org/www-project-mobile-app-security/)
- [COPPA Compliance](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)
- [RGPD Mineurs](https://www.cnil.fr/fr/les-droits-des-mineurs)

---

**Derniere mise a jour**: 2025-12-12
**Module**: Gaming Platform - Security
