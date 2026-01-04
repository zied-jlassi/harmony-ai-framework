# Flow Complet: "Intégrer un module d'authentification"

> Exemple de déroulement avec le modèle hybride 3 niveaux.

---

## Requête Utilisateur

```
USER: "j'ai besoin d'intégrer un module d'authentification"
```

---

## Étape 1: Guardian - Détection Intent

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🚦 GUARDIAN: Détection Intent                                              │
│  ─────────────────────────────                                              │
│  Keywords: "authentification" → Intent: SECURITY + IMPLEMENT                │
│  Profile détecté: nestjs (depuis package.json)                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Étape 2: Profile Loader - Chargement Conditionnel

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  📂 PROFILE LOADER: Chargement 3 Niveaux                                    │
│  ───────────────────────────────────────                                    │
│                                                                             │
│  NIVEAU 1: INDUSTRY STANDARDS (toujours dispo)                              │
│     └─ knowledge/industry-standards/architecture.md                         │
│     └─ knowledge/industry-standards/security.md                             │
│                                                                             │
│  NIVEAU 2: PROJECT CONVENTIONS (si existent)                                │
│     └─ knowledge/project-conventions/api-patterns.md                        │
│     └─ knowledge/project-conventions/security.md                            │
│                                                                             │
│  NIVEAU 3: EXPERIENCE (auto depuis Sentinel)                                │
│     └─ knowledge/experience/pitfalls.md                                     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Étape 3: Sentinel - Vérification Mémoire

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🛡️ SENTINEL: Vérification Mémoire                                          │
│  ─────────────────────────────────                                          │
│                                                                             │
│  Recherche dans error-journal.json:                                         │
│  └─ Tags: ["auth", "jwt", "guard", "security"]                              │
│                                                                             │
│  ⚠️ ALERTE: ERR-042 trouvé                                                  │
│  "JWT secret hardcodé causait fuite en prod - utiliser ConfigService"       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Étape 4: Context7 - Fetch Docs Officielles (On-Demand)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🔍 CONTEXT7: Fetch Docs Officielles (on-demand)                            │
│  ───────────────────────────────────────────────                            │
│                                                                             │
│  Query: "NestJS authentication JWT passport guard"                          │
│  Library: /nestjs/docs.nestjs.com                                           │
│                                                                             │
│  → Récupère docs officielles NestJS 11.x                                    │
│  → Patterns: JwtModule, PassportStrategy, AuthGuard                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Étape 5: Contexte Fusionné

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🧠 CONTEXTE FUSIONNÉ → Claude Code                                         │
│  ───────────────────────────────────                                        │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │ DOCS OFFICIELLES│  │ CONVENTIONS     │  │ EXPÉRIENCE      │             │
│  │ (Context7)      │  │ (Profile)       │  │ (Sentinel)      │             │
│  ├─────────────────┤  ├─────────────────┤  ├─────────────────┤             │
│  │ JwtModule       │  │ POST pour auth  │  │ ⚠️ Pas hardcoder │             │
│  │ PassportStrategy│  │ Response wrapper│  │   JWT_SECRET    │             │
│  │ @UseGuards()    │  │ Notre AuthGuard │  │                 │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Étape 6: Développement Guidé

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  💻 DÉVELOPPEMENT GUIDÉ                                                     │
│  ──────────────────────                                                     │
│                                                                             │
│  Claude génère le code avec:                                                │
│  ✓ Pattern officiel NestJS (Context7)                                       │
│  ✓ Conventions projet appliquées (Profile)                                  │
│  ✓ Erreurs passées évitées (Sentinel)                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Code Généré

```typescript
// auth.module.ts
// ✅ Pattern officiel (Context7)
// ✅ Convention projet (Profile)
// ✅ Erreur évitée (Sentinel)

@Module({
  imports: [
    // ✅ Context7: Pattern officiel JwtModule
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      // ✅ Sentinel: ERR-042 évité - pas de secret hardcodé
      useFactory: (config: ConfigService) => ({
        secret: config.get('JWT_SECRET'),  // ← Sentinel a prévenu
        signOptions: { expiresIn: '1h' },
      }),
    }),
    PassportModule,
  ],
  providers: [AuthService, JwtStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

```typescript
// auth.controller.ts
@Controller('auth')
export class AuthController {
  // ✅ Convention projet: POST pour login (pas GET)
  @Post('login')
  async login(@Body() loginDto: LoginDto) {
    // ✅ Convention projet: Response wrapper
    return {
      data: await this.authService.login(loginDto),
      timestamp: new Date().toISOString(),
    };
  }
}
```

---

## Résumé

| Étape | Source | Apport |
|-------|--------|--------|
| 1. Détection | Guardian | Intent SECURITY détecté |
| 2. Conventions | Profile (Niveau 1+2) | Standards + spécificités projet |
| 3. Erreurs | Sentinel (Niveau 3) | "Ne pas hardcoder JWT_SECRET" |
| 4. Docs | Context7 | Pattern officiel NestJS frais |
| 5. Code | Claude | Fusion intelligente des 3 sources |

---

## Bénéfices

- **Code correct dès le premier essai**
- **Conforme aux standards industrie**
- **Respecte les conventions projet**
- **Évite les erreurs passées**
- **Docs toujours à jour (Context7)**

---

*Exemple documenté pour Harmony Framework - Modèle Hybride 3 Niveaux*
