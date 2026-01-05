# React Architecture - Best Practices Industrie

> Sources: react.dev, Clean Code Architecture, Context7
> Dernière mise à jour: 2026-01-04

---

## Clean Architecture pour React

### Principes SOLID Appliqués

```
┌─────────────────────────────────────────────────────────────────┐
│                    CLEAN ARCHITECTURE REACT                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   PRESENTATION        │   APPLICATION       │   DOMAIN/DATA     │
│   (UI Layer)          │   (Business Logic)  │   (Core Logic)    │
│   ─────────────       │   ─────────────     │   ─────────────   │
│   • Components        │   • Use Cases       │   • Entities      │
│   • Pages             │   • Services        │   • Repositories  │
│   • Hooks (UI)        │   • Hooks (Logic)   │   • API Clients   │
│                       │                     │                   │
│   Dépend de →         │   Dépend de →       │   (indépendant)   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Structure Clean Architecture

```
src/
├── presentation/              # UI Layer (React-specific)
│   ├── components/            # UI Components (dumb)
│   │   ├── Button/
│   │   ├── Card/
│   │   └── Modal/
│   ├── pages/                 # Page components
│   │   ├── HomePage/
│   │   └── UserPage/
│   └── hooks/                 # UI-only hooks (animations, focus)
│       └── useScrollPosition.ts
│
├── application/               # Business Logic Layer
│   ├── useCases/              # Use cases (actions)
│   │   ├── user/
│   │   │   ├── createUser.ts
│   │   │   ├── updateUser.ts
│   │   │   └── deleteUser.ts
│   │   └── order/
│   ├── services/              # Application services
│   │   ├── AuthService.ts
│   │   └── NotificationService.ts
│   └── hooks/                 # Business logic hooks
│       ├── useAuth.ts
│       └── useOrders.ts
│
├── domain/                    # Domain Layer (framework-agnostic)
│   ├── entities/              # Business entities
│   │   ├── User.ts
│   │   └── Order.ts
│   ├── repositories/          # Repository interfaces
│   │   └── IUserRepository.ts
│   └── valueObjects/          # Value objects
│       └── Email.ts
│
├── infrastructure/            # Data Layer
│   ├── api/                   # API clients
│   │   ├── httpClient.ts
│   │   └── userApi.ts
│   ├── repositories/          # Repository implementations
│   │   └── UserRepository.ts
│   └── storage/               # Local storage, cache
│       └── localStorage.ts
│
└── shared/                    # Utilitaires partagés
    ├── types/
    ├── constants/
    └── utils/
```

---

## Principes Clean Code

### Single Responsibility (SRP)

```jsx
// ❌ Composant qui fait trop de choses
function UserCard({ userId }) {
  const [user, setUser] = useState(null);
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    fetch(`/api/users/${userId}`).then(r => r.json()).then(setUser);
    fetch(`/api/users/${userId}/orders`).then(r => r.json()).then(setOrders);
  }, [userId]);

  // 100 lignes de logique...

  return (/* rendu complexe */);
}

// ✅ Séparation des responsabilités
// Hook pour la logique
function useUser(userId) {
  const [user, setUser] = useState(null);
  useEffect(() => {
    userRepository.getById(userId).then(setUser);
  }, [userId]);
  return user;
}

// Composant pour l'affichage uniquement
function UserCard({ userId }) {
  const user = useUser(userId);
  if (!user) return <Skeleton />;
  return <UserCardView user={user} />;
}

// Composant de présentation pur
function UserCardView({ user }) {
  return (
    <Card>
      <Avatar src={user.avatar} />
      <Name>{user.name}</Name>
    </Card>
  );
}
```

### Dependency Inversion (DIP)

```typescript
// ✅ Interface dans domain/ (pas de dépendance framework)
// domain/repositories/IUserRepository.ts
interface IUserRepository {
  getById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}

// ✅ Implémentation dans infrastructure/
// infrastructure/repositories/UserRepository.ts
class UserRepository implements IUserRepository {
  constructor(private httpClient: HttpClient) {}

  async getById(id: string): Promise<User> {
    const data = await this.httpClient.get(`/users/${id}`);
    return User.fromDTO(data);
  }
}

// ✅ Hook utilise l'interface, pas l'implémentation
// application/hooks/useUser.ts
function useUser(id: string, repository: IUserRepository) {
  const [user, setUser] = useState<User | null>(null);
  useEffect(() => {
    repository.getById(id).then(setUser);
  }, [id, repository]);
  return user;
}
```

### Open/Closed (OCP)

```jsx
// ✅ Composant extensible sans modification
function Button({ variant = 'primary', size = 'md', children, ...props }) {
  const variants = {
    primary: 'bg-blue-500 text-white',
    secondary: 'bg-gray-200 text-gray-800',
    danger: 'bg-red-500 text-white',
  };

  const sizes = {
    sm: 'px-2 py-1 text-sm',
    md: 'px-4 py-2',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <button
      className={`${variants[variant]} ${sizes[size]}`}
      {...props}
    >
      {children}
    </button>
  );
}

// Extensible via composition
function IconButton({ icon, ...props }) {
  return (
    <Button {...props}>
      <Icon name={icon} />
    </Button>
  );
}
```

---

## Components Patterns

### Container/Presenter Pattern

```jsx
// ✅ Container: logique + data fetching
function UserListContainer() {
  const users = useUsers();
  const { sortBy, setSortBy } = useSorting();

  const sortedUsers = useMemo(
    () => [...users].sort(comparators[sortBy]),
    [users, sortBy]
  );

  return (
    <UserListPresenter
      users={sortedUsers}
      sortBy={sortBy}
      onSortChange={setSortBy}
    />
  );
}

// ✅ Presenter: rendu uniquement (facilement testable)
function UserListPresenter({ users, sortBy, onSortChange }) {
  return (
    <div>
      <SortSelector value={sortBy} onChange={onSortChange} />
      <ul>
        {users.map(user => (
          <UserItem key={user.id} user={user} />
        ))}
      </ul>
    </div>
  );
}
```

### Compound Components

```jsx
// ✅ API flexible et composable
function Tabs({ children, defaultValue }) {
  const [active, setActive] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ active, setActive }}>
      {children}
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }) {
  return <div role="tablist">{children}</div>;
};

Tabs.Tab = function Tab({ value, children }) {
  const { active, setActive } = useTabsContext();
  return (
    <button
      role="tab"
      aria-selected={active === value}
      onClick={() => setActive(value)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabsPanel({ value, children }) {
  const { active } = useTabsContext();
  if (active !== value) return null;
  return <div role="tabpanel">{children}</div>;
};

// Usage
<Tabs defaultValue="profile">
  <Tabs.List>
    <Tabs.Tab value="profile">Profile</Tabs.Tab>
    <Tabs.Tab value="settings">Settings</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="profile">Profile content</Tabs.Panel>
  <Tabs.Panel value="settings">Settings content</Tabs.Panel>
</Tabs>
```

---

## État et Hooks

### État Dérivé vs État Stocké

```jsx
// ✅ État dérivé - calculé au render
function Form() {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');

  // Dérivé, pas stocké!
  const fullName = firstName + ' ' + lastName;
  const isValid = firstName.length > 0 && lastName.length > 0;

  return (/* ... */);
}

// ❌ Anti-pattern: Stocker ce qui peut être calculé
const [fullName, setFullName] = useState('');  // Redondant!
useEffect(() => {
  setFullName(firstName + ' ' + lastName);     // Inutile!
}, [firstName, lastName]);
```

### useReducer pour Logique Complexe

```jsx
// ✅ Reducer pour état complexe avec Clean Code
const initialState = { items: [], loading: false, error: null };

function cartReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM':
      return { ...state, items: [...state.items, action.payload] };
    case 'REMOVE_ITEM':
      return { ...state, items: state.items.filter(i => i.id !== action.payload) };
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    case 'SET_ERROR':
      return { ...state, error: action.payload, loading: false };
    default:
      throw new Error(`Unknown action: ${action.type}`);
  }
}

function useCart() {
  const [state, dispatch] = useReducer(cartReducer, initialState);

  const addItem = useCallback((item) => {
    dispatch({ type: 'ADD_ITEM', payload: item });
  }, []);

  const removeItem = useCallback((id) => {
    dispatch({ type: 'REMOVE_ITEM', payload: id });
  }, []);

  return { ...state, addItem, removeItem };
}
```

---

## Conventions de Nommage

| Type | Pattern | Exemple |
|------|---------|---------|
| Component | `PascalCase` | `UserProfile`, `LoginForm` |
| Hook | `useCamelCase` | `useAuth`, `useLocalStorage` |
| Use Case | `verbNoun` | `createUser`, `fetchOrders` |
| Repository | `I{Name}Repository` | `IUserRepository` |
| Service | `{Name}Service` | `AuthService` |
| Entity | `PascalCase` | `User`, `Order` |
| Event handler | `handleEvent` | `handleClick`, `handleSubmit` |

---

## Accessibilité (OBLIGATOIRE)

```jsx
// ✅ Labels pour inputs
<label htmlFor="email">Email</label>
<input id="email" type="email" aria-describedby="email-hint" />
<span id="email-hint">We'll never share your email</span>

// ✅ Rôles ARIA
<nav aria-label="Main navigation">
  <ul role="menubar">
    <li role="none"><a role="menuitem" href="/">Home</a></li>
  </ul>
</nav>

// ✅ Focus management
const modalRef = useRef();
useEffect(() => {
  if (isOpen) modalRef.current?.focus();
}, [isOpen]);
```

---

*Source: react.dev, Clean Code (R. Martin), Context7 - React Best Practices for LLM*
