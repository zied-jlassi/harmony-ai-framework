# Complete Flow: "Integrate an authentication module"

> **🌐 Language:** English · [Français](../fr/examples/FLOW-AUTHENTICATION-MODULE.md)

> Example walkthrough with the centralized knowledge model.

---

## User Request

```
USER: "j'ai besoin d'intégrer un module d'authentification"
```

---

## Step 1: Guardian - Intent Detection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  🚦 GUARDIAN: Détection Intent                                              │
│  ─────────────────────────────                                              │
│  Keywords: "authentification" → Intent: SECURITY + IMPLEMENT                │
│  Profile détecté: nestjs (depuis package.json)                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 2: Profile Loader - Loading Centralized Knowledge

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  📂 PROFILE LOADER: Chargement Knowledge Centralisé                         │
│  ──────────────────────────────────────────────────                         │
│                                                                             │
│  KNOWLEDGE CENTRALISÉ (framework):                                          │
│     └─ knowledge/frameworks/nestjs/architecture.md                          │
│     └─ knowledge/domains/security/owasp-top10.md                            │
│     └─ knowledge/shared/patterns/api-design-principles.md                   │
│                                                                             │
│  OVERRIDE LOCAL (équipe - .harmony/local/):                                 │
│     └─ .harmony/local/profiles/backend/nestjs/knowledge/conventions.md     │
│     └─ .harmony/local/profiles/backend/nestjs/knowledge/experience/        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Step 3: Sentinel - Memory Check

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

## Step 4: Context7 - Fetch Official Docs (On-Demand)

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

## Step 5: Merged Context

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

## Step 6: Guided Development

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

## Generated Code

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

## Summary

| Step | Source | Contribution |
|-------|--------|--------|
| 1. Detection | Guardian | SECURITY intent detected |
| 2. Conventions | Profile (Level 1+2) | Standards + project specifics |
| 3. Errors | Sentinel (Level 3) | "Do not hardcode JWT_SECRET" |
| 4. Docs | Context7 | Fresh official NestJS pattern |
| 5. Code | Claude | Intelligent fusion of the 3 sources |

---

## Benefits

- **Correct code on the first try**
- **Compliant with industry standards**
- **Respects project conventions**
- **Avoids past mistakes**
- **Always up-to-date docs (Context7)**

---

*Example documented for the Harmony Framework - Centralized Knowledge Model*
