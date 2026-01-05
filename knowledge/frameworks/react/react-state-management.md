---
name: react-state-management
displayName: "React State Management"
category: frontend-development
tier: 2
model: inherit
triggers:
  - "useState"
  - "useReducer"
  - "context"
  - "zustand"
  - "redux"
  - "state management"
---

# React State Management

> Implement effective state management solutions for React applications.

## State Types

| Type | Scope | Solution |
|------|-------|----------|
| **Local UI** | Component | useState, useReducer |
| **Shared UI** | Feature | Context, Zustand |
| **Server** | App-wide | React Query, SWR |
| **URL** | Navigation | useSearchParams |
| **Form** | Form | React Hook Form |

## Local State

### useState
```tsx
const [count, setCount] = useState(0);
const [user, setUser] = useState<User | null>(null);

// Functional update (previous state)
setCount(prev => prev + 1);

// Object update (spread)
setUser(prev => ({ ...prev, name: 'New Name' }));
```

### useReducer
```tsx
type State = { count: number; step: number };
type Action =
  | { type: 'increment' }
  | { type: 'decrement' }
  | { type: 'setStep'; payload: number };

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { ...state, count: state.count + state.step };
    case 'decrement':
      return { ...state, count: state.count - state.step };
    case 'setStep':
      return { ...state, step: action.payload };
  }
}

const [state, dispatch] = useReducer(reducer, { count: 0, step: 1 });
dispatch({ type: 'increment' });
```

## Shared State with Context

```tsx
// 1. Create context
type AuthContextType = {
  user: User | null;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
};

const AuthContext = createContext<AuthContextType | null>(null);

// 2. Create provider
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const login = async (credentials: Credentials) => {
    const user = await authApi.login(credentials);
    setUser(user);
  };

  const logout = () => setUser(null);

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// 3. Create hook
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}

// 4. Usage
function Profile() {
  const { user, logout } = useAuth();
  return <button onClick={logout}>Logout {user?.name}</button>;
}
```

## Zustand (Recommended for Most Cases)

```tsx
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

interface CartStore {
  items: CartItem[];
  total: number;
  addItem: (item: Product) => void;
  removeItem: (id: string) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartStore>()(
  devtools(
    persist(
      (set, get) => ({
        items: [],
        total: 0,

        addItem: (product) => set((state) => {
          const existing = state.items.find(i => i.id === product.id);
          if (existing) {
            return {
              items: state.items.map(i =>
                i.id === product.id ? { ...i, quantity: i.quantity + 1 } : i
              ),
              total: state.total + product.price,
            };
          }
          return {
            items: [...state.items, { ...product, quantity: 1 }],
            total: state.total + product.price,
          };
        }),

        removeItem: (id) => set((state) => ({
          items: state.items.filter(i => i.id !== id),
          total: state.items
            .filter(i => i.id !== id)
            .reduce((sum, i) => sum + i.price * i.quantity, 0),
        })),

        clearCart: () => set({ items: [], total: 0 }),
      }),
      { name: 'cart-storage' }
    )
  )
);

// Usage - only re-renders on items change
function CartCount() {
  const itemCount = useCartStore((state) => state.items.length);
  return <span>{itemCount}</span>;
}
```

## Server State with React Query

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

// Fetch data
function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get('/users'),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Mutate with optimistic update
function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (user: User) => api.put(`/users/${user.id}`, user),

    onMutate: async (newUser) => {
      await queryClient.cancelQueries({ queryKey: ['users'] });
      const previous = queryClient.getQueryData(['users']);

      queryClient.setQueryData(['users'], (old: User[]) =>
        old.map(u => u.id === newUser.id ? newUser : u)
      );

      return { previous };
    },

    onError: (err, newUser, context) => {
      queryClient.setQueryData(['users'], context?.previous);
    },

    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });
}

// Usage
function UserList() {
  const { data: users, isLoading, error } = useUsers();
  const updateUser = useUpdateUser();

  if (isLoading) return <Spinner />;
  if (error) return <Error message={error.message} />;

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>
          {user.name}
          <button onClick={() => updateUser.mutate({ ...user, active: true })}>
            Activate
          </button>
        </li>
      ))}
    </ul>
  );
}
```

## Decision Guide

```
┌─────────────────────────────────────────────┐
│               STATE TYPE?                    │
├─────────────────────────────────────────────┤
│                                              │
│  Server Data? ──────► React Query / SWR     │
│       │                                      │
│       NO                                     │
│       ▼                                      │
│  Shared across components? ──► Zustand      │
│       │                                      │
│       NO                                     │
│       ▼                                      │
│  Complex logic? ──────────► useReducer      │
│       │                                      │
│       NO                                     │
│       ▼                                      │
│  ────────────────────────► useState         │
│                                              │
└─────────────────────────────────────────────┘
```

## Best Practices

- [ ] Keep state as local as possible
- [ ] Use server state libraries for API data
- [ ] Avoid prop drilling with context/Zustand
- [ ] Memoize selectors for performance
- [ ] Split stores by domain
- [ ] Use TypeScript for type safety
