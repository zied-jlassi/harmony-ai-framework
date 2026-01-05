---
name: nextjs-app-router-patterns
displayName: "Next.js App Router Patterns"
category: frontend-development
tier: 2
model: inherit
triggers:
  - "next.js"
  - "app router"
  - "server components"
  - "server actions"
  - "RSC"
---

# Next.js App Router Patterns

> Build Next.js 14+ applications with App Router best practices.

## Project Structure
```
app/
├── (auth)/                    # Route group (no URL segment)
│   ├── login/page.tsx
│   └── register/page.tsx
├── (dashboard)/
│   ├── layout.tsx             # Shared dashboard layout
│   ├── page.tsx               # /dashboard
│   └── settings/page.tsx      # /dashboard/settings
├── api/
│   └── users/route.ts         # API route
├── users/
│   ├── [id]/                  # Dynamic segment
│   │   ├── page.tsx           # /users/123
│   │   └── loading.tsx        # Loading UI
│   └── page.tsx               # /users
├── layout.tsx                 # Root layout
├── page.tsx                   # Home page
├── error.tsx                  # Error boundary
├── not-found.tsx              # 404 page
└── globals.css
```

## Server vs Client Components

### Server Component (Default)
```tsx
// app/users/page.tsx (Server Component)
async function UsersPage() {
  // Direct database access - no API needed!
  const users = await db.user.findMany();

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Client Component
```tsx
'use client';

import { useState } from 'react';

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </button>
  );
}
```

### Composition Pattern
```tsx
// Server Component with Client children
import { Counter } from './Counter'; // Client
import { UserData } from './UserData'; // Server

export default async function Page() {
  const data = await fetchData(); // Server-side fetch

  return (
    <div>
      <UserData data={data} />     {/* Server */}
      <Counter />                   {/* Client */}
    </div>
  );
}
```

## Data Fetching

### Parallel Fetching
```tsx
async function Dashboard() {
  // Parallel - much faster!
  const [user, posts, comments] = await Promise.all([
    getUser(),
    getPosts(),
    getComments(),
  ]);

  return <DashboardView user={user} posts={posts} comments={comments} />;
}
```

### Sequential with Suspense
```tsx
import { Suspense } from 'react';

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<UserSkeleton />}>
        <UserInfo />
      </Suspense>
      <Suspense fallback={<PostsSkeleton />}>
        <RecentPosts />
      </Suspense>
    </div>
  );
}
```

### Caching
```tsx
// Cached by default (static)
const data = await fetch('https://api.example.com/data');

// Revalidate every 60 seconds
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 60 }
});

// No cache (dynamic)
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store'
});
```

## Server Actions

```tsx
// app/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;

  // Validation
  if (!title || title.length < 3) {
    return { error: 'Title must be at least 3 characters' };
  }

  // Database operation
  await db.post.create({ data: { title, content } });

  // Revalidate and redirect
  revalidatePath('/posts');
  redirect('/posts');
}

// Usage in Client Component
'use client';

import { createPost } from './actions';
import { useFormStatus } from 'react-dom';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create Post'}
    </button>
  );
}

export function CreatePostForm() {
  return (
    <form action={createPost}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" />
      <SubmitButton />
    </form>
  );
}
```

## Layouts & Templates

### Root Layout
```tsx
// app/layout.tsx
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
```

### Nested Layout
```tsx
// app/(dashboard)/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <Sidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}
```

## Error Handling

```tsx
// app/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Loading UI

```tsx
// app/users/loading.tsx
export default function Loading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="h-4 bg-gray-200 rounded w-full mb-2" />
      <div className="h-4 bg-gray-200 rounded w-3/4" />
    </div>
  );
}
```

## Metadata

```tsx
// Static metadata
export const metadata = {
  title: 'My App',
  description: 'Welcome to my app',
};

// Dynamic metadata
export async function generateMetadata({ params }: Props) {
  const post = await getPost(params.id);
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      images: [post.image],
    },
  };
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Default to Server** | Use Server Components unless interactivity needed |
| **Colocate Data** | Fetch data where it's used |
| **Parallel Fetch** | Use Promise.all for independent data |
| **Suspense Boundaries** | Wrap slow components |
| **Server Actions** | Use for mutations, not GET |
| **Route Groups** | Organize without affecting URL |
| **Streaming** | Enable for large pages |
