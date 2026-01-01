# Architecture Patterns 🏛️

> Patterns obligatoires: Clean Architecture, Maintenabilité, Scalabilité

## Règle Fondamentale

```
╔══════════════════════════════════════════════════════════════╗
║     ⚠️ ARCHITECTURE PATTERNS - APPLICATION OBLIGATOIRE ⚠️     ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Ces patterns DOIVENT être appliqués pour:                   ║
║  • Toute nouvelle feature                                     ║
║  • Tout refactoring                                          ║
║  • Toute PR (vérification en code review)                    ║
║                                                               ║
║  AUCUNE exception sans validation explicite de l'Architect   ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 1. Clean Architecture

### Principes Fondamentaux

```
╔══════════════════════════════════════════════════════════════╗
║                    CLEAN ARCHITECTURE                        ║
║                                                               ║
║              ┌─────────────────────────────┐                 ║
║              │        DOMAIN               │                 ║
║              │   (Entities, Value Objects) │                 ║
║              │   Aucune dépendance externe │                 ║
║              └─────────────┬───────────────┘                 ║
║                            │                                 ║
║              ┌─────────────▼───────────────┐                 ║
║              │      APPLICATION            │                 ║
║              │   (Use Cases, DTOs)         │                 ║
║              │   Dépend uniquement Domain  │                 ║
║              └─────────────┬───────────────┘                 ║
║                            │                                 ║
║              ┌─────────────▼───────────────┐                 ║
║              │     INFRASTRUCTURE          │                 ║
║              │  (Repositories, Services)   │                 ║
║              │  Implémente les interfaces  │                 ║
║              └─────────────────────────────┘                 ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

### Règles de Dépendances

```typescript
// ❌ INTERDIT - Infrastructure ne doit JAMAIS être importée dans Domain
// domain/entities/order.entity.ts
import { PrismaClient } from '@prisma/client';  // ERREUR!

// ✅ CORRECT - Domain ne connaît que ses propres types
// domain/entities/order.entity.ts
export class Order {
  constructor(
    public readonly id: string,
    public readonly customerId: string,
    public readonly totalAmount: number,
  ) {}
}
```

### Structure de Dossiers

```
src/
├── domain/                      # Couche Domain (AUCUNE dépendance)
│   ├── entities/               # Entités métier
│   │   ├── order.entity.ts
│   │   ├── product.entity.ts
│   │   └── customer.entity.ts
│   ├── value-objects/          # Value Objects
│   │   ├── discount-code.vo.ts
│   │   └── shipping-address.vo.ts
│   ├── interfaces/             # Interfaces (Ports)
│   │   ├── order.repository.interface.ts
│   │   └── product.repository.interface.ts
│   ├── services/               # Domain Services
│   │   └── pricing-calculator.service.ts
│   └── events/                 # Domain Events
│       ├── order-placed.event.ts
│       └── payment-received.event.ts
│
├── application/                 # Couche Application
│   ├── use-cases/              # Use Cases (1 classe = 1 action)
│   │   ├── place-order.use-case.ts
│   │   ├── apply-discount.use-case.ts
│   │   └── get-bestsellers.use-case.ts
│   ├── dto/                    # Data Transfer Objects
│   │   ├── place-order.dto.ts
│   │   └── bestsellers.dto.ts
│   └── mappers/                # Entity <-> DTO mappers
│       └── order.mapper.ts
│
├── infrastructure/              # Couche Infrastructure
│   ├── repositories/           # Implémentations Repositories
│   │   ├── prisma-order.repository.ts
│   │   └── prisma-product.repository.ts
│   ├── services/               # Services externes
│   │   ├── redis-cache.service.ts
│   │   └── rabbitmq-event.service.ts
│   └── persistence/            # Prisma, migrations
│       └── prisma.service.ts
│
└── presentation/                # Couche Présentation (Controllers)
    ├── controllers/
    │   ├── order.controller.ts
    │   └── product.controller.ts
    └── guards/
        └── customer.guard.ts
```

### Template Use Case

```typescript
// application/use-cases/place-order.use-case.ts
import { Injectable, Inject } from '@nestjs/common';
import { Order } from '../../domain/entities/order.entity';
import { IOrderRepository, ORDER_REPOSITORY } from '../../domain/interfaces/order.repository.interface';
import { IEventEmitter, EVENT_EMITTER } from '../../domain/interfaces/event-emitter.interface';
import { PlaceOrderDto } from '../dto/place-order.dto';
import { OrderPlacedEvent } from '../../domain/events/order-placed.event';

@Injectable()
export class PlaceOrderUseCase {
  constructor(
    @Inject(ORDER_REPOSITORY)
    private readonly orderRepository: IOrderRepository,
    @Inject(EVENT_EMITTER)
    private readonly eventEmitter: IEventEmitter,
  ) {}

  async execute(dto: PlaceOrderDto): Promise<Order> {
    // 1. Créer l'entité Domain
    const order = Order.create({
      customerId: dto.customerId,
      items: dto.items,
      totalAmount: this.calculateTotal(dto.items),
      status: 'pending',
    });

    // 2. Persister via repository (interface, pas implémentation)
    const savedOrder = await this.orderRepository.save(order);

    // 3. Émettre event domain
    await this.eventEmitter.emit(
      new OrderPlacedEvent(savedOrder),
    );

    return savedOrder;
  }

  private calculateTotal(items: OrderItem[]): number {
    return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  }
}
```

---

## 2. Maintenabilité

### Règles de Maintenabilité

```
╔══════════════════════════════════════════════════════════════╗
║                  RÈGLES MAINTENABILITÉ                       ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  1. SINGLE RESPONSIBILITY PRINCIPLE (SRP)                    ║
║     Une classe = Une responsabilité                          ║
║     Un fichier < 300 lignes                                  ║
║     Une fonction < 50 lignes                                 ║
║                                                               ║
║  2. DEPENDENCY INJECTION                                     ║
║     Toujours injecter les dépendances                        ║
║     Jamais d'instanciation directe de services               ║
║                                                               ║
║  3. INTERFACE SEGREGATION                                    ║
║     Interfaces spécifiques > Interface générique             ║
║     IOrderReader, IOrderWriter > IOrderService               ║
║                                                               ║
║  4. TESTABILITÉ                                              ║
║     Code découplé = Code testable                            ║
║     Mocks faciles grâce aux interfaces                       ║
║     Coverage minimum: 80%                                     ║
║                                                               ║
║  5. DOCUMENTATION INLINE                                     ║
║     JSDoc sur toutes les classes/méthodes publiques          ║
║     README par module complexe                                ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

### Patterns de Maintenabilité

#### Repository Pattern

```typescript
// domain/interfaces/order.repository.interface.ts
export const ORDER_REPOSITORY = 'ORDER_REPOSITORY';

export interface IOrderRepository {
  findById(id: string): Promise<Order | null>;
  findByCustomer(customerId: string): Promise<Order[]>;
  save(order: Order): Promise<Order>;
  delete(id: string): Promise<void>;
}

// infrastructure/repositories/prisma-order.repository.ts
@Injectable()
export class PrismaOrderRepository implements IOrderRepository {
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<Order | null> {
    const data = await this.prisma.order.findUnique({ where: { id } });
    return data ? OrderMapper.toDomain(data) : null;
  }

  // ... autres méthodes
}

// Module registration
@Module({
  providers: [
    {
      provide: ORDER_REPOSITORY,
      useClass: PrismaOrderRepository,
    },
  ],
})
```

#### Factory Pattern

```typescript
// domain/factories/order.factory.ts
export class OrderFactory {
  static create(params: CreateOrderParams): Order {
    // Validation et création centralisée
    if (!params.customerId) {
      throw new DomainError('Customer ID is required');
    }

    return new Order({
      id: uuid(),
      customerId: params.customerId,
      items: params.items,
      status: 'pending',
      createdAt: new Date(),
      shippingAddress: params.shippingAddress,
    });
  }
}
```

#### Event-Driven Pattern

```typescript
// domain/events/order-shipped.event.ts
export class OrderShippedEvent {
  constructor(
    public readonly orderId: string,
    public readonly customerId: string,
    public readonly trackingNumber: string,
    public readonly shippedAt: Date,
  ) {}
}

// application/handlers/order-shipped.handler.ts
@Injectable()
export class OrderShippedHandler {
  @OnEvent('order.shipped')
  async handle(event: OrderShippedEvent): Promise<void> {
    // Notification, analytics, etc.
  }
}
```

### Métriques Maintenabilité

```
MÉTRIQUES OBLIGATOIRES
══════════════════════

┌─────────────────────────┬─────────────┬─────────────────────┐
│ Métrique                │ Seuil       │ Vérification        │
├─────────────────────────┼─────────────┼─────────────────────┤
│ Cyclomatic Complexity   │ < 10        │ ESLint              │
│ Lines per file          │ < 300       │ ESLint              │
│ Lines per function      │ < 50        │ ESLint              │
│ Test coverage           │ > 80%       │ Jest                │
│ Duplication             │ < 3%        │ SonarQube           │
│ Technical debt ratio    │ < 5%        │ SonarQube           │
└─────────────────────────┴─────────────┴─────────────────────┘
```

---

## 3. Scalabilité

### Principes de Scalabilité

```
╔══════════════════════════════════════════════════════════════╗
║                  PRINCIPES SCALABILITÉ                       ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  1. STATELESS SERVICES                                       ║
║     Aucun état en mémoire entre requêtes                     ║
║     Sessions dans Redis, pas en mémoire                      ║
║                                                               ║
║  2. HORIZONTAL SCALING                                       ║
║     Design pour N instances identiques                       ║
║     Load balancer compatible                                  ║
║                                                               ║
║  3. DATABASE OPTIMIZATION                                    ║
║     Indexes sur toutes colonnes filtrées                     ║
║     Pagination OBLIGATOIRE sur toute liste                   ║
║     Connection pooling                                        ║
║                                                               ║
║  4. CACHING STRATEGY                                         ║
║     Cache Redis pour données fréquentes                      ║
║     TTL approprié, invalidation event-driven                 ║
║                                                               ║
║  5. ASYNC PROCESSING                                         ║
║     Opérations lourdes via queue (RabbitMQ)                  ║
║     Background jobs pour batch processing                     ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```

### Patterns de Scalabilité

#### Pagination Pattern

```typescript
// OBLIGATOIRE sur toute liste
export class PaginationDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit: number = 20;

  @IsOptional()
  @IsInt()
  @Min(0)
  offset: number = 0;
}

export interface PaginatedResult<T> {
  data: T[];
  meta: {
    total: number;
    limit: number;
    offset: number;
    hasMore: boolean;
  };
}

// Usage
async findAll(pagination: PaginationDto): Promise<PaginatedResult<Product>> {
  const [data, total] = await Promise.all([
    this.prisma.product.findMany({
      take: pagination.limit,
      skip: pagination.offset,
    }),
    this.prisma.product.count(),
  ]);

  return {
    data,
    meta: {
      total,
      limit: pagination.limit,
      offset: pagination.offset,
      hasMore: pagination.offset + data.length < total,
    },
  };
}
```

#### Cache-Aside Pattern

```typescript
// infrastructure/cache/cache-aside.decorator.ts
export function CacheAside(options: CacheOptions) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const cacheKey = `${options.prefix}:${JSON.stringify(args)}`;
      const redis = this.redis;

      // Try cache first
      const cached = await redis.get(cacheKey);
      if (cached) {
        return JSON.parse(cached);
      }

      // Execute method
      const result = await originalMethod.apply(this, args);

      // Store in cache
      await redis.setex(cacheKey, options.ttl, JSON.stringify(result));

      return result;
    };
  };
}

// Usage
@CacheAside({ prefix: 'bestsellers', ttl: 60 })
async getBestsellers(categoryId: string): Promise<Product[]> {
  return this.productRepository.findTopByCategory(categoryId, 100);
}
```

#### Event Queue Pattern

```typescript
// Pour opérations lourdes
@Injectable()
export class OrderService {
  constructor(
    @Inject('RABBITMQ_CLIENT')
    private readonly rabbitClient: ClientProxy,
  ) {}

  async placeOrder(dto: PlaceOrderDto): Promise<Order> {
    // 1. Sauvegarder commande (synchrone, rapide)
    const order = await this.orderRepository.save(dto);

    // 2. Opérations lourdes en async (queue)
    this.rabbitClient.emit('order.placed', {
      orderId: order.id,
      customerId: dto.customerId,
      totalAmount: order.totalAmount,
    });

    // 3. Répondre immédiatement
    return order;
  }
}

// Consumer (process séparé)
@Controller()
export class OrderConsumer {
  @MessagePattern('order.placed')
  async handleOrderPlaced(data: OrderPlacedPayload) {
    // Opérations lourdes: email, stock update, analytics
    await this.emailService.sendConfirmation(data.customerId);
    await this.inventoryService.decrementStock(data.orderId);
    await this.analyticsService.track(data);
  }
}
```

### Métriques Scalabilité

```
OBJECTIFS SCALABILITÉ
═════════════════════

┌─────────────────────────────┬─────────────────────────────────┐
│ Métrique                    │ Objectif                        │
├─────────────────────────────┼─────────────────────────────────┤
│ Concurrent users            │ 10,000 sans dégradation         │
│ API response P95            │ < 200ms                         │
│ DB connections per instance │ < 20                            │
│ Memory per instance         │ < 512MB                         │
│ CPU per instance            │ < 70% (scale trigger à 80%)     │
│ Cache hit rate              │ > 90%                           │
│ Queue processing lag        │ < 5 seconds                     │
└─────────────────────────────┴─────────────────────────────────┘

SCALING AUTOMATIQUE:
├── CPU > 80% pendant 5min → Scale up
├── CPU < 30% pendant 15min → Scale down
└── Min instances: 2, Max instances: 10
```

---

## Checklist Validation

```
CHECKLIST ARCHITECTURE - Obligatoire avant merge
════════════════════════════════════════════════

CLEAN ARCHITECTURE:
□ Domain entities sans dépendances externes
□ Use cases dans application layer
□ Repositories via interfaces
□ Controllers dans presentation layer
□ Dependency injection partout

MAINTENABILITÉ:
□ Classes < 300 lignes
□ Fonctions < 50 lignes
□ Cyclomatic complexity < 10
□ Tests coverage > 80%
□ JSDoc sur API publiques

SCALABILITÉ:
□ Pagination sur toutes les listes
□ Cache Redis pour données fréquentes
□ Opérations lourdes en async (queue)
□ Stateless (pas d'état en mémoire)
□ Indexes DB sur colonnes filtrées
```

---

## Références

- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [12-Factor App](https://12factor.net/)
- [Scalability Patterns](https://docs.microsoft.com/en-us/azure/architecture/patterns/)

---

*Architecture Patterns - Harmony Framework*
