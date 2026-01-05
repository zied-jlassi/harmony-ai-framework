---
name: tailwind-design-system
displayName: "Tailwind Design System"
category: frontend-development
tier: 2
model: inherit
triggers:
  - "tailwind"
  - "design system"
  - "css"
  - "styling"
  - "theme"
---

# Tailwind Design System

> Create consistent design systems with Tailwind CSS.

## Theme Configuration

```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',  // Main
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
        secondary: {
          // ...similar scale
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['Fira Code', 'monospace'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};

export default config;
```

## Component Patterns

### Button Component
```tsx
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-primary-600 text-white hover:bg-primary-700 focus-visible:ring-primary-500',
        secondary: 'bg-secondary-100 text-secondary-900 hover:bg-secondary-200',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-50',
        ghost: 'hover:bg-gray-100',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  isLoading?: boolean;
}

export function Button({
  className,
  variant,
  size,
  isLoading,
  children,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(buttonVariants({ variant, size }), className)}
      disabled={isLoading}
      {...props}
    >
      {isLoading && <Spinner className="mr-2 h-4 w-4" />}
      {children}
    </button>
  );
}
```

### Card Component
```tsx
export function Card({ className, children }: CardProps) {
  return (
    <div className={cn(
      'rounded-lg border border-gray-200 bg-white shadow-sm',
      className
    )}>
      {children}
    </div>
  );
}

Card.Header = function CardHeader({ className, children }: CardProps) {
  return (
    <div className={cn('border-b border-gray-200 px-6 py-4', className)}>
      {children}
    </div>
  );
};

Card.Body = function CardBody({ className, children }: CardProps) {
  return (
    <div className={cn('px-6 py-4', className)}>
      {children}
    </div>
  );
};

Card.Footer = function CardFooter({ className, children }: CardProps) {
  return (
    <div className={cn('border-t border-gray-200 px-6 py-4', className)}>
      {children}
    </div>
  );
};
```

### Input Component
```tsx
const inputVariants = cva(
  'flex w-full rounded-md border bg-white px-3 py-2 text-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'border-gray-300 focus-visible:ring-primary-500',
        error: 'border-red-500 focus-visible:ring-red-500',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement>,
    VariantProps<typeof inputVariants> {
  error?: string;
}

export function Input({ className, variant, error, ...props }: InputProps) {
  return (
    <div>
      <input
        className={cn(inputVariants({ variant: error ? 'error' : variant }), className)}
        {...props}
      />
      {error && <p className="mt-1 text-sm text-red-600">{error}</p>}
    </div>
  );
}
```

## Utility Functions

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage
<div className={cn(
  'base-class',
  isActive && 'active-class',
  variant === 'primary' ? 'bg-blue-500' : 'bg-gray-500'
)} />
```

## Responsive Design

```tsx
// Mobile-first approach
<div className="
  grid grid-cols-1      /* Mobile: 1 column */
  sm:grid-cols-2        /* Small: 2 columns */
  md:grid-cols-3        /* Medium: 3 columns */
  lg:grid-cols-4        /* Large: 4 columns */
  gap-4
">
  {items.map(item => <Card key={item.id} />)}
</div>

// Hide/show based on screen size
<nav className="hidden md:flex">Desktop Nav</nav>
<nav className="flex md:hidden">Mobile Nav</nav>
```

## Dark Mode

```tsx
// tailwind.config.ts
module.exports = {
  darkMode: 'class', // or 'media'
  // ...
};

// Component
<div className="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
  <h1 className="text-2xl font-bold">Title</h1>
  <p className="text-gray-600 dark:text-gray-400">Description</p>
</div>

// Toggle
function ThemeToggle() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', isDark);
  }, [isDark]);

  return (
    <button onClick={() => setIsDark(!isDark)}>
      {isDark ? <SunIcon /> : <MoonIcon />}
    </button>
  );
}
```

## Animation Examples

```tsx
// Hover effects
<button className="transform transition hover:scale-105 hover:shadow-lg">
  Hover me
</button>

// Fade in on load
<div className="animate-fade-in">Content</div>

// Staggered children
<ul>
  {items.map((item, i) => (
    <li
      key={item.id}
      className="animate-slide-up"
      style={{ animationDelay: `${i * 100}ms` }}
    >
      {item.name}
    </li>
  ))}
</ul>

// Skeleton loading
<div className="animate-pulse">
  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2" />
  <div className="h-4 bg-gray-200 rounded w-1/2" />
</div>
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Use CVA** | Class Variance Authority for component variants |
| **cn() helper** | Merge classes without conflicts |
| **Mobile-first** | Start with mobile, add responsive |
| **Consistent spacing** | Use theme spacing scale |
| **Extract components** | Don't repeat class combinations |
| **Dark mode support** | Plan from the start |
| **Typography plugin** | For prose content |
