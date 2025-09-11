# TailwindCSS Style Guide

A comprehensive style guide for modern TailwindCSS development focusing on utility-first patterns, component composition, and design system integration.

## Core Principles

- **Utility-First Approach**: Compose complex components from simple utility classes
- **Design System Integration**: Use Tailwind as a foundation for consistent design tokens
- **Component Abstraction**: Extract reusable patterns while maintaining utility flexibility
- **Performance Optimization**: Leverage Tailwind's purging capabilities for optimal bundle sizes
- **Mobile-First Responsive**: Build responsive interfaces using mobile-first breakpoints
- **Maintainable Scale**: Organize utilities and components for long-term project growth

## Table of Contents

1. [Project Setup & Configuration](#project-setup--configuration)
2. [Utility Class Organization](#utility-class-organization)
3. [Component Patterns](#component-patterns)
4. [Responsive Design](#responsive-design)
5. [Dark Mode Implementation](#dark-mode-implementation)
6. [Design System Integration](#design-system-integration)
7. [Performance Optimization](#performance-optimization)
8. [Advanced Patterns](#advanced-patterns)
9. [Tooling & Automation](#tooling--automation)

---

## Project Setup & Configuration

### Modern Tailwind Configuration

```javascript
// tailwind.config.js - Modern v4 configuration
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{html,js,jsx,ts,tsx,vue,svelte}',
    './components/**/*.{js,jsx,ts,tsx}',
    './pages/**/*.{js,jsx,ts,tsx}',
    './app/**/*.{js,jsx,ts,tsx}',
  ],
  darkMode: 'class', // Enable class-based dark mode
  theme: {
    extend: {
      // Custom design tokens
      colors: {
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          500: '#0ea5e9',
          600: '#0284c7',
          900: '#0c4a6e',
        },
        gray: {
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          500: '#64748b',
          700: '#334155',
          900: '#0f172a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'bounce-gentle': 'bounceGentle 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(100%)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        bounceGentle: {
          '0%, 20%, 50%, 80%, 100%': { transform: 'translateY(0)' },
          '40%': { transform: 'translateY(-4px)' },
          '60%': { transform: 'translateY(-2px)' },
        },
      },
      // Container queries
      containers: {
        '4xs': '14rem',
        '3xs': '16rem',
        '2xs': '18rem',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/container-queries'),
    // Custom plugin for design system utilities
    function({ addComponents, addUtilities, theme }) {
      addComponents({
        '.btn': {
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          borderRadius: theme('borderRadius.lg'),
          fontSize: theme('fontSize.sm'),
          fontWeight: theme('fontWeight.medium'),
          padding: `${theme('spacing.2')} ${theme('spacing.4')}`,
          transition: 'all 150ms ease-in-out',
          '&:focus': {
            outline: 'none',
            boxShadow: `0 0 0 3px ${theme('colors.brand.500')}40`,
          },
        },
        '.card': {
          backgroundColor: theme('colors.white'),
          borderRadius: theme('borderRadius.xl'),
          boxShadow: theme('boxShadow.lg'),
          padding: theme('spacing.6'),
          '.dark &': {
            backgroundColor: theme('colors.gray.800'),
          },
        },
      });

      addUtilities({
        '.text-balance': {
          textWrap: 'balance',
        },
        '.text-pretty': {
          textWrap: 'pretty',
        },
      });
    },
  ],
};
```

### CSS Layer Organization

```css
/* styles/globals.css */
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* Custom base styles */
@layer base {
  :root {
    --brand-primary: 14 165 233;
    --brand-secondary: 59 130 246;
    --surface: 248 250 252;
    --surface-dark: 15 23 42;
  }

  .dark {
    --surface: 15 23 42;
    --surface-dark: 248 250 252;
  }

  html {
    scroll-behavior: smooth;
  }

  body {
    @apply antialiased text-gray-900 dark:text-gray-100;
    @apply bg-white dark:bg-gray-900;
    font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
  }

  /* Better focus styles */
  *:focus-visible {
    @apply outline-none ring-2 ring-brand-500 ring-offset-2 ring-offset-white dark:ring-offset-gray-900;
  }
}

/* Custom component layer */
@layer components {
  /* Form controls */
  .form-input {
    @apply block w-full rounded-lg border-gray-300 shadow-sm;
    @apply focus:border-brand-500 focus:ring-brand-500;
    @apply disabled:bg-gray-50 disabled:text-gray-500;
    @apply dark:bg-gray-800 dark:border-gray-600 dark:text-white;
  }

  .form-label {
    @apply block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2;
  }

  /* Button variants */
  .btn-primary {
    @apply bg-brand-500 text-white hover:bg-brand-600 active:bg-brand-700;
    @apply disabled:bg-gray-300 disabled:text-gray-500 disabled:cursor-not-allowed;
  }

  .btn-secondary {
    @apply bg-white text-gray-700 border border-gray-300;
    @apply hover:bg-gray-50 active:bg-gray-100;
    @apply dark:bg-gray-800 dark:text-gray-300 dark:border-gray-600;
    @apply dark:hover:bg-gray-700;
  }

  .btn-ghost {
    @apply text-gray-700 hover:bg-gray-100 active:bg-gray-200;
    @apply dark:text-gray-300 dark:hover:bg-gray-800 dark:active:bg-gray-700;
  }

  /* Layout components */
  .container-fluid {
    @apply mx-auto max-w-7xl px-4 sm:px-6 lg:px-8;
  }

  .section-padding {
    @apply py-12 sm:py-16 lg:py-20;
  }
}

/* Custom utilities */
@layer utilities {
  .text-shadow {
    text-shadow: 0 2px 4px rgb(0 0 0 / 0.1);
  }

  .text-shadow-lg {
    text-shadow: 0 4px 8px rgb(0 0 0 / 0.2);
  }

  .backface-hidden {
    backface-visibility: hidden;
  }

  .perspective-1000 {
    perspective: 1000px;
  }

  /* Scrollbar utilities */
  .scrollbar-thin {
    scrollbar-width: thin;
  }

  .scrollbar-none {
    scrollbar-width: none;
    -ms-overflow-style: none;
  }

  .scrollbar-none::-webkit-scrollbar {
    display: none;
  }
}
```

---

## Utility Class Organization

### Class Ordering Convention

```html
<!-- ✅ Good - Organized class order -->
<div class="
  relative flex items-center justify-between
  w-full max-w-md mx-auto p-6
  bg-white dark:bg-gray-800
  border border-gray-200 dark:border-gray-700
  rounded-xl shadow-lg
  transition-all duration-200
  hover:shadow-xl hover:scale-105
  focus:outline-none focus:ring-2 focus:ring-brand-500
  sm:max-w-lg md:max-w-xl lg:max-w-2xl
">
  <!-- Content -->
</div>

<!-- ❌ Bad - Random class order -->
<div class="
  hover:shadow-xl bg-white rounded-xl p-6 flex
  w-full transition-all shadow-lg border relative
  focus:ring-2 dark:bg-gray-800 items-center
  max-w-md mx-auto justify-between duration-200
">
  <!-- Content -->
</div>
```

### Recommended Class Order

1. **Layout & Position**: `relative`, `absolute`, `flex`, `grid`, `block`, `inline`
2. **Box Model**: `w-*`, `h-*`, `m-*`, `p-*`
3. **Typography**: `text-*`, `font-*`, `leading-*`, `tracking-*`
4. **Background & Borders**: `bg-*`, `border-*`, `rounded-*`
5. **Effects**: `shadow-*`, `opacity-*`, `transform`
6. **Interactions**: `transition-*`, `hover:*`, `focus:*`, `active:*`
7. **Responsive**: `sm:*`, `md:*`, `lg:*`, `xl:*`, `2xl:*`

### Class Grouping Strategies

```html
<!-- ✅ Good - Logical grouping with line breaks -->
<button class="
  relative inline-flex items-center justify-center
  px-4 py-2 min-w-[120px]
  text-sm font-medium text-white
  bg-brand-500 border border-transparent rounded-lg
  shadow-sm ring-1 ring-black/5
  transition-colors duration-150
  hover:bg-brand-600 focus:bg-brand-600
  focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2
  disabled:opacity-50 disabled:cursor-not-allowed
  sm:text-base sm:px-6 sm:py-3
">
  Submit
</button>

<!-- Alternative: Use template literals for better readability -->
<div className={`
  flex items-center gap-4 p-6
  bg-white dark:bg-gray-900
  rounded-xl shadow-lg
  transition-all duration-300
  ${isActive ? 'ring-2 ring-brand-500' : ''}
  ${size === 'large' ? 'text-lg p-8' : 'text-sm p-4'}
`}>
  <!-- Content -->
</div>
```

---

## Component Patterns

### React Component Composition

```tsx
// components/ui/Button.tsx
import { type VariantProps, cva } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const buttonVariants = cva(
  // Base styles
  'inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        default: 'bg-brand-500 text-white hover:bg-brand-600 focus-visible:ring-brand-500',
        destructive: 'bg-red-500 text-white hover:bg-red-600 focus-visible:ring-red-500',
        outline: 'border border-gray-300 bg-transparent hover:bg-gray-100 dark:border-gray-600 dark:hover:bg-gray-800',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200 dark:bg-gray-800 dark:text-gray-100 dark:hover:bg-gray-700',
        ghost: 'hover:bg-gray-100 dark:hover:bg-gray-800',
        link: 'text-brand-500 underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-10 px-4 py-2',
        sm: 'h-9 rounded-md px-3',
        lg: 'h-11 rounded-md px-8',
        icon: 'h-10 w-10',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);

export { Button, buttonVariants };
```

### Card Component Pattern

```tsx
// components/ui/Card.tsx
interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'outlined' | 'elevated';
  padding?: 'none' | 'sm' | 'md' | 'lg';
}

const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, variant = 'default', padding = 'md', children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          // Base styles
          'rounded-xl border bg-white text-gray-950 dark:bg-gray-950 dark:text-gray-50',
          // Variants
          {
            'border-gray-200 dark:border-gray-800': variant === 'default',
            'border-gray-300 dark:border-gray-700': variant === 'outlined',
            'border-gray-200 shadow-lg dark:border-gray-800': variant === 'elevated',
          },
          // Padding
          {
            'p-0': padding === 'none',
            'p-4': padding === 'sm',
            'p-6': padding === 'md',
            'p-8': padding === 'lg',
          },
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);

const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn('flex flex-col space-y-1.5 p-6', className)}
      {...props}
    />
  )
);

const CardTitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn('text-2xl font-semibold leading-none tracking-tight', className)}
      {...props}
    />
  )
);

export { Card, CardHeader, CardTitle };
```

### Layout Components

```tsx
// components/layout/Container.tsx
interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  padding?: boolean;
}

const Container: React.FC<ContainerProps> = ({ 
  children, 
  size = 'lg', 
  padding = true, 
  className,
  ...props 
}) => {
  return (
    <div
      className={cn(
        'mx-auto w-full',
        {
          'max-w-3xl': size === 'sm',
          'max-w-5xl': size === 'md',
          'max-w-7xl': size === 'lg',
          'max-w-screen-2xl': size === 'xl',
          'max-w-none': size === 'full',
        },
        padding && 'px-4 sm:px-6 lg:px-8',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};

// components/layout/Stack.tsx
interface StackProps extends React.HTMLAttributes<HTMLDivElement> {
  spacing?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  direction?: 'horizontal' | 'vertical';
  align?: 'start' | 'center' | 'end' | 'stretch';
  justify?: 'start' | 'center' | 'end' | 'between' | 'around';
}

const Stack: React.FC<StackProps> = ({
  children,
  spacing = 'md',
  direction = 'vertical',
  align = 'stretch',
  justify = 'start',
  className,
  ...props
}) => {
  return (
    <div
      className={cn(
        'flex',
        // Direction
        direction === 'horizontal' ? 'flex-row' : 'flex-col',
        // Spacing
        direction === 'horizontal' 
          ? {
              'gap-2': spacing === 'xs',
              'gap-3': spacing === 'sm',
              'gap-4': spacing === 'md',
              'gap-6': spacing === 'lg',
              'gap-8': spacing === 'xl',
            }
          : {
              'space-y-2': spacing === 'xs',
              'space-y-3': spacing === 'sm',
              'space-y-4': spacing === 'md',
              'space-y-6': spacing === 'lg',
              'space-y-8': spacing === 'xl',
            },
        // Alignment
        {
          'items-start': align === 'start',
          'items-center': align === 'center',
          'items-end': align === 'end',
          'items-stretch': align === 'stretch',
        },
        // Justify
        {
          'justify-start': justify === 'start',
          'justify-center': justify === 'center',
          'justify-end': justify === 'end',
          'justify-between': justify === 'between',
          'justify-around': justify === 'around',
        },
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
```

---

## Responsive Design

### Mobile-First Breakpoint Strategy

```html
<!-- ✅ Good - Mobile-first approach -->
<div class="
  text-center sm:text-left
  px-4 sm:px-6 lg:px-8
  py-8 sm:py-12 lg:py-16
">
  <h1 class="
    text-2xl sm:text-3xl lg:text-4xl xl:text-5xl
    font-bold leading-tight sm:leading-normal
    mb-4 sm:mb-6 lg:mb-8
  ">
    Responsive Heading
  </h1>
  
  <div class="
    grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4
    gap-4 sm:gap-6 lg:gap-8
  ">
    <!-- Grid items -->
  </div>
</div>

<!-- ❌ Bad - Desktop-first approach -->
<div class="
  text-left max-sm:text-center
  px-8 max-lg:px-6 max-sm:px-4
">
  <!-- Don't use max-* modifiers as primary strategy -->
</div>
```

### Container Queries for Component-Level Responsiveness

```html
<!-- Modern container queries -->
<div class="@container">
  <div class="
    flex flex-col @md:flex-row
    gap-4 @md:gap-6 @lg:gap-8
    p-4 @md:p-6 @lg:p-8
  ">
    <div class="
      @md:w-1/3 @lg:w-1/4
      @md:shrink-0
    ">
      <!-- Sidebar content -->
    </div>
    
    <div class="
      flex-1
      @md:min-w-0
    ">
      <!-- Main content -->
    </div>
  </div>
</div>

<!-- Named container queries for complex layouts -->
<div class="@container/main">
  <div class="@container/sidebar">
    <div class="
      grid grid-cols-1 @md/main:grid-cols-3
      @lg/sidebar:grid-cols-2
    ">
      <!-- Complex responsive grid -->
    </div>
  </div>
</div>
```

### Responsive Typography Scale

```html
<!-- Fluid typography with proper scaling -->
<h1 class="
  text-3xl sm:text-4xl md:text-5xl lg:text-6xl xl:text-7xl
  font-bold tracking-tight
  leading-[1.1] sm:leading-[1.2]
">
  Display Heading
</h1>

<h2 class="
  text-2xl sm:text-3xl md:text-4xl lg:text-5xl
  font-semibold tracking-tight
  leading-tight sm:leading-normal
">
  Section Heading
</h2>

<p class="
  text-base sm:text-lg md:text-xl
  leading-relaxed sm:leading-loose
  max-w-prose
">
  Body text with optimal reading length and line height.
</p>

<!-- Responsive text alignment and spacing -->
<div class="
  text-center sm:text-left
  space-y-4 sm:space-y-6 md:space-y-8
">
  <!-- Content with responsive spacing -->
</div>
```

### Responsive Image Patterns

```html
<!-- Responsive images with proper aspect ratios -->
<div class="
  relative overflow-hidden
  aspect-square sm:aspect-video lg:aspect-[4/3]
  rounded-lg sm:rounded-xl lg:rounded-2xl
">
  <img
    src="/image.jpg"
    alt="Description"
    class="
      absolute inset-0 w-full h-full
      object-cover object-center
      transition-transform duration-300
      hover:scale-105
    "
  />
</div>

<!-- Responsive image grid -->
<div class="
  grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6
  gap-2 sm:gap-4 md:gap-6
">
  <div class="
    aspect-square overflow-hidden
    rounded-md sm:rounded-lg
  ">
    <img
      src="/thumb.jpg"
      alt="Thumbnail"
      class="w-full h-full object-cover hover:scale-110 transition-transform duration-200"
    />
  </div>
  <!-- More grid items -->
</div>
```

---

## Dark Mode Implementation

### Comprehensive Dark Mode Setup

```tsx
// lib/theme-provider.tsx
'use client';

import { createContext, useContext, useEffect, useState } from 'react';

type Theme = 'dark' | 'light' | 'system';

type ThemeProviderProps = {
  children: React.ReactNode;
  defaultTheme?: Theme;
  storageKey?: string;
};

type ThemeProviderState = {
  theme: Theme;
  setTheme: (theme: Theme) => void;
  resolvedTheme: 'dark' | 'light';
};

const ThemeProviderContext = createContext<ThemeProviderState | undefined>(undefined);

export function ThemeProvider({
  children,
  defaultTheme = 'system',
  storageKey = 'ui-theme',
  ...props
}: ThemeProviderProps) {
  const [theme, setTheme] = useState<Theme>(defaultTheme);
  const [resolvedTheme, setResolvedTheme] = useState<'dark' | 'light'>('light');

  useEffect(() => {
    const root = window.document.documentElement;
    const systemTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    
    root.classList.remove('light', 'dark');
    
    const effectiveTheme = theme === 'system' ? systemTheme : theme;
    root.classList.add(effectiveTheme);
    setResolvedTheme(effectiveTheme);
  }, [theme]);

  const value = {
    theme,
    setTheme: (theme: Theme) => {
      localStorage.setItem(storageKey, theme);
      setTheme(theme);
    },
    resolvedTheme,
  };

  return (
    <ThemeProviderContext.Provider {...props} value={value}>
      {children}
    </ThemeProviderContext.Provider>
  );
}

export const useTheme = () => {
  const context = useContext(ThemeProviderContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};
```

### Dark Mode Component Patterns

```html
<!-- Comprehensive dark mode styling -->
<div class="
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-gray-100
  border border-gray-200 dark:border-gray-800
">
  <!-- Header with dark mode support -->
  <header class="
    bg-gray-50 dark:bg-gray-800
    border-b border-gray-200 dark:border-gray-700
    px-6 py-4
  ">
    <h2 class="
      text-lg font-semibold
      text-gray-900 dark:text-gray-100
    ">
      Card Title
    </h2>
  </header>

  <!-- Content area -->
  <div class="p-6 space-y-4">
    <p class="
      text-gray-600 dark:text-gray-400
      leading-relaxed
    ">
      Supporting text that adapts to theme changes.
    </p>

    <!-- Interactive elements -->
    <button class="
      bg-blue-500 hover:bg-blue-600 dark:bg-blue-600 dark:hover:bg-blue-700
      text-white font-medium px-4 py-2 rounded-lg
      focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 focus:ring-offset-2
      focus:ring-offset-white dark:focus:ring-offset-gray-900
      transition-colors duration-200
    ">
      Action Button
    </button>

    <!-- Form inputs -->
    <input
      type="text"
      placeholder="Enter text..."
      class="
        w-full px-3 py-2 rounded-lg border
        bg-white dark:bg-gray-800
        border-gray-300 dark:border-gray-600
        text-gray-900 dark:text-gray-100
        placeholder-gray-500 dark:placeholder-gray-400
        focus:border-blue-500 dark:focus:border-blue-400
        focus:ring-1 focus:ring-blue-500 dark:focus:ring-blue-400
      "
    />
  </div>
</div>
```

### Dark Mode Color Strategy

```css
/* Custom dark mode color system */
@layer base {
  :root {
    /* Light mode colors */
    --color-primary: 59 130 246;
    --color-primary-foreground: 255 255 255;
    --color-secondary: 148 163 184;
    --color-secondary-foreground: 15 23 42;
    --color-background: 255 255 255;
    --color-foreground: 15 23 42;
    --color-muted: 248 250 252;
    --color-muted-foreground: 100 116 139;
    --color-border: 226 232 240;
    --color-input: 226 232 240;
    --color-ring: 59 130 246;
  }

  .dark {
    /* Dark mode colors */
    --color-primary: 59 130 246;
    --color-primary-foreground: 255 255 255;
    --color-secondary: 71 85 105;
    --color-secondary-foreground: 248 250 252;
    --color-background: 2 6 23;
    --color-foreground: 248 250 252;
    --color-muted: 15 23 42;
    --color-muted-foreground: 148 163 184;
    --color-border: 30 41 59;
    --color-input: 30 41 59;
    --color-ring: 59 130 246;
  }
}

/* Use CSS custom properties with Tailwind */
.bg-primary { background-color: rgb(var(--color-primary)); }
.text-foreground { color: rgb(var(--color-foreground)); }
.border-input { border-color: rgb(var(--color-input)); }
```

---

## Design System Integration

### Design Token Configuration

```javascript
// design-tokens.js - Centralized design system
const spacing = {
  0: '0',
  px: '1px',
  0.5: '0.125rem',
  1: '0.25rem',
  1.5: '0.375rem',
  2: '0.5rem',
  2.5: '0.625rem',
  3: '0.75rem',
  3.5: '0.875rem',
  4: '1rem',
  5: '1.25rem',
  6: '1.5rem',
  7: '1.75rem',
  8: '2rem',
  9: '2.25rem',
  10: '2.5rem',
  11: '2.75rem',
  12: '3rem',
  14: '3.5rem',
  16: '4rem',
  20: '5rem',
  24: '6rem',
  28: '7rem',
  32: '8rem',
  36: '9rem',
  40: '10rem',
  44: '11rem',
  48: '12rem',
  52: '13rem',
  56: '14rem',
  60: '15rem',
  64: '16rem',
  72: '18rem',
  80: '20rem',
  96: '24rem',
};

const typography = {
  fontFamily: {
    sans: ['Inter', 'system-ui', 'sans-serif'],
    serif: ['Georgia', 'Times New Roman', 'serif'],
    mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
  },
  fontSize: {
    xs: ['0.75rem', { lineHeight: '1rem' }],
    sm: ['0.875rem', { lineHeight: '1.25rem' }],
    base: ['1rem', { lineHeight: '1.5rem' }],
    lg: ['1.125rem', { lineHeight: '1.75rem' }],
    xl: ['1.25rem', { lineHeight: '1.75rem' }],
    '2xl': ['1.5rem', { lineHeight: '2rem' }],
    '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
    '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
    '5xl': ['3rem', { lineHeight: '1' }],
    '6xl': ['3.75rem', { lineHeight: '1' }],
    '7xl': ['4.5rem', { lineHeight: '1' }],
    '8xl': ['6rem', { lineHeight: '1' }],
    '9xl': ['8rem', { lineHeight: '1' }],
  },
  fontWeight: {
    thin: '100',
    extralight: '200',
    light: '300',
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
    extrabold: '800',
    black: '900',
  },
};

const colors = {
  // Brand colors
  brand: {
    50: '#f0f9ff',
    100: '#e0f2fe',
    200: '#bae6fd',
    300: '#7dd3fc',
    400: '#38bdf8',
    500: '#0ea5e9',
    600: '#0284c7',
    700: '#0369a1',
    800: '#075985',
    900: '#0c4a6e',
    950: '#082f49',
  },
  
  // Semantic colors
  success: {
    50: '#f0fdf4',
    500: '#22c55e',
    900: '#14532d',
  },
  warning: {
    50: '#fffbeb',
    500: '#f59e0b',
    900: '#78350f',
  },
  error: {
    50: '#fef2f2',
    500: '#ef4444',
    900: '#7f1d1d',
  },
  
  // Neutral colors
  gray: {
    50: '#f8fafc',
    100: '#f1f5f9',
    200: '#e2e8f0',
    300: '#cbd5e1',
    400: '#94a3b8',
    500: '#64748b',
    600: '#475569',
    700: '#334155',
    800: '#1e293b',
    900: '#0f172a',
    950: '#020617',
  },
};

export { spacing, typography, colors };
```

### Component Library Structure

```typescript
// components/design-system/index.ts
// Centralized component exports for design system

// Layout
export { Container } from './layout/Container';
export { Stack } from './layout/Stack';
export { Grid } from './layout/Grid';
export { Flex } from './layout/Flex';

// Typography
export { Heading } from './typography/Heading';
export { Text } from './typography/Text';
export { Code } from './typography/Code';

// Form Components
export { Button } from './forms/Button';
export { Input } from './forms/Input';
export { Textarea } from './forms/Textarea';
export { Select } from './forms/Select';
export { Checkbox } from './forms/Checkbox';
export { Radio } from './forms/Radio';

// Feedback
export { Alert } from './feedback/Alert';
export { Toast } from './feedback/Toast';
export { Spinner } from './feedback/Spinner';
export { Progress } from './feedback/Progress';

// Overlays
export { Modal } from './overlays/Modal';
export { Drawer } from './overlays/Drawer';
export { Popover } from './overlays/Popover';
export { Tooltip } from './overlays/Tooltip';

// Data Display
export { Card } from './data-display/Card';
export { Table } from './data-display/Table';
export { Badge } from './data-display/Badge';
export { Avatar } from './data-display/Avatar';

// Navigation
export { Tabs } from './navigation/Tabs';
export { Breadcrumb } from './navigation/Breadcrumb';
export { Pagination } from './navigation/Pagination';
```

### Compound Component Pattern

```tsx
// components/ui/Card.tsx - Advanced compound component
interface CardContextType {
  variant: 'default' | 'outlined' | 'elevated';
}

const CardContext = createContext<CardContextType | undefined>(undefined);

const useCardContext = () => {
  const context = useContext(CardContext);
  if (!context) {
    throw new Error('Card components must be used within a Card');
  }
  return context;
};

// Root Card component
interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'outlined' | 'elevated';
  children: React.ReactNode;
}

const CardRoot = ({ variant = 'default', children, className, ...props }: CardProps) => {
  return (
    <CardContext.Provider value={{ variant }}>
      <div
        className={cn(
          'rounded-xl bg-white text-gray-950 dark:bg-gray-950 dark:text-gray-50',
          {
            'border border-gray-200 dark:border-gray-800': variant === 'default',
            'border-2 border-gray-300 dark:border-gray-700': variant === 'outlined',
            'border border-gray-200 shadow-lg dark:border-gray-800': variant === 'elevated',
          },
          className
        )}
        {...props}
      >
        {children}
      </div>
    </CardContext.Provider>
  );
};

// Card sub-components
const CardHeader = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => {
  const { variant } = useCardContext();
  
  return (
    <div
      className={cn(
        'flex flex-col space-y-1.5 p-6',
        variant === 'elevated' && 'border-b border-gray-100 dark:border-gray-800',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};

const CardContent = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => (
  <div className={cn('p-6 pt-0', className)} {...props}>
    {children}
  </div>
);

const CardFooter = ({ className, children, ...props }: React.HTMLAttributes<HTMLDivElement>) => (
  <div className={cn('flex items-center p-6 pt-0', className)} {...props}>
    {children}
  </div>
);

// Compose the final Card component
export const Card = Object.assign(CardRoot, {
  Header: CardHeader,
  Content: CardContent,
  Footer: CardFooter,
});

// Usage
// <Card variant="elevated">
//   <Card.Header>
//     <h3>Title</h3>
//   </Card.Header>
//   <Card.Content>
//     <p>Content</p>
//   </Card.Content>
//   <Card.Footer>
//     <Button>Action</Button>
//   </Card.Footer>
// </Card>
```

---

## Performance Optimization

### CSS Purging and Optimization

```javascript
// tailwind.config.js - Optimized for production
module.exports = {
  content: [
    './src/**/*.{js,jsx,ts,tsx}',
    './components/**/*.{js,jsx,ts,tsx}',
    './pages/**/*.{js,jsx,ts,tsx}',
    './app/**/*.{js,jsx,ts,tsx}',
    // Include any files that might contain Tailwind classes
    './stories/**/*.{js,jsx,ts,tsx}',
    './docs/**/*.{md,mdx}',
  ],
  
  // Safelist classes that might be generated dynamically
  safelist: [
    // Dynamic grid patterns
    'grid-cols-1',
    'grid-cols-2',
    'grid-cols-3',
    'grid-cols-4',
    'grid-cols-5',
    'grid-cols-6',
    
    // Dynamic color variations
    {
      pattern: /bg-(red|green|blue|yellow|purple|pink|indigo)-(100|200|300|400|500|600|700|800|900)/,
      variants: ['hover', 'focus', 'dark'],
    },
    
    // Animation classes that might be added via JavaScript
    {
      pattern: /animate-(spin|ping|pulse|bounce)/,
    },
  ],
  
  // Block unused CSS from being generated
  blocklist: [
    'container', // If you have custom container implementation
  ],
  
  theme: {
    extend: {
      // Only extend what you actually use
    },
  },
  
  plugins: [
    // Only include plugins you actually use
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
};
```

### Build Optimization

```javascript
// next.config.js - Next.js optimization
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizeCss: true, // Enable CSS optimization
  },
  
  webpack: (config, { dev, isServer }) => {
    // Optimize Tailwind CSS in production
    if (!dev && !isServer) {
      config.optimization.splitChunks.cacheGroups.styles = {
        name: 'styles',
        test: /\.(css|scss)$/,
        chunks: 'all',
        enforce: true,
      };
    }
    
    return config;
  },
};

module.exports = nextConfig;
```

### Bundle Analysis

```bash
# package.json scripts for analyzing bundle size
{
  "scripts": {
    "analyze": "ANALYZE=true next build",
    "build:analyze": "cross-env ANALYZE=true next build",
    "bundle:analyze": "npx @next/bundle-analyzer",
    "tailwind:analyze": "npx tailwindcss-analyzer build/static/css/*.css"
  }
}
```

### Critical CSS Strategy

```tsx
// components/CriticalCSS.tsx - Above-the-fold optimization
const CriticalCSS = () => {
  return (
    <style jsx>{`
      /* Critical path CSS - only above-the-fold styles */
      .hero-section {
        @apply min-h-screen flex items-center justify-center;
        @apply bg-gradient-to-br from-blue-600 to-purple-700;
        @apply text-white text-center;
      }
      
      .hero-title {
        @apply text-4xl md:text-6xl font-bold mb-6;
        @apply bg-clip-text text-transparent bg-gradient-to-r from-white to-blue-100;
      }
      
      .hero-subtitle {
        @apply text-xl md:text-2xl font-light mb-8 max-w-2xl;
      }
      
      .cta-button {
        @apply inline-flex items-center px-8 py-4;
        @apply bg-white text-blue-600 rounded-full font-semibold;
        @apply hover:bg-blue-50 transition-colors duration-200;
        @apply shadow-lg hover:shadow-xl;
      }
    `}</style>
  );
};
```

---

## Advanced Patterns

### Dynamic Class Generation

```tsx
// utils/dynamic-classes.ts
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Dynamic class generation with type safety
type ColorVariant = 'red' | 'green' | 'blue' | 'yellow' | 'purple';
type SizeVariant = 'sm' | 'md' | 'lg' | 'xl';

const generateColorClasses = (color: ColorVariant, intensity: number = 500) => ({
  background: `bg-${color}-${intensity}`,
  text: `text-${color}-${intensity}`,
  border: `border-${color}-${intensity}`,
  ring: `ring-${color}-${intensity}`,
});

const generateSizeClasses = (size: SizeVariant) => {
  const sizeMap = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
    xl: 'px-8 py-4 text-xl',
  };
  return sizeMap[size];
};

// Usage in components
const DynamicButton = ({ color, size, children }: {
  color: ColorVariant;
  size: SizeVariant;
  children: React.ReactNode;
}) => {
  const colorClasses = generateColorClasses(color);
  const sizeClasses = generateSizeClasses(size);
  
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center font-medium rounded-lg',
        'focus:outline-none focus:ring-2 focus:ring-offset-2',
        'transition-colors duration-200',
        colorClasses.background,
        colorClasses.ring,
        sizeClasses,
        'text-white hover:opacity-90'
      )}
    >
      {children}
    </button>
  );
};
```

### Animation and Transition Patterns

```css
/* Custom animations in CSS layer */
@layer utilities {
  .animate-fade-in {
    animation: fadeIn 0.5s ease-in-out;
  }
  
  .animate-slide-up {
    animation: slideUp 0.3s ease-out;
  }
  
  .animate-scale-in {
    animation: scaleIn 0.2s ease-out;
  }
  
  .animate-shimmer {
    animation: shimmer 2s infinite;
    background-size: 200% 100%;
    background-image: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.4),
      transparent
    );
  }
  
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  
  @keyframes slideUp {
    from { 
      opacity: 0;
      transform: translateY(20px);
    }
    to { 
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  @keyframes scaleIn {
    from { 
      opacity: 0;
      transform: scale(0.9);
    }
    to { 
      opacity: 1;
      transform: scale(1);
    }
  }
  
  @keyframes shimmer {
    0% { background-position: -200% 0; }
    100% { background-position: 200% 0; }
  }
}
```

### Advanced Layout Patterns

```html
<!-- Masonry-style layout with CSS Grid -->
<div class="
  columns-1 sm:columns-2 lg:columns-3 xl:columns-4
  gap-4 sm:gap-6 lg:gap-8
  space-y-4 sm:space-y-6 lg:space-y-8
">
  <div class="break-inside-avoid mb-4 sm:mb-6 lg:mb-8">
    <!-- Masonry item -->
  </div>
</div>

<!-- Responsive sidebar layout -->
<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <!-- Sidebar -->
  <aside class="
    fixed inset-y-0 left-0 z-50 w-64
    transform transition-transform duration-300 ease-in-out
    bg-white dark:bg-gray-800 border-r border-gray-200 dark:border-gray-700
    lg:translate-x-0
    {{ sidebarOpen ? 'translate-x-0' : '-translate-x-full' }}
  ">
    <!-- Sidebar content -->
  </aside>
  
  <!-- Main content -->
  <main class="lg:pl-64">
    <div class="px-4 sm:px-6 lg:px-8 py-8">
      <!-- Page content -->
    </div>
  </main>
  
  <!-- Mobile overlay -->
  <div class="
    fixed inset-0 z-40 bg-gray-600 bg-opacity-75
    transition-opacity duration-300 ease-linear
    lg:hidden
    {{ sidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none' }}
  "></div>
</div>

<!-- Complex grid with auto-fit and responsive gaps -->
<div class="
  grid grid-cols-[repeat(auto-fit,_minmax(300px,_1fr))]
  gap-4 sm:gap-6 lg:gap-8
  auto-rows-max
">
  <!-- Auto-fitting grid items -->
</div>
```

---

## Tooling & Automation

### Prettier Configuration

```javascript
// .prettierrc.js
module.exports = {
  plugins: ['prettier-plugin-tailwindcss'],
  tailwindConfig: './tailwind.config.js',
  tailwindFunctions: ['clsx', 'cn', 'cva'],
  semi: true,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'es5',
  printWidth: 100,
  // Tailwind-specific options
  tailwindPreserveDuplicates: false,
  tailwindRemoveDeprecatedClasses: true,
};
```

### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    'next/core-web-vitals',
    'plugin:tailwindcss/recommended',
  ],
  plugins: ['tailwindcss'],
  rules: {
    // Tailwind-specific rules
    'tailwindcss/classnames-order': 'error',
    'tailwindcss/enforces-negative-arbitrary-values': 'error',
    'tailwindcss/enforces-shorthand': 'error',
    'tailwindcss/migration-from-tailwind-2': 'error',
    'tailwindcss/no-arbitrary-value': 'off', // Allow arbitrary values
    'tailwindcss/no-custom-classname': 'off', // Allow custom classes
    'tailwindcss/no-contradicting-classname': 'error',
    'tailwindcss/no-unnecessary-arbitrary-value': 'error',
  },
  settings: {
    tailwindcss: {
      config: './tailwind.config.js',
      cssFiles: [
        '**/*.css',
        '!**/node_modules',
        '!**/.*',
        '!**/dist',
        '!**/build',
      ],
    },
  },
};
```

### VSCode Configuration

```json
// .vscode/settings.json
{
  "tailwindCSS.includeLanguages": {
    "typescript": "javascript",
    "typescriptreact": "javascript"
  },
  "tailwindCSS.experimental.classRegex": [
    ["cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"],
    ["cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"],
    ["cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ],
  "tailwindCSS.classAttributes": [
    "class",
    "className",
    "ngClass",
    "class:list"
  ],
  "css.validate": false,
  "editor.quickSuggestions": {
    "strings": true
  },
  "editor.autoClosingBrackets": "always",
  "emmet.includeLanguages": {
    "typescript": "html",
    "typescriptreact": "html"
  }
}
```

### Build Scripts and Automation

```json
// package.json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:css": "stylelint '**/*.css' --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "tailwind:build": "tailwindcss -i ./src/styles/globals.css -o ./dist/styles.css --watch",
    "tailwind:optimize": "tailwindcss -i ./src/styles/globals.css -o ./dist/styles.css --minify",
    "analyze:css": "npx tailwindcss-analyzer build/static/css/*.css",
    "check": "npm run format:check && npm run lint && npm run type-check",
    "pre-commit": "lint-staged"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "prettier --write",
      "eslint --fix"
    ],
    "*.{css,scss}": [
      "prettier --write",
      "stylelint --fix"
    ]
  }
}
```

---

## Best Practices Summary

### Architecture & Organization
1. **Utility-First Mindset**: Compose components from utility classes rather than creating custom CSS
2. **Component Abstraction**: Extract reusable patterns into components while maintaining utility flexibility
3. **Design System Integration**: Use Tailwind as the foundation for a cohesive design system
4. **Consistent Class Ordering**: Follow a logical class ordering convention for maintainability
5. **Mobile-First Responsive**: Always design for mobile first, then enhance for larger screens

### Performance & Optimization
6. **CSS Purging**: Ensure unused CSS is removed in production builds
7. **Critical Path CSS**: Inline critical above-the-fold styles for faster initial rendering
8. **Bundle Analysis**: Regularly analyze CSS bundle size and optimize accordingly
9. **Container Queries**: Use container queries for component-level responsiveness
10. **Animation Performance**: Use transform and opacity for smooth animations

### Development Workflow
11. **Tool Integration**: Use Prettier plugin for automatic class sorting and formatting
12. **Type Safety**: Implement type-safe component APIs with proper TypeScript integration
13. **Dark Mode Strategy**: Implement comprehensive dark mode support from the start
14. **Testing Strategy**: Test component variants and responsive behavior systematically
15. **Documentation**: Maintain a component library with usage examples and guidelines

### Code Quality & Maintainability
- **Biome**: Use for fast, consistent formatting and linting
- **Class Variance Authority**: Implement type-safe component variants
- **Tailwind Merge**: Properly merge and override class conflicts
- **Custom Properties**: Use CSS custom properties for dynamic theming
- **Component Composition**: Favor composition over inheritance for flexible APIs

---

*This style guide covers modern TailwindCSS development practices, focusing on utility-first design, component composition, and scalable architecture patterns as of 2024.*