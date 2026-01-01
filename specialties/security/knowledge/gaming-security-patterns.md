# Gaming Security Patterns

> Patterns de sécurité spécifiques à la plateforme de jeux éducatifs pour enfants

## Vue d'ensemble

Ce document définit les patterns de sécurité obligatoires pour toute implémentation sur la plateforme Gaming. La protection des données des enfants est notre priorité absolue.

---

## 1. Authentication Patterns

### 1.1 PlayerGuard Pattern

```typescript
// src/infrastructure/guards/player.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class PlayerGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);

    if (!token) return false;

    try {
      const payload = await this.jwtService.verifyAsync(token);
      // Vérifier que c'est bien un player (enfant ou parent)
      if (!payload.playerId && !payload.familyAccountId) {
        return false;
      }
      request.user = payload;
      return true;
    } catch {
      return false;
    }
  }
}
```

### 1.2 FamilyGuard Pattern

```typescript
// src/infrastructure/guards/family.guard.ts
@Injectable()
export class FamilyGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private familyService: FamilyService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const playerId = request.params.playerId || request.body.playerId;
    const familyAccountId = request.user.familyAccountId;

    // Vérifier que le joueur appartient à la famille
    const isFamily = await this.familyService.isPlayerInFamily(
      playerId,
      familyAccountId
    );

    return isFamily;
  }
}
```

### 1.3 ParentOnlyGuard Pattern

```typescript
// Pour les actions réservées aux parents (paramètres, achats, etc.)
@Injectable()
export class ParentOnlyGuard implements CanActivate {
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    return request.user.role === 'PARENT';
  }
}
```

---

## 2. Data Protection Patterns

### 2.1 Child Data Encryption

```typescript
// Données sensibles enfants chiffrées au repos
const ENCRYPTED_FIELDS = [
  'firstName',
  'lastName',
  'birthDate',
  'avatar'
];

// Utiliser AES-256-GCM
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

export class ChildDataEncryption {
  private readonly algorithm = 'aes-256-gcm';
  private readonly key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');

  encrypt(data: string): EncryptedData {
    const iv = randomBytes(16);
    const cipher = createCipheriv(this.algorithm, this.key, iv);
    let encrypted = cipher.update(data, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag();

    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }
}
```

### 2.2 Data Minimization Pattern

```typescript
// Ne stocker que le minimum nécessaire
interface MinimalPlayerData {
  id: string;           // UUID, pas d'ID séquentiel
  displayName: string;  // Pseudo, pas le vrai nom
  ageGroup: AgeGroup;   // Tranche d'âge, pas date exacte
  createdAt: Date;
}

// Éviter de stocker
interface NEVER_STORE {
  exactBirthDate: Date;     // Stocker ageGroup à la place
  fullName: string;         // Stocker displayName à la place
  locationDetails: string;  // JAMAIS de géolocalisation
  photos: string;           // Seulement avatars prédéfinis
}
```

### 2.3 Score Anonymization Pattern

```typescript
// Leaderboards publics avec données anonymisées
interface PublicLeaderboardEntry {
  rank: number;
  displayName: string;    // "Leo***" ou "Joueur_12345"
  score: number;
  ageGroup: AgeGroup;     // Pour catégories de classement
  // PAS de playerId, PAS d'informations identifiantes
}

// Classements famille (privés)
interface FamilyLeaderboardEntry {
  playerId: string;       // OK car restreint à la famille
  firstName: string;      // OK car famille
  score: number;
}
```

---

## 3. Input Validation Patterns

### 3.1 Child Content Filter

```typescript
// Filtrer tout contenu généré par les enfants
export class ChildContentFilter {
  private readonly bannedPatterns = [
    /\b(email|mail|@)\b/i,
    /\b\d{10}\b/,  // Numéros de téléphone
    /\b(adresse|rue|avenue)\b/i,
    // Mots inappropriés (liste complète dans config)
  ];

  filter(content: string): FilterResult {
    for (const pattern of this.bannedPatterns) {
      if (pattern.test(content)) {
        return {
          safe: false,
          reason: 'POTENTIAL_PII',
          sanitized: this.sanitize(content)
        };
      }
    }
    return { safe: true, sanitized: content };
  }

  private sanitize(content: string): string {
    return content
      .replace(/\d{10}/g, '***')
      .replace(/@\S+/g, '***')
      .slice(0, 50); // Limite longueur
  }
}
```

### 3.2 Game Input Validation

```typescript
// Validation stricte des entrées de jeu
export class GameInputValidator {
  validateScore(score: number, gameConfig: GameConfig): boolean {
    // Score dans les limites théoriques du jeu
    return score >= 0 && score <= gameConfig.maxPossibleScore;
  }

  validateAnswer(answer: string, questionType: QuestionType): boolean {
    const maxLength = {
      MULTIPLE_CHOICE: 1,    // A, B, C, D
      SHORT_TEXT: 100,
      NUMBER: 20
    };

    return answer.length <= maxLength[questionType];
  }

  validateGameAction(action: GameAction): boolean {
    // Rate limiting: max 10 actions/seconde
    // Vérifier cohérence temporelle
    // Détecter patterns de triche
  }
}
```

---

## 4. Session Security Patterns

### 4.1 Child Session Management

```typescript
// Sessions enfants avec contrôles parentaux
interface ChildSession {
  playerId: string;
  familyAccountId: string;
  startedAt: Date;
  maxDuration: number;      // En minutes, configuré par parent
  warningAt: number;        // 5 min avant fin
  expiresAt: Date;
}

// Redis storage avec TTL automatique
await redis.setex(
  `session:player:${playerId}`,
  maxDuration * 60,  // TTL en secondes
  JSON.stringify(session)
);
```

### 4.2 Parent PIN Verification

```typescript
// PIN pour accès sections parents depuis device enfant
export class ParentPinService {
  async verifyPin(familyAccountId: string, pin: string): Promise<boolean> {
    const stored = await this.redis.get(`pin:${familyAccountId}`);
    const attempts = await this.redis.get(`pin:attempts:${familyAccountId}`);

    // Blocage après 5 tentatives
    if (parseInt(attempts) >= 5) {
      throw new TooManyAttemptsError();
    }

    const isValid = await argon2.verify(stored, pin);

    if (!isValid) {
      await this.redis.incr(`pin:attempts:${familyAccountId}`);
      await this.redis.expire(`pin:attempts:${familyAccountId}`, 3600);
    } else {
      await this.redis.del(`pin:attempts:${familyAccountId}`);
    }

    return isValid;
  }
}
```

---

## 5. API Security Patterns

### 5.1 Rate Limiting per Player

```typescript
// Limites différentes selon le type d'utilisateur
const RATE_LIMITS = {
  child: {
    gameActions: '100/minute',
    scoreSubmit: '10/minute',
    leaderboard: '30/minute'
  },
  parent: {
    settings: '20/minute',
    reports: '50/minute',
    purchase: '5/minute'
  }
};

@UseGuards(PlayerGuard)
@Throttle(RATE_LIMITS.child.scoreSubmit)
@Post('scores')
async submitScore(@Body() dto: SubmitScoreDto) {}
```

### 5.2 CORS Configuration

```typescript
// Configuration CORS stricte
const corsOptions = {
  origin: [
    'https://gaming.enfant-app.fr',
    'https://app.enfant-app.fr',
    // Pas de localhost en production!
    ...(process.env.NODE_ENV === 'development'
      ? ['http://localhost:3000']
      : [])
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Authorization', 'Content-Type'],
  credentials: true,
  maxAge: 86400  // Cache preflight 24h
};
```

---

## 6. Audit & Logging Patterns

### 6.1 Security Event Logging

```typescript
// Log tous les événements de sécurité
interface SecurityEvent {
  timestamp: Date;
  eventType: SecurityEventType;
  actorId: string;           // Qui a fait l'action
  actorType: 'PLAYER' | 'PARENT' | 'SYSTEM';
  targetId?: string;         // Sur qui/quoi
  action: string;
  result: 'SUCCESS' | 'FAILURE';
  metadata: Record<string, unknown>;
  ip: string;                // Pour détection abus
}

enum SecurityEventType {
  LOGIN_SUCCESS,
  LOGIN_FAILURE,
  PIN_ATTEMPT,
  PERMISSION_DENIED,
  DATA_ACCESS,
  SETTINGS_CHANGE,
  SUSPICIOUS_ACTIVITY
}
```

### 6.2 Child Activity Audit

```typescript
// Audit trail pour conformité RGPD
interface ChildActivityLog {
  playerId: string;
  familyAccountId: string;
  sessionId: string;
  activities: ActivityEntry[];
  // Retention: 90 jours puis anonymisation
}

interface ActivityEntry {
  timestamp: Date;
  type: 'GAME_START' | 'GAME_END' | 'SCORE' | 'BADGE';
  gameId?: string;
  duration?: number;
  // PAS de contenu détaillé, juste métriques
}
```

---

## Checklist de Validation

Avant chaque merge, vérifier:

- [ ] Authentification: Guards appropriés sur tous les endpoints
- [ ] Autorisation: Vérification family membership pour accès données enfant
- [ ] Input: Validation et sanitization de toutes les entrées
- [ ] Output: Pas de données sensibles dans les réponses publiques
- [ ] Sessions: TTL configuré, timeout parental respecté
- [ ] Logging: Événements de sécurité loggés
- [ ] CORS: Origines autorisées vérifiées
- [ ] Rate Limiting: Limites appropriées par endpoint

---

*Gaming Security Patterns - BMAD Gaming Platform*
