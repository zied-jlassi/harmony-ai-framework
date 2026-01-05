# Symfony Architecture - Best Practices Industrie

> Sources: symfony.com/best_practices, Context7
> Dernière mise à jour: 2026-01-04

---

## Principes Architecturaux

### Autowiring par Défaut

> "Use dependency injection by type-hinting action method arguments"

```php
// ✅ Symfony 6+/7+ : Injection par type-hint (autowiring)
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\Response;

class LuckyController extends AbstractController
{
    public function number(
        int $max,
        LoggerInterface $logger,
        GreetingGenerator $generator
    ): Response {
        $logger->info('We are logging!');
        return new Response($generator->getRandomGreeting());
    }
}

// ❌ Ancien style - $this->get() (deprecated)
$logger = $this->get('logger');
```

### Attributs PHP 8+ pour le Routing

```php
// ✅ Symfony 6.1+ : Attributs PHP
use Symfony\Component\Routing\Attribute\Route;

class ProductController extends AbstractController
{
    #[Route('/product/{id}', name: 'product_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        // ...
    }
}

// ❌ Ancien style - Annotations (deprecated)
/**
 * @Route("/product/{id}", name="product_show")
 */
```

### Injection Explicite avec #[Autowire]

```php
// ✅ Symfony 6.1+ : Injection précise
use Symfony\Component\DependencyInjection\Attribute\Autowire;

class LuckyController extends AbstractController
{
    public function number(
        #[Autowire(service: 'monolog.logger.request')]
        LoggerInterface $logger,

        #[Autowire('%kernel.project_dir%')]
        string $projectDir
    ): Response {
        // ...
    }
}
```

---

## Organisation des Fichiers

> "Organize by domain/feature, not by technical layer"

### ✅ Structure Recommandée

```
src/
├── Controller/                # Contrôleurs
│   ├── Api/                   # API endpoints
│   └── Admin/                 # Backoffice
├── Entity/                    # Entités Doctrine
├── Repository/                # Repositories
├── Service/                   # Services métier
│   ├── User/
│   │   ├── UserCreator.php
│   │   └── UserNotifier.php
│   └── Order/
├── Form/                      # Types de formulaires
├── Security/                  # Voters, Authenticators
└── EventSubscriber/           # Event listeners
```

---

## Controllers

### Règles Best Practices

```php
// ✅ Controller léger - délègue au service
#[Route('/api/orders', name: 'order_')]
class OrderController extends AbstractController
{
    #[Route('', name: 'create', methods: ['POST'])]
    public function create(
        #[MapRequestPayload] CreateOrderRequest $request,
        OrderService $orderService
    ): JsonResponse {
        $order = $orderService->create($request);
        return $this->json($order, Response::HTTP_CREATED);
    }
}

// ❌ Controller fat - logique métier dans le contrôleur
public function create(Request $request): Response
{
    // 50 lignes de logique métier... NON!
}
```

### MapRequestPayload (Symfony 6.3+)

```php
// ✅ Désérialisation automatique du body
use Symfony\Component\HttpKernel\Attribute\MapRequestPayload;

#[Route('/api/users', methods: ['POST'])]
public function create(
    #[MapRequestPayload] CreateUserDto $dto
): JsonResponse {
    // $dto est automatiquement validé et hydraté
}
```

---

## Services

### Bonnes Pratiques

```php
// ✅ Service avec dépendances injectées
#[AsService]
class OrderService
{
    public function __construct(
        private readonly OrderRepository $orderRepository,
        private readonly EventDispatcherInterface $dispatcher,
        private readonly LoggerInterface $logger,
    ) {}

    public function create(CreateOrderRequest $request): Order
    {
        $order = new Order($request->items);
        $this->orderRepository->save($order);
        $this->dispatcher->dispatch(new OrderCreatedEvent($order));
        return $order;
    }
}
```

### Configuration services.yaml

```yaml
# config/services.yaml
services:
    _defaults:
        autowire: true
        autoconfigure: true

    App\:
        resource: '../src/'
        exclude:
            - '../src/DependencyInjection/'
            - '../src/Entity/'
            - '../src/Kernel.php'
```

---

## Sécurité

### Voters pour Autorisation

```php
// ✅ Voter pour logique d'autorisation complexe
use Symfony\Component\Security\Core\Authorization\Voter\Voter;

class OrderVoter extends Voter
{
    protected function supports(string $attribute, mixed $subject): bool
    {
        return in_array($attribute, ['VIEW', 'EDIT'])
            && $subject instanceof Order;
    }

    protected function voteOnAttribute(
        string $attribute,
        mixed $subject,
        TokenInterface $token
    ): bool {
        $user = $token->getUser();
        return $subject->getOwner() === $user;
    }
}
```

---

## Conventions de Nommage

| Type | Pattern | Exemple |
|------|---------|---------|
| Controller | `{Name}Controller` | `OrderController` |
| Service | `{Name}Service` ou `{Verb}{Name}` | `OrderService`, `CreateOrder` |
| Entity | `{Name}` (singulier) | `Order`, `User` |
| Repository | `{Entity}Repository` | `OrderRepository` |
| Form Type | `{Name}Type` | `OrderType` |
| Voter | `{Entity}Voter` | `OrderVoter` |
| Event | `{Action}{Entity}Event` | `OrderCreatedEvent` |
| DTO | `{Action}{Entity}Dto` | `CreateOrderDto` |

---

*Source: symfony.com/best_practices, Context7 - Symfony Best Practices for LLM*
