---
name: react-native-architecture
displayName: "React Native Architecture"
category: frontend-development
tier: 2
model: inherit
triggers:
  - "react native"
  - "expo"
  - "mobile app"
  - "ios android"
  - "cross-platform"
---

# React Native Architecture

> Architect React Native applications for scalability and maintainability.

## Project Structure (Expo)

```
src/
├── app/                      # Expo Router (file-based routing)
│   ├── (tabs)/               # Tab navigation group
│   │   ├── _layout.tsx
│   │   ├── index.tsx         # Home tab
│   │   └── profile.tsx       # Profile tab
│   ├── (auth)/               # Auth flow group
│   │   ├── login.tsx
│   │   └── register.tsx
│   ├── _layout.tsx           # Root layout
│   └── [id].tsx              # Dynamic route
├── components/
│   ├── ui/                   # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── Card.tsx
│   └── features/             # Feature-specific components
│       ├── auth/
│       └── profile/
├── hooks/                    # Custom hooks
│   ├── useAuth.ts
│   └── useTheme.ts
├── services/                 # API and external services
│   ├── api.ts
│   └── storage.ts
├── stores/                   # State management (Zustand)
│   ├── authStore.ts
│   └── settingsStore.ts
├── utils/                    # Utility functions
│   └── helpers.ts
├── constants/                # App constants
│   ├── Colors.ts
│   └── Layout.ts
└── types/                    # TypeScript types
    └── index.ts
```

## Navigation (Expo Router)

### Tab Navigation
```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Home, User, Settings } from 'lucide-react-native';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        tabBarStyle: { paddingBottom: 5 },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => <Home color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => <User color={color} size={size} />,
        }}
      />
    </Tabs>
  );
}
```

### Protected Routes
```tsx
// app/_layout.tsx
import { Slot, useRouter, useSegments } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';

export default function RootLayout() {
  const { user, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!user && !inAuthGroup) {
      router.replace('/login');
    } else if (user && inAuthGroup) {
      router.replace('/');
    }
  }, [user, segments, isLoading]);

  if (isLoading) return <LoadingScreen />;

  return <Slot />;
}
```

## Styling with NativeWind

```tsx
// tailwind.config.js
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        primary: '#007AFF',
      },
    },
  },
};

// Component with NativeWind
import { View, Text, Pressable } from 'react-native';

export function Button({ title, onPress, variant = 'primary' }) {
  return (
    <Pressable
      onPress={onPress}
      className={`
        px-4 py-3 rounded-lg
        ${variant === 'primary' ? 'bg-primary' : 'bg-gray-200'}
        active:opacity-80
      `}
    >
      <Text className={`
        text-center font-semibold
        ${variant === 'primary' ? 'text-white' : 'text-gray-800'}
      `}>
        {title}
      </Text>
    </Pressable>
  );
}
```

## State Management (Zustand)

```tsx
// stores/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isLoading: false,

      login: async (credentials) => {
        set({ isLoading: true });
        try {
          const { user, token } = await authApi.login(credentials);
          set({ user, token, isLoading: false });
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },

      logout: () => {
        set({ user: null, token: null });
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

## API Layer

```tsx
// services/api.ts
import { useAuthStore } from '@/stores/authStore';

const BASE_URL = process.env.EXPO_PUBLIC_API_URL;

class ApiClient {
  private getHeaders(): HeadersInit {
    const token = useAuthStore.getState().token;
    return {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  }

  async get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      headers: this.getHeaders(),
    });

    if (!response.ok) {
      if (response.status === 401) {
        useAuthStore.getState().logout();
      }
      throw new ApiError(response.status, await response.text());
    }

    return response.json();
  }

  async post<T>(endpoint: string, data: unknown): Promise<T> {
    const response = await fetch(`${BASE_URL}${endpoint}`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      throw new ApiError(response.status, await response.text());
    }

    return response.json();
  }
}

export const api = new ApiClient();

// React Query integration
export function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.get<User[]>('/users'),
  });
}
```

## Platform-Specific Code

```tsx
// Platform-specific files
// Button.ios.tsx
// Button.android.tsx
// Button.tsx (fallback)

// Or inline
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  container: {
    paddingTop: Platform.OS === 'ios' ? 50 : 30,
    ...Platform.select({
      ios: { shadowColor: 'black', shadowOpacity: 0.2 },
      android: { elevation: 4 },
    }),
  },
});
```

## Performance Optimization

```tsx
// Memoization
const MemoizedItem = React.memo(({ item }: { item: Item }) => (
  <View>
    <Text>{item.title}</Text>
  </View>
));

// FlashList for large lists
import { FlashList } from '@shopify/flash-list';

function UserList({ users }: { users: User[] }) {
  return (
    <FlashList
      data={users}
      renderItem={({ item }) => <UserCard user={item} />}
      estimatedItemSize={100}
      keyExtractor={(item) => item.id}
    />
  );
}

// Image optimization
import { Image } from 'expo-image';

<Image
  source={{ uri: imageUrl }}
  contentFit="cover"
  transition={200}
  placeholder={blurhash}
/>
```

## Offline Support

```tsx
// React Query + AsyncStorage
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 60, // 1 hour
    },
  },
});

// Persist queries
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister';

const persister = createAsyncStoragePersister({
  storage: AsyncStorage,
});

<PersistQueryClientProvider
  client={queryClient}
  persistOptions={{ persister }}
>
  <App />
</PersistQueryClientProvider>
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Expo Router** | File-based routing, deep linking |
| **NativeWind** | Tailwind for consistent styling |
| **Zustand + AsyncStorage** | Persist state offline |
| **React Query** | Server state + caching |
| **FlashList** | Better performance than FlatList |
| **expo-image** | Optimized image loading |
| **Platform files** | .ios.tsx / .android.tsx |
