# Angular Architecture - Best Practices Industrie

> Sources: angular.dev/style-guide, Context7
> Dernière mise à jour: 2026-01-04

---

## Principes Architecturaux (Angular 18+)

### Standalone Components par Défaut

> "Always use standalone components over NgModules" - Angular Style Guide 2025

```typescript
// ✅ Angular 18+ : standalone par défaut (pas besoin de standalone: true)
@Component({
  selector: 'app-user-profile',
  templateUrl: './user-profile.html',
  imports: [CommonModule, ReactiveFormsModule],
})
export class UserProfileComponent {}

// ❌ Ancien style (NgModules) - à éviter
@NgModule({
  declarations: [UserProfileComponent],
  imports: [CommonModule],
})
export class UserModule {}
```

### Injection de Dépendances

> "Favor the `inject()` function over constructor parameter injection"

```typescript
// ✅ Angular 18+ : inject() préféré
@Component({...})
export class UserProfileComponent {
  private readonly userService = inject(UserService);
  private readonly router = inject(Router);
  private readonly config = inject(APP_CONFIG);
}

// ❌ Ancien style - constructor injection
export class UserProfileComponent {
  constructor(
    private userService: UserService,
    private router: Router,
  ) {}
}
```

**Avantages de inject():**
- Meilleure lisibilité avec plusieurs dépendances
- Meilleure inférence de types TypeScript
- Initialisation de champs plus propre (ES2022+)

---

## Organisation des Fichiers

> "Organize by feature areas, not by code type"

### ✅ Structure Recommandée

```
src/
├── app/
│   ├── users/                    # Feature module
│   │   ├── user-profile/
│   │   │   ├── user-profile.ts
│   │   │   ├── user-profile.html
│   │   │   ├── user-profile.css
│   │   │   └── user-profile.spec.ts
│   │   ├── user-list/
│   │   └── users.routes.ts
│   ├── products/                 # Autre feature
│   │   ├── product-card/
│   │   └── products.routes.ts
│   └── shared/                   # Composants partagés
│       ├── ui/
│       └── utils/
```

### ❌ À Éviter

```
src/
├── components/     # Non! Pas par type
├── services/       # Non!
├── directives/     # Non!
└── pipes/          # Non!
```

---

## Conventions de Nommage

| Type | Pattern Fichier | Pattern Classe |
|------|-----------------|----------------|
| Component | `user-profile.ts` | `UserProfileComponent` |
| Service | `user.service.ts` | `UserService` |
| Directive | `tooltip.directive.ts` | `TooltipDirective` |
| Pipe | `date-format.pipe.ts` | `DateFormatPipe` |
| Guard | `auth.guard.ts` | `authGuard` (function) |
| Test | `*.spec.ts` | - |

```typescript
// Fichiers du même composant partagent le nom
user-profile.ts       // TypeScript
user-profile.html     // Template
user-profile.css      // Styles
user-profile.spec.ts  // Tests
```

---

## Signals (Angular 18+)

> State management moderne, remplace progressivement RxJS pour l'état local

```typescript
@Component({...})
export class CounterComponent {
  // État local avec signal
  count = signal(0);

  // État dérivé avec computed
  doubleCount = computed(() => this.count() * 2);

  // Effet pour side effects
  constructor() {
    effect(() => {
      console.log('Count changed:', this.count());
    });
  }

  increment() {
    this.count.update(c => c + 1);  // ✅ update()
    // this.count.set(this.count() + 1);  // Aussi valide
  }
}
```

**Règles Signals:**
- `signal()` pour état mutable
- `computed()` pour état dérivé
- `effect()` pour side effects
- JAMAIS `mutate()` (deprecated), utiliser `update()` ou `set()`

---

## Templates (Angular 17+)

### Nouveau Control Flow

```html
<!-- ✅ Angular 17+ : @if/@for/@switch -->
@if (user) {
  <p>{{ user.name }}</p>
} @else {
  <p>Loading...</p>
}

@for (item of items; track item.id) {
  <app-item [data]="item" />
}

<!-- ❌ Ancien style - à migrer -->
<p *ngIf="user">{{ user.name }}</p>
<div *ngFor="let item of items">...</div>
```

### Bindings Préférés

```html
<!-- ✅ Préféré : class/style bindings -->
<div [class.active]="isActive" [style.color]="textColor">

<!-- ❌ À éviter : ngClass/ngStyle -->
<div [ngClass]="{'active': isActive}" [ngStyle]="{'color': textColor}">
```

---

## Services

```typescript
// ✅ providedIn: 'root' pour singletons
@Injectable({ providedIn: 'root' })
export class UserService {
  private readonly http = inject(HttpClient);

  getUsers() {
    return this.http.get<User[]>('/api/users');
  }
}
```

---

## Accessibilité (OBLIGATOIRE)

> "It MUST pass all AXE checks. It MUST follow all WCAG AA minimums."

- Focus management
- Color contrast
- ARIA attributes
- Keyboard navigation

---

*Source: angular.dev/style-guide, Context7 - Angular Best Practices for LLM*
