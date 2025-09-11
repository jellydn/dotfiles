# React Style Guide

A comprehensive style guide for modern React development with React Query, React Hook Form, and Zod integration.

## Core Principles

- **Component Composition**: Build complex UIs from simple, reusable components
- **Data Fetching**: Use React Query for server state management
- **Form Handling**: Use React Hook Form with Zod validation for type-safe forms
- **Performance**: Optimize with proper memoization and code splitting
- **Accessibility**: Build inclusive components following WCAG guidelines
- **TypeScript First**: Leverage type safety throughout the component tree

## Table of Contents

1. [Component Patterns](#component-patterns)
2. [Data Fetching with React Query](#data-fetching-with-react-query)
3. [Forms with React Hook Form & Zod](#forms-with-react-hook-form--zod)
4. [State Management](#state-management)
5. [Performance Optimization](#performance-optimization)
6. [Accessibility](#accessibility)
7. [Testing Patterns](#testing-patterns)
8. [Modern Tooling](#modern-tooling)

---

## Component Patterns

### Component Structure and Naming

```tsx
// ✅ Good - Component file structure
// components/user/UserProfileCard.tsx
import { memo } from 'react';
import { cn } from '@/lib/utils';
import type { User } from '@/types/user';

interface UserProfileCardProps {
  user: User;
  showActions?: boolean;
  onEdit?: (user: User) => void;
  className?: string;
}

export const UserProfileCard = memo(({
  user,
  showActions = false,
  onEdit,
  className,
}: UserProfileCardProps) => {
  return (
    <div className={cn('bg-white rounded-lg shadow-md p-6', className)}>
      <div className="flex items-center space-x-4">
        <img
          src={user.avatar}
          alt={`${user.name}'s avatar`}
          className="w-16 h-16 rounded-full"
        />
        <div>
          <h3 className="text-lg font-semibold">{user.name}</h3>
          <p className="text-gray-600">{user.email}</p>
        </div>
      </div>
      
      {showActions && (
        <div className="mt-4 flex space-x-2">
          <button
            onClick={() => onEdit?.(user)}
            className="px-4 py-2 bg-blue-600 text-white rounded"
          >
            Edit Profile
          </button>
        </div>
      )}
    </div>
  );
});

UserProfileCard.displayName = 'UserProfileCard';
```

### Custom Hooks for Reusable Logic

```tsx
// ✅ Good - Custom hooks with TypeScript
// hooks/useLocalStorage.ts
import { useState, useEffect } from 'react';

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((prev: T) => T)) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error reading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((prev: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue];
}

// hooks/useDebounce.ts
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}
```

---

## Data Fetching with React Query

### Setup and Configuration

```tsx
// ✅ Good - React Query setup
// lib/queryClient.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
      retry: (failureCount, error: any) => {
        if (error?.status === 404) return false;
        return failureCount < 3;
      },
      refetchOnWindowFocus: false,
    },
    mutations: {
      retry: false,
    },
  },
});

// app.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <Routes>
          {/* Your routes */}
        </Routes>
      </Router>
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

### Query Patterns

```tsx
// ✅ Good - Typed API client
// lib/api.ts
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  avatar: z.string().url(),
});

const UsersResponseSchema = z.object({
  users: z.array(UserSchema),
  total: z.number(),
  page: z.number(),
});

export type User = z.infer<typeof UserSchema>;
export type UsersResponse = z.infer<typeof UsersResponseSchema>;

export const api = {
  async getUsers(page = 1): Promise<UsersResponse> {
    const response = await fetch(`/api/users?page=${page}`);
    if (!response.ok) throw new Error('Failed to fetch users');
    const data = await response.json();
    return UsersResponseSchema.parse(data);
  },

  async getUser(id: string): Promise<User> {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) throw new Error('Failed to fetch user');
    const data = await response.json();
    return UserSchema.parse(data);
  },

  async createUser(userData: Omit<User, 'id'>): Promise<User> {
    const response = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });
    if (!response.ok) throw new Error('Failed to create user');
    const data = await response.json();
    return UserSchema.parse(data);
  },
};

// hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api, type User } from '@/lib/api';

export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (page: number) => [...userKeys.lists(), page] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

export function useUsers(page = 1) {
  return useQuery({
    queryKey: userKeys.list(page),
    queryFn: () => api.getUsers(page),
  });
}

export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => api.getUser(id),
    enabled: !!id,
  });
}

export function useCreateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: api.createUser,
    onSuccess: (newUser) => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
      
      // Optimistically update the cache
      queryClient.setQueryData(userKeys.detail(newUser.id), newUser);
    },
  });
}
```

### Component Integration

```tsx
// ✅ Good - Component with React Query
// components/UsersList.tsx
import { useState } from 'react';
import { useUsers } from '@/hooks/useUsers';
import { UserProfileCard } from './UserProfileCard';
import { Spinner } from '@/components/ui/Spinner';
import { ErrorMessage } from '@/components/ui/ErrorMessage';

export function UsersList() {
  const [page, setPage] = useState(1);
  const { data, isLoading, error, isError } = useUsers(page);

  if (isLoading) {
    return (
      <div className="flex justify-center p-8">
        <Spinner size="lg" />
      </div>
    );
  }

  if (isError) {
    return (
      <ErrorMessage
        title="Failed to load users"
        message={error?.message || 'Something went wrong'}
        onRetry={() => window.location.reload()}
      />
    );
  }

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {data?.users.map((user) => (
          <UserProfileCard key={user.id} user={user} showActions />
        ))}
      </div>
      
      <div className="flex justify-center space-x-2">
        <button
          onClick={() => setPage(prev => Math.max(1, prev - 1))}
          disabled={page === 1}
          className="px-4 py-2 bg-gray-200 rounded disabled:opacity-50"
        >
          Previous
        </button>
        
        <span className="px-4 py-2">Page {page}</span>
        
        <button
          onClick={() => setPage(prev => prev + 1)}
          disabled={!data?.users.length}
          className="px-4 py-2 bg-gray-200 rounded disabled:opacity-50"
        >
          Next
        </button>
      </div>
    </div>
  );
}
```

---

## Forms with React Hook Form & Zod

### Form Schema and Validation

```tsx
// ✅ Good - Form schemas with Zod
// schemas/userForm.ts
import { z } from 'zod';

export const CreateUserFormSchema = z.object({
  name: z.string()
    .min(2, 'Name must be at least 2 characters')
    .max(50, 'Name must be less than 50 characters'),
  
  email: z.string()
    .email('Please enter a valid email address')
    .max(255, 'Email is too long'),
  
  age: z.number()
    .int('Age must be a whole number')
    .min(18, 'Must be at least 18 years old')
    .max(120, 'Age must be realistic'),
  
  role: z.enum(['admin', 'user', 'moderator'], {
    errorMap: () => ({ message: 'Please select a valid role' }),
  }),
  
  preferences: z.object({
    newsletter: z.boolean().default(false),
    notifications: z.boolean().default(true),
    theme: z.enum(['light', 'dark']).default('light'),
  }),
  
  tags: z.array(z.string().min(1)).max(5, 'Maximum 5 tags allowed'),
});

export type CreateUserFormData = z.infer<typeof CreateUserFormSchema>;
```

### Form Components

```tsx
// ✅ Good - Form with React Hook Form and Zod
// components/forms/CreateUserForm.tsx
import { useForm, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateUserFormSchema, type CreateUserFormData } from '@/schemas/userForm';
import { useCreateUser } from '@/hooks/useUsers';
import { toast } from 'sonner';

interface CreateUserFormProps {
  onSuccess?: (user: User) => void;
  onCancel?: () => void;
}

export function CreateUserForm({ onSuccess, onCancel }: CreateUserFormProps) {
  const createUser = useCreateUser();
  
  const {
    register,
    handleSubmit,
    control,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<CreateUserFormData>({
    resolver: zodResolver(CreateUserFormSchema),
    defaultValues: {
      preferences: {
        newsletter: false,
        notifications: true,
        theme: 'light',
      },
      tags: [],
    },
  });

  const onSubmit = async (data: CreateUserFormData) => {
    try {
      const user = await createUser.mutateAsync(data);
      toast.success('User created successfully!');
      reset();
      onSuccess?.(user);
    } catch (error) {
      toast.error('Failed to create user');
      console.error('Create user error:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Name Field */}
        <div>
          <label htmlFor="name" className="block text-sm font-medium mb-1">
            Name *
          </label>
          <input
            {...register('name')}
            id="name"
            type="text"
            className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
            aria-invalid={!!errors.name}
            aria-describedby={errors.name ? 'name-error' : undefined}
          />
          {errors.name && (
            <p id="name-error" className="text-red-600 text-sm mt-1">
              {errors.name.message}
            </p>
          )}
        </div>

        {/* Email Field */}
        <div>
          <label htmlFor="email" className="block text-sm font-medium mb-1">
            Email *
          </label>
          <input
            {...register('email')}
            id="email"
            type="email"
            className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
            aria-invalid={!!errors.email}
            aria-describedby={errors.email ? 'email-error' : undefined}
          />
          {errors.email && (
            <p id="email-error" className="text-red-600 text-sm mt-1">
              {errors.email.message}
            </p>
          )}
        </div>
      </div>

      {/* Age Field */}
      <div>
        <label htmlFor="age" className="block text-sm font-medium mb-1">
          Age *
        </label>
        <input
          {...register('age', { valueAsNumber: true })}
          id="age"
          type="number"
          min="18"
          max="120"
          className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
          aria-invalid={!!errors.age}
          aria-describedby={errors.age ? 'age-error' : undefined}
        />
        {errors.age && (
          <p id="age-error" className="text-red-600 text-sm mt-1">
            {errors.age.message}
          </p>
        )}
      </div>

      {/* Role Field */}
      <div>
        <label htmlFor="role" className="block text-sm font-medium mb-1">
          Role *
        </label>
        <Controller
          name="role"
          control={control}
          render={({ field }) => (
            <select
              {...field}
              id="role"
              className="w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              aria-invalid={!!errors.role}
              aria-describedby={errors.role ? 'role-error' : undefined}
            >
              <option value="">Select a role</option>
              <option value="user">User</option>
              <option value="admin">Admin</option>
              <option value="moderator">Moderator</option>
            </select>
          )}
        />
        {errors.role && (
          <p id="role-error" className="text-red-600 text-sm mt-1">
            {errors.role.message}
          </p>
        )}
      </div>

      {/* Preferences */}
      <fieldset className="space-y-3">
        <legend className="text-sm font-medium">Preferences</legend>
        
        <div className="flex items-center space-x-2">
          <input
            {...register('preferences.newsletter')}
            id="newsletter"
            type="checkbox"
            className="rounded"
          />
          <label htmlFor="newsletter" className="text-sm">
            Subscribe to newsletter
          </label>
        </div>

        <div className="flex items-center space-x-2">
          <input
            {...register('preferences.notifications')}
            id="notifications"
            type="checkbox"
            className="rounded"
          />
          <label htmlFor="notifications" className="text-sm">
            Enable notifications
          </label>
        </div>

        <div>
          <label htmlFor="theme" className="block text-sm mb-1">
            Theme
          </label>
          <Controller
            name="preferences.theme"
            control={control}
            render={({ field }) => (
              <select
                {...field}
                id="theme"
                className="px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500"
              >
                <option value="light">Light</option>
                <option value="dark">Dark</option>
              </select>
            )}
          />
        </div>
      </fieldset>

      {/* Form Actions */}
      <div className="flex space-x-4">
        <button
          type="submit"
          disabled={isSubmitting}
          className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {isSubmitting ? 'Creating...' : 'Create User'}
        </button>
        
        {onCancel && (
          <button
            type="button"
            onClick={onCancel}
            className="px-6 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
          >
            Cancel
          </button>
        )}
      </div>
    </form>
  );
}
```

### Reusable Form Components

```tsx
// ✅ Good - Reusable form field components
// components/forms/FormField.tsx
import { forwardRef } from 'react';
import { cn } from '@/lib/utils';

interface FormFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  description?: string;
}

export const FormField = forwardRef<HTMLInputElement, FormFieldProps>(
  ({ label, error, description, className, id, ...props }, ref) => {
    const fieldId = id || `field-${Math.random().toString(36).substr(2, 9)}`;
    
    return (
      <div className="space-y-1">
        <label htmlFor={fieldId} className="block text-sm font-medium">
          {label}
          {props.required && <span className="text-red-500 ml-1">*</span>}
        </label>
        
        {description && (
          <p className="text-sm text-gray-600">{description}</p>
        )}
        
        <input
          {...props}
          ref={ref}
          id={fieldId}
          className={cn(
            'w-full px-3 py-2 border rounded-md focus:ring-2 focus:ring-blue-500',
            error && 'border-red-500 focus:ring-red-500',
            className
          )}
          aria-invalid={!!error}
          aria-describedby={error ? `${fieldId}-error` : undefined}
        />
        
        {error && (
          <p id={`${fieldId}-error`} className="text-red-600 text-sm">
            {error}
          </p>
        )}
      </div>
    );
  }
);

FormField.displayName = 'FormField';
```

---

## Performance Optimization

### Memoization Patterns

```tsx
// ✅ Good - Strategic memoization
import { memo, useMemo, useCallback } from 'react';

interface ExpensiveComponentProps {
  data: ComplexData[];
  onItemClick: (id: string) => void;
  filter: string;
}

export const ExpensiveComponent = memo(({ 
  data, 
  onItemClick, 
  filter 
}: ExpensiveComponentProps) => {
  // Memoize expensive calculations
  const filteredData = useMemo(() => {
    return data.filter(item => 
      item.name.toLowerCase().includes(filter.toLowerCase())
    );
  }, [data, filter]);

  // Memoize event handlers to prevent child re-renders
  const handleItemClick = useCallback((id: string) => {
    onItemClick(id);
  }, [onItemClick]);

  return (
    <div>
      {filteredData.map(item => (
        <ExpensiveListItem
          key={item.id}
          item={item}
          onClick={handleItemClick}
        />
      ))}
    </div>
  );
});

ExpensiveComponent.displayName = 'ExpensiveComponent';
```

### Code Splitting and Lazy Loading

```tsx
// ✅ Good - Route-based code splitting
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';
import { Spinner } from '@/components/ui/Spinner';

const HomePage = lazy(() => import('@/pages/HomePage'));
const UserPage = lazy(() => import('@/pages/UserPage'));
const AdminPage = lazy(() => import('@/pages/AdminPage'));

export function AppRoutes() {
  return (
    <Suspense fallback={<Spinner size="lg" />}>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/users/:id" element={<UserPage />} />
        <Route path="/admin" element={<AdminPage />} />
      </Routes>
    </Suspense>
  );
}

// ✅ Good - Component-based lazy loading
import { useState, lazy, Suspense } from 'react';

const HeavyModal = lazy(() => import('@/components/HeavyModal'));

export function MyComponent() {
  const [showModal, setShowModal] = useState(false);

  return (
    <div>
      <button onClick={() => setShowModal(true)}>
        Open Modal
      </button>
      
      {showModal && (
        <Suspense fallback={<div>Loading modal...</div>}>
          <HeavyModal onClose={() => setShowModal(false)} />
        </Suspense>
      )}
    </div>
  );
}
```

---

## Best Practices Summary

### Modern React Patterns
1. **React Query**: Use for all server state management
2. **React Hook Form**: Use with Zod for type-safe form validation
3. **Component Composition**: Build complex UIs from simple components
4. **Custom Hooks**: Extract reusable logic into custom hooks
5. **TypeScript**: Full type safety throughout the component tree

### Performance & UX
6. **Memoization**: Use strategically for expensive calculations
7. **Code Splitting**: Lazy load routes and heavy components
8. **Loading States**: Provide feedback during async operations
9. **Error Boundaries**: Handle errors gracefully
10. **Accessibility**: Build inclusive components with proper ARIA

### Data Management
- **React Query**: Server state, caching, and synchronization
- **Zod**: Runtime validation and type inference
- **Form State**: React Hook Form for complex forms
- **Local State**: useState and useReducer for component state

---

*This React style guide covers modern patterns with React Query, React Hook Form, and Zod for building robust, type-safe applications.*