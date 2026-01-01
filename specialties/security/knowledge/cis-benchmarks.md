# CIS Benchmarks - HTTP, Timeouts, Static Files

> Module de l'agent `/bmad:security`
> **Source**: CIS Benchmark (adapte NestJS)
> **Commandes**: `audit-http-methods`, `audit-timeouts`, `audit-static-files`

---

## Restriction des Methodes HTTP

**Contexte**: CIS Benchmark recommande de limiter les methodes HTTP aux seules necessaires.

### Checklist Methodes HTTP

```markdown
## Audit Methodes HTTP

### Verifications
- [ ] Seules GET, POST, PUT, PATCH, DELETE autorisees
- [ ] TRACE desactive (prevention XST - Cross-Site Tracing)
- [ ] OPTIONS controle (CORS)
- [ ] HEAD limite si non necessaire
- [ ] CONNECT bloque

### Configuration NestJS (Helmet)
- [ ] Helmet middleware configure
- [ ] CORS restrictif (origines whitelist)
- [ ] Headers de securite actives

### Nginx/Reverse Proxy
- [ ] Methodes filtrees au niveau proxy
- [ ] Requetes malformees rejetees
```

### Implementation NestJS

```typescript
// middleware/http-methods.middleware.ts
import { Injectable, NestMiddleware, MethodNotAllowedException } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class HttpMethodsMiddleware implements NestMiddleware {
  private readonly allowedMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'];
  private readonly blockedMethods = ['TRACE', 'TRACK', 'CONNECT'];

  use(req: Request, res: Response, next: NextFunction) {
    const method = req.method.toUpperCase();

    // Bloquer explicitement les methodes dangereuses
    if (this.blockedMethods.includes(method)) {
      throw new MethodNotAllowedException(`Method ${method} is not allowed`);
    }

    // Verifier que la methode est dans la liste autorisee
    if (!this.allowedMethods.includes(method)) {
      throw new MethodNotAllowedException(`Method ${method} is not supported`);
    }

    next();
  }
}

// main.ts - Configuration Helmet
import helmet from 'helmet';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Helmet avec configuration stricte
  app.use(helmet({
    crossOriginResourcePolicy: { policy: 'same-origin' },
    crossOriginEmbedderPolicy: true,
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
        connectSrc: ["'self'"],
        fontSrc: ["'self'"],
        objectSrc: ["'none'"],
        frameAncestors: ["'none'"],
        upgradeInsecureRequests: [],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
    noSniff: true,
    xssFilter: true,
    hidePoweredBy: true,
    frameguard: { action: 'deny' },
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  }));

  // CORS restrictif
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
    credentials: true,
    maxAge: 3600,
  });
}
```

### Configuration Nginx

```nginx
# Bloquer methodes non autorisees
if ($request_method !~ ^(GET|POST|PUT|PATCH|DELETE|OPTIONS)$) {
    return 405;
}

# Bloquer explicitement TRACE
if ($request_method = TRACE) {
    return 405;
}

# Headers de securite
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
```

---

## Timeouts Applicatifs

**Contexte**: Les bonnes pratiques recommandent des timeouts pour prevenir les attaques DoS et les connexions zombies.

### Checklist Timeouts

```markdown
## Audit Timeouts

### Session
- [ ] Timeout d'inactivite configure (< 30min recommande)
- [ ] Timeout absolu de session (< 8h recommande)
- [ ] Regeneration ID session apres login

### Requetes HTTP
- [ ] Timeout de connexion configure
- [ ] Timeout de lecture configure
- [ ] Timeout body parser limite
- [ ] Keep-alive timeout defini

### Base de donnees
- [ ] Connection timeout Prisma
- [ ] Pool timeout configure
- [ ] Statement timeout pour longues requetes

### Operations asynchrones
- [ ] Timeout sur appels externes
- [ ] Circuit breaker implemente
- [ ] Queue timeout defini
```

### Implementation NestJS

```typescript
// config/timeouts.config.ts
export const TimeoutConfig = {
  // Session
  SESSION_IDLE_TIMEOUT: 30 * 60 * 1000,      // 30 minutes
  SESSION_ABSOLUTE_TIMEOUT: 8 * 60 * 60 * 1000, // 8 heures

  // HTTP
  HTTP_TIMEOUT: 30000,         // 30 secondes
  BODY_PARSER_TIMEOUT: 10000,  // 10 secondes
  KEEP_ALIVE_TIMEOUT: 65000,   // 65 secondes (> load balancer)

  // Database
  DB_CONNECTION_TIMEOUT: 5000,  // 5 secondes
  DB_POOL_TIMEOUT: 10000,       // 10 secondes
  DB_STATEMENT_TIMEOUT: 30000,  // 30 secondes

  // External calls
  EXTERNAL_API_TIMEOUT: 10000,  // 10 secondes
};

// middleware/timeout.middleware.ts
import { Injectable, NestMiddleware, RequestTimeoutException } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { TimeoutConfig } from '../config/timeouts.config';

@Injectable()
export class TimeoutMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const timeout = setTimeout(() => {
      if (!res.headersSent) {
        throw new RequestTimeoutException('Request timeout');
      }
    }, TimeoutConfig.HTTP_TIMEOUT);

    res.on('finish', () => clearTimeout(timeout));
    res.on('close', () => clearTimeout(timeout));

    next();
  }
}

// interceptors/timeout.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler, RequestTimeoutException } from '@nestjs/common';
import { Observable, throwError, TimeoutError } from 'rxjs';
import { catchError, timeout } from 'rxjs/operators';
import { TimeoutConfig } from '../config/timeouts.config';

@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      timeout(TimeoutConfig.HTTP_TIMEOUT),
      catchError(err => {
        if (err instanceof TimeoutError) {
          return throwError(() => new RequestTimeoutException('Request timeout'));
        }
        return throwError(() => err);
      }),
    );
  }
}

// main.ts - Configuration Express
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const server = app.getHttpServer();
  server.setTimeout(TimeoutConfig.HTTP_TIMEOUT);
  server.keepAliveTimeout = TimeoutConfig.KEEP_ALIVE_TIMEOUT;
  server.headersTimeout = TimeoutConfig.KEEP_ALIVE_TIMEOUT + 1000;
}

// prisma/schema.prisma - Timeout dans connection string
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL") // ?connect_timeout=5&pool_timeout=10&statement_timeout=30000
}
```

### Guard Session Timeout

```typescript
// guards/session-timeout.guard.ts
import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { TimeoutConfig } from '../config/timeouts.config';

@Injectable()
export class SessionTimeoutGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly redis: Redis,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = request.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      throw new UnauthorizedException('No token provided');
    }

    const payload = this.jwtService.decode(token);
    const userId = payload.sub;

    // Verifier le dernier acces (timeout d'inactivite)
    const lastAccess = await this.redis.get(`user:${userId}:lastAccess`);
    const now = Date.now();

    if (lastAccess) {
      const idleTime = now - parseInt(lastAccess);
      if (idleTime > TimeoutConfig.SESSION_IDLE_TIMEOUT) {
        await this.redis.del(`user:${userId}:session`);
        throw new UnauthorizedException('Session expired due to inactivity');
      }
    }

    // Verifier le timeout absolu
    const sessionStart = await this.redis.get(`user:${userId}:sessionStart`);
    if (sessionStart) {
      const sessionDuration = now - parseInt(sessionStart);
      if (sessionDuration > TimeoutConfig.SESSION_ABSOLUTE_TIMEOUT) {
        await this.redis.del(`user:${userId}:session`);
        throw new UnauthorizedException('Session expired (maximum duration reached)');
      }
    }

    // Mettre a jour le dernier acces
    await this.redis.set(`user:${userId}:lastAccess`, now.toString());

    return true;
  }
}
```

---

## Securite des Fichiers Statiques

**Contexte**: CIS Benchmark recommande de proteger les fichiers sensibles contre l'acces direct.

### Checklist Fichiers Statiques

```markdown
## Audit Fichiers Statiques

### Configuration Serveur
- [ ] Directory listing desactive
- [ ] Fichiers .env non accessibles
- [ ] Fichiers de backup (.bak, ~) bloques
- [ ] Fichiers de config (.json, .yml) proteges
- [ ] Fichiers source (.ts, .tsx) non servis

### Headers
- [ ] X-Content-Type-Options: nosniff
- [ ] Content-Disposition correct
- [ ] Cache-Control approprie

### Uploads
- [ ] Repertoire uploads hors webroot
- [ ] Validation MIME type reel
- [ ] Renommage fichiers uploades
- [ ] Scan antivirus si applicable
```

### Configuration NestJS

```typescript
// serve-static.config.ts
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';

ServeStaticModule.forRoot({
  rootPath: join(__dirname, '..', 'public'),
  serveRoot: '/static',
  serveStaticOptions: {
    index: false,          // Pas de directory listing
    dotfiles: 'deny',      // Bloquer fichiers caches
    extensions: ['html', 'css', 'js', 'png', 'jpg', 'svg', 'ico'],
    setHeaders: (res, path) => {
      // Headers de securite
      res.setHeader('X-Content-Type-Options', 'nosniff');
      res.setHeader('X-Frame-Options', 'DENY');

      // Cache selon type de fichier
      if (path.match(/\.(js|css)$/)) {
        res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
      } else if (path.match(/\.(png|jpg|svg|ico)$/)) {
        res.setHeader('Cache-Control', 'public, max-age=86400');
      }
    },
  },
}),

// middleware/static-security.middleware.ts
import { Injectable, NestMiddleware, ForbiddenException } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class StaticSecurityMiddleware implements NestMiddleware {
  private readonly blockedPatterns = [
    /\.env$/i,
    /\.git/i,
    /\.bak$/i,
    /\.backup$/i,
    /\.old$/i,
    /~$/,
    /\.sql$/i,
    /\.log$/i,
    /\.ini$/i,
    /\.conf$/i,
    /\.config\.js$/i,
    /package\.json$/i,
    /package-lock\.json$/i,
    /tsconfig\.json$/i,
    /\.ts$/i,
    /\.tsx$/i,
    /node_modules/i,
    /\.docker/i,
    /Dockerfile/i,
    /docker-compose/i,
  ];

  use(req: Request, res: Response, next: NextFunction) {
    const path = req.path.toLowerCase();

    // Verifier les patterns bloques
    for (const pattern of this.blockedPatterns) {
      if (pattern.test(path)) {
        throw new ForbiddenException('Access denied');
      }
    }

    // Bloquer les traversees de repertoire
    if (path.includes('..') || path.includes('%2e%2e')) {
      throw new ForbiddenException('Path traversal detected');
    }

    next();
  }
}
```

### Configuration Nginx

```nginx
# Bloquer fichiers sensibles
location ~ /\. {
    deny all;
    return 404;
}

location ~ \.(env|bak|backup|old|sql|log|ini|conf|ts|tsx)$ {
    deny all;
    return 404;
}

location ~ ^/(node_modules|\.git|\.docker)/ {
    deny all;
    return 404;
}

# Desactiver directory listing
autoindex off;

# Headers pour fichiers statiques
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    add_header X-Content-Type-Options "nosniff" always;
}
```

---

## References

- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks)
- [OWASP HTTP Methods](https://cheatsheetseries.owasp.org/cheatsheets/REST_Assessment_Cheat_Sheet.html)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
