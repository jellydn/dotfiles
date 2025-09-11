# Next.js Style Guide

A comprehensive style guide for modern Next.js 15+ development using App Router and React Server Components.

## Core Principles

- **App Router First**: Use App Router for new projects, leverage Server Components by default
- **Performance by Design**: Optimize for Core Web Vitals and user experience
- **Type Safety**: Full TypeScript integration with proper typing
- **Server-First Mindset**: Use Server Components by default, Client Components when needed
- **Modern Patterns**: Leverage React 19 features and Next.js 15 optimizations

## Table of Contents

1. [Project Structure](#project-structure)
2. [App Router Patterns](#app-router-patterns)
3. [Server vs Client Components](#server-vs-client-components)
4. [Data Fetching](#data-fetching)
5. [React Query Integration](#react-query-integration)
6. [Routing & Navigation](#routing--navigation)
7. [Layouts & Pages](#layouts--pages)
8. [Performance Optimization](#performance-optimization)
9. [Modern Tooling](#modern-tooling)

---

## Project Structure

### Recommended Folder Structure

```
app/                    # App Router directory
├── (marketing)/        # Route groups (don't affect URL)
│   ├── about/
│   └── contact/
├── dashboard/
│   ├── layout.tsx      # Nested layout
│   ├── page.tsx        # Dashboard home
│   └── settings/
├── api/               # API routes
├── globals.css        # Global styles
└── layout.tsx         # Root layout

components/            # Reusable components
├── ui/               # Basic UI components (shadcn/ui style)
│   ├── button.tsx
│   ├── input.tsx
│   └── modal.tsx
└── features/         # Feature-specific components
    ├── auth/
    ├── dashboard/
    └── blog/

lib/                  # Utility functions and configurations
├── utils.ts         # General utilities
├── validations.ts   # Zod schemas
├── auth.ts          # Authentication logic
└── db.ts            # Database configuration

hooks/               # Custom React hooks
types/               # TypeScript type definitions
styles/              # CSS modules and global styles
public/              # Static assets
```

### Route Groups for Organization

```typescript
// ✅ Good - Use route groups for organization
app/
├── (auth)/
│   ├── login/page.tsx     // /login
│   └── register/page.tsx  // /register
├── (dashboard)/
│   ├── analytics/page.tsx // /analytics
│   └── settings/page.tsx  // /settings
└── (marketing)/
    ├── about/page.tsx     // /about
    └── contact/page.tsx   // /contact
```

---

## App Router Patterns

### File-Based Routing Conventions

```typescript
// ✅ Good - App Router file conventions
app/
├── page.tsx          # / (homepage)
├── layout.tsx        # Root layout
├── loading.tsx       # Loading UI
├── error.tsx         # Error UI
├── not-found.tsx     # 404 UI
├── global-error.tsx  # Global error boundary
└── template.tsx      # Template (re-renders on navigation)

// Dynamic routes
app/
├── blog/
│   └── [slug]/
│       └── page.tsx  # /blog/[slug]
├── shop/
│   └── [...slug]/
│       └── page.tsx  # /shop/[...slug] (catch-all)
└── optional/
    └── [[...slug]]/
        └── page.tsx  # /optional/[[...slug]] (optional catch-all)
```

### Page and Layout Components

```typescript
// ✅ Good - Server Component page with proper typing
interface PageProps {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

export default async function BlogPostPage({ params, searchParams }: PageProps) {
  const { slug } = await params;
  const { category } = await searchParams;
  
  const post = await getPost(slug);
  
  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  );
}

// ✅ Good - Layout with proper metadata
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Blog | My App',
  description: 'Latest blog posts and articles',
};

export default function BlogLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="max-w-4xl mx-auto px-4">
      <nav className="mb-8">
        <h2>Blog Navigation</h2>
      </nav>
      <main>{children}</main>
    </div>
  );
}
```

---

## Server vs Client Components

### Server Components (Default)

```typescript
// ✅ Good - Server Component for data fetching
import { Suspense } from 'react';
import { PostList } from '@/components/features/blog/post-list';
import { PostListSkeleton } from '@/components/ui/skeletons';

// Server Component by default
export default function BlogPage() {
  return (
    <div>
      <h1>Latest Posts</h1>
      <Suspense fallback={<PostListSkeleton />}>
        <PostList />
      </Suspense>
    </div>
  );
}

// Server Component for data fetching
async function PostList() {
  // Data fetching happens on server
  const posts = await getPosts();
  
  return (
    <div>
      {posts.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
```

### Client Components (When Needed)

```typescript
'use client';

// ✅ Good - Client Component for interactivity
import { useState, useEffect } from 'react';

interface SearchProps {
  initialQuery?: string;
}

export function SearchForm({ initialQuery = '' }: SearchProps) {
  const [query, setQuery] = useState(initialQuery);
  const [results, setResults] = useState([]);

  // Client-side state and effects
  useEffect(() => {
    if (query.length > 2) {
      searchPosts(query).then(setResults);
    }
  }, [query]);

  return (
    <form>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Search posts..."
      />
      <SearchResults results={results} />
    </form>
  );
}
```

### Composition Pattern

```typescript
// ✅ Good - Server Component composing Client Components
import { SearchForm } from '@/components/features/search/search-form';
import { UserProfile } from '@/components/features/auth/user-profile';

export default async function DashboardPage() {
  // Server-side data fetching
  const user = await getCurrentUser();
  const recentPosts = await getRecentPosts();

  return (
    <div>
      {/* Client Component for user interaction */}
      <UserProfile user={user} />
      
      {/* Client Component for search functionality */}
      <SearchForm />
      
      {/* Server Component for static content */}
      <RecentPosts posts={recentPosts} />
    </div>
  );
}
```

---

## Data Fetching

### Modern Data Fetching Patterns

```typescript
// ✅ Good - Different caching strategies
async function getData() {
  // Static data (cached until manually invalidated)
  const staticData = await fetch('https://api.example.com/static', {
    cache: 'force-cache', // default
  });

  // Dynamic data (refetched on every request)
  const dynamicData = await fetch('https://api.example.com/dynamic', {
    cache: 'no-store',
  });

  // Revalidated data (cached with time-based revalidation)
  const timedData = await fetch('https://api.example.com/timed', {
    next: { revalidate: 3600 }, // 1 hour
  });

  return {
    static: await staticData.json(),
    dynamic: await dynamicData.json(),
    timed: await timedData.json(),
  };
}

export default async function DataPage() {
  const data = await getData();
  
  return (
    <div>
      <h1>Data Dashboard</h1>
      <StaticSection data={data.static} />
      <DynamicSection data={data.dynamic} />
      <TimedSection data={data.timed} />
    </div>
  );
}
```

### Streaming with Suspense

```typescript
// ✅ Good - Streaming with granular loading states
import { Suspense } from 'react';

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <h1>Dashboard</h1>
      
      {/* Fast-loading content renders immediately */}
      <UserGreeting />
      
      {/* Slow content streams in separately */}
      <div className="grid grid-cols-2 gap-6">
        <Suspense fallback={<ChartSkeleton />}>
          <RevenueChart />
        </Suspense>
        
        <Suspense fallback={<TableSkeleton />}>
          <RecentOrders />
        </Suspense>
      </div>
      
      <Suspense fallback={<ListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  );
}

// Async Server Components for data fetching
async function RevenueChart() {
  const data = await getRevenueData();
  return <Chart data={data} />;
}

async function RecentOrders() {
  const orders = await getRecentOrders();
  return <OrderTable orders={orders} />;
}
```

### Error Boundaries and Loading States

```typescript
// error.tsx - Handles errors in the route segment
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px]">
      <h2>Something went wrong!</h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-600 text-white rounded"
      >
        Try again
      </button>
    </div>
  );
}

// loading.tsx - Shows while the page is loading
export default function Loading() {
  return (
    <div className="animate-pulse space-y-4">
      <div className="h-8 bg-gray-200 rounded w-1/4"></div>
      <div className="space-y-2">
        <div className="h-4 bg-gray-200 rounded"></div>
        <div className="h-4 bg-gray-200 rounded w-5/6"></div>
      </div>
    </div>
  );
}
```

---

## React Query Integration

### Setup and Configuration

```typescript
// lib/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        // With SSR, we usually want to set some default staleTime
        // above 0 to avoid refetching immediately on the client
        staleTime: 60 * 1000, // 1 minute
        retry: (failureCount, error: any) => {
          // Don't retry on 4xx errors
          if (error?.status >= 400 && error?.status < 500) {
            return false;
          }
          return failureCount < 3;
        },
      },
    },
  });
}

let browserQueryClient: QueryClient | undefined = undefined;

export function getQueryClient() {
  if (typeof window === 'undefined') {
    // Server: always make a new query client
    return makeQueryClient();
  } else {
    // Browser: make a new query client if we don't already have one
    if (!browserQueryClient) browserQueryClient = makeQueryClient();
    return browserQueryClient;
  }
}
```

```typescript
// app/providers.tsx
'use client';

import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { useState } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,
      },
    },
  }));

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

```typescript
// app/layout.tsx - Root layout with providers
import { Providers } from './providers';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}
```

### Server Components + React Query Pattern

```typescript
// app/posts/page.tsx - Server Component with initial data
import { HydrationBoundary, dehydrate } from '@tanstack/react-query';
import { getQueryClient } from '@/lib/query-client';
import { PostsList } from '@/components/posts/posts-list';
import { getPosts } from '@/lib/api/posts';

export default async function PostsPage() {
  const queryClient = getQueryClient();

  // Pre-fetch data on the server
  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: getPosts,
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <div>
        <h1>Posts</h1>
        {/* Client Component will use the prefetched data */}
        <PostsList />
      </div>
    </HydrationBoundary>
  );
}
```

```typescript
// components/posts/posts-list.tsx - Client Component
'use client';

import { useQuery } from '@tanstack/react-query';
import { getPosts } from '@/lib/api/posts';
import { PostCard } from './post-card';

export function PostsList() {
  const { data: posts, isLoading, error } = useQuery({
    queryKey: ['posts'],
    queryFn: getPosts,
  });

  if (isLoading) return <PostsSkeleton />;
  if (error) return <div>Error loading posts</div>;

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {posts?.map((post) => (
        <PostCard key={post.id} post={post} />
      ))}
    </div>
  );
}
```

### Dynamic Routes with Prefetching

```typescript
// app/posts/[slug]/page.tsx
import { HydrationBoundary, dehydrate } from '@tanstack/react-query';
import { getQueryClient } from '@/lib/query-client';
import { PostDetail } from '@/components/posts/post-detail';
import { getPost, getRelatedPosts } from '@/lib/api/posts';
import { notFound } from 'next/navigation';

interface PageProps {
  params: Promise<{ slug: string }>;
}

export default async function PostPage({ params }: PageProps) {
  const { slug } = await params;
  const queryClient = getQueryClient();

  try {
    // Prefetch main post data
    await queryClient.prefetchQuery({
      queryKey: ['post', slug],
      queryFn: () => getPost(slug),
    });

    // Prefetch related posts in parallel
    await queryClient.prefetchQuery({
      queryKey: ['posts', 'related', slug],
      queryFn: () => getRelatedPosts(slug),
    });
  } catch (error) {
    notFound();
  }

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <PostDetail slug={slug} />
    </HydrationBoundary>
  );
}
```

### Mutations with Server Actions

```typescript
// lib/api/posts.ts
import { z } from 'zod';

export const CreatePostSchema = z.object({
  title: z.string().min(1).max(100),
  content: z.string().min(1),
  categoryId: z.string().uuid(),
});

export type CreatePostInput = z.infer<typeof CreatePostSchema>;

export async function createPost(input: CreatePostInput) {
  const validated = CreatePostSchema.parse(input);
  
  const response = await fetch('/api/posts', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(validated),
  });

  if (!response.ok) {
    throw new Error('Failed to create post');
  }

  return response.json();
}
```

```typescript
// components/posts/create-post-form.tsx
'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { createPost, CreatePostSchema, type CreatePostInput } from '@/lib/api/posts';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';

export function CreatePostForm() {
  const router = useRouter();
  const queryClient = useQueryClient();

  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm<CreatePostInput>({
    resolver: zodResolver(CreatePostSchema),
  });

  const createPostMutation = useMutation({
    mutationFn: createPost,
    onSuccess: (newPost) => {
      // Invalidate and refetch posts list
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      
      // Optimistically add the new post to cache
      queryClient.setQueryData(['post', newPost.slug], newPost);
      
      // Navigate to the new post
      router.push(`/posts/${newPost.slug}`);
      reset();
    },
    onError: (error) => {
      console.error('Failed to create post:', error);
    },
  });

  const onSubmit = (data: CreatePostInput) => {
    createPostMutation.mutate(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <Input
          {...register('title')}
          placeholder="Post title"
          className={errors.title ? 'border-red-500' : ''}
        />
        {errors.title && (
          <p className="text-red-500 text-sm mt-1">{errors.title.message}</p>
        )}
      </div>

      <div>
        <Textarea
          {...register('content')}
          placeholder="Post content"
          rows={6}
          className={errors.content ? 'border-red-500' : ''}
        />
        {errors.content && (
          <p className="text-red-500 text-sm mt-1">{errors.content.message}</p>
        )}
      </div>

      <div>
        <Input
          {...register('categoryId')}
          placeholder="Category ID"
          className={errors.categoryId ? 'border-red-500' : ''}
        />
        {errors.categoryId && (
          <p className="text-red-500 text-sm mt-1">{errors.categoryId.message}</p>
        )}
      </div>

      <Button
        type="submit"
        disabled={createPostMutation.isPending}
        className="w-full"
      >
        {createPostMutation.isPending ? 'Creating...' : 'Create Post'}
      </Button>
    </form>
  );
}
```

### Infinite Queries for Pagination

```typescript
// components/posts/infinite-posts-list.tsx
'use client';

import { useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';
import { useEffect } from 'react';
import { getPostsPaginated } from '@/lib/api/posts';
import { PostCard } from './post-card';

export function InfinitePostsList() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
    isLoading,
    error,
  } = useInfiniteQuery({
    queryKey: ['posts', 'infinite'],
    queryFn: ({ pageParam = 1 }) => getPostsPaginated({ page: pageParam }),
    getNextPageParam: (lastPage, allPages) => {
      return lastPage.hasMore ? allPages.length + 1 : undefined;
    },
    initialPageParam: 1,
  });

  const { ref, inView } = useInView({
    threshold: 0,
    rootMargin: '100px',
  });

  useEffect(() => {
    if (inView && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, isFetchingNextPage, fetchNextPage]);

  if (isLoading) return <PostsSkeleton />;
  if (error) return <div>Error loading posts</div>;

  return (
    <div>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {data?.pages.map((page, pageIndex) =>
          page.posts.map((post, postIndex) => (
            <PostCard
              key={`${pageIndex}-${postIndex}-${post.id}`}
              post={post}
            />
          ))
        )}
      </div>

      {/* Loading trigger */}
      <div ref={ref} className="mt-8 flex justify-center">
        {isFetchingNextPage && <div>Loading more posts...</div>}
        {!hasNextPage && data?.pages[0].posts.length > 0 && (
          <div className="text-gray-500">No more posts to load</div>
        )}
      </div>
    </div>
  );
}
```

### Search with Debounced Queries

```typescript
// components/posts/search-posts.tsx
'use client';

import { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useDebounce } from '@/hooks/use-debounce';
import { searchPosts } from '@/lib/api/posts';
import { Input } from '@/components/ui/input';
import { PostCard } from './post-card';

export function SearchPosts() {
  const [searchTerm, setSearchTerm] = useState('');
  const debouncedSearch = useDebounce(searchTerm, 300);

  const {
    data: searchResults,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['posts', 'search', debouncedSearch],
    queryFn: () => searchPosts(debouncedSearch),
    enabled: debouncedSearch.length >= 2,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });

  const hasResults = searchResults && searchResults.length > 0;
  const showNoResults = debouncedSearch.length >= 2 && !isLoading && !hasResults;

  return (
    <div className="space-y-4">
      <Input
        type="text"
        placeholder="Search posts..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        className="w-full"
      />

      {isLoading && <div>Searching...</div>}
      
      {error && <div>Error searching posts</div>}
      
      {showNoResults && <div>No posts found for "{debouncedSearch}"</div>}

      {hasResults && (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {searchResults.map((post) => (
            <PostCard key={post.id} post={post} />
          ))}
        </div>
      )}
    </div>
  );
}
```

### React Query Best Practices with Next.js

```typescript
// lib/query-keys.ts - Centralized query key management
export const queryKeys = {
  posts: {
    all: ['posts'] as const,
    lists: () => [...queryKeys.posts.all, 'list'] as const,
    list: (filters: string) => [...queryKeys.posts.lists(), filters] as const,
    details: () => [...queryKeys.posts.all, 'detail'] as const,
    detail: (id: string) => [...queryKeys.posts.details(), id] as const,
    search: (term: string) => [...queryKeys.posts.all, 'search', term] as const,
  },
  users: {
    all: ['users'] as const,
    profile: (id: string) => [...queryKeys.users.all, 'profile', id] as const,
  },
} as const;

// Usage in components
const { data: posts } = useQuery({
  queryKey: queryKeys.posts.list('published'),
  queryFn: () => getPosts({ status: 'published' }),
});

// Invalidation becomes type-safe
queryClient.invalidateQueries({ queryKey: queryKeys.posts.all });
```

```typescript
// hooks/use-optimistic-mutation.ts - Optimistic updates pattern
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { queryKeys } from '@/lib/query-keys';

export function useOptimisticPostUpdate() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updatePost,
    onMutate: async (variables) => {
      // Cancel any outgoing refetches
      await queryClient.cancelQueries({ 
        queryKey: queryKeys.posts.detail(variables.id) 
      });

      // Snapshot the previous value
      const previousPost = queryClient.getQueryData(
        queryKeys.posts.detail(variables.id)
      );

      // Optimistically update to the new value
      queryClient.setQueryData(
        queryKeys.posts.detail(variables.id),
        (old: any) => ({ ...old, ...variables.updates })
      );

      return { previousPost };
    },
    onError: (err, variables, context) => {
      // Rollback on error
      if (context?.previousPost) {
        queryClient.setQueryData(
          queryKeys.posts.detail(variables.id),
          context.previousPost
        );
      }
    },
    onSettled: (data, error, variables) => {
      // Always refetch after error or success
      queryClient.invalidateQueries({ 
        queryKey: queryKeys.posts.detail(variables.id) 
      });
    },
  });
}
```

---

## Routing & Navigation

### Navigation Components

```typescript
'use client';

import { usePathname } from 'next/navigation';
import Link from 'next/link';
import { cn } from '@/lib/utils';

const navigation = [
  { name: 'Dashboard', href: '/dashboard' },
  { name: 'Posts', href: '/posts' },
  { name: 'Settings', href: '/settings' },
];

export function Navigation() {
  const pathname = usePathname();

  return (
    <nav className="space-y-1">
      {navigation.map((item) => (
        <Link
          key={item.name}
          href={item.href}
          className={cn(
            'block px-3 py-2 rounded-md text-sm font-medium transition-colors',
            pathname === item.href
              ? 'bg-blue-100 text-blue-700'
              : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
          )}
        >
          {item.name}
        </Link>
      ))}
    </nav>
  );
}
```

### Programmatic Navigation

```typescript
'use client';

import { useRouter } from 'next/navigation';
import { useTransition } from 'react';

export function CreatePostForm() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  async function handleSubmit(formData: FormData) {
    const result = await createPost(formData);
    
    if (result.success) {
      startTransition(() => {
        router.push(`/posts/${result.data.slug}`);
        router.refresh(); // Refresh server components
      });
    }
  }

  return (
    <form action={handleSubmit}>
      <input name="title" placeholder="Post title" />
      <textarea name="content" placeholder="Post content" />
      <button disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

---

## Performance Optimization

### Image Optimization

```typescript
import Image from 'next/image';

// ✅ Good - Optimized images with proper sizing
export function ProductCard({ product }: { product: Product }) {
  return (
    <div className="border rounded-lg overflow-hidden">
      <Image
        src={product.image}
        alt={product.name}
        width={400}
        height={300}
        className="w-full h-48 object-cover"
        sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
        priority={product.featured} // Above-the-fold images
      />
      <div className="p-4">
        <h3>{product.name}</h3>
        <p>{product.price}</p>
      </div>
    </div>
  );
}

// ✅ Good - Hero image with priority loading
export function HeroSection() {
  return (
    <section className="relative h-96">
      <Image
        src="/hero-image.jpg"
        alt="Hero image"
        fill
        className="object-cover"
        priority // Critical for LCP
        sizes="100vw"
      />
      <div className="relative z-10">
        <h1>Welcome to our site</h1>
      </div>
    </section>
  );
}
```

### Font Optimization

```typescript
// app/layout.tsx - Font optimization
import { Inter, Playfair_Display } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

const playfair = Playfair_Display({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-playfair',
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${playfair.variable}`}>
      <body className="font-sans">{children}</body>
    </html>
  );
}

// CSS usage
// .title { font-family: var(--font-playfair); }
```

### Bundle Optimization

```typescript
// ✅ Good - Dynamic imports for code splitting
import { lazy, Suspense } from 'react';

const HeavyChart = lazy(() => import('@/components/charts/heavy-chart'));
const VideoPlayer = lazy(() => import('@/components/media/video-player'));

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      
      <Suspense fallback={<ChartSkeleton />}>
        <HeavyChart />
      </Suspense>
      
      <Suspense fallback={<div>Loading video...</div>}>
        <VideoPlayer src="/demo.mp4" />
      </Suspense>
    </div>
  );
}
```

---

## Modern Tooling

### Biome Configuration for Next.js

```json
{
  "$schema": "https://biomejs.dev/schemas/1.8.0/schema.json",
  "files": {
    "include": [
      "app/**/*.{js,jsx,ts,tsx}",
      "components/**/*.{js,jsx,ts,tsx}",
      "lib/**/*.{js,ts}",
      "hooks/**/*.{js,ts}"
    ],
    "ignore": [
      "node_modules",
      ".next",
      "out",
      "*.config.js"
    ]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 80
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "suspicious": {
        "noExplicitAny": "error"
      },
      "correctness": {
        "useExhaustiveDependencies": "warn"
      },
      "style": {
        "useImportType": "error",
        "useConst": "error"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always",
      "trailingComma": "es5"
    }
  }
}
```

### TypeScript Configuration

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "ES2022"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
```

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "biome lint ./app ./components",
    "lint:fix": "biome lint --apply ./app ./components",
    "format": "biome format --write ./app ./components",
    "type-check": "tsc --noEmit",
    "check": "biome check --apply && npm run type-check",
    "ci": "biome ci && npm run type-check && next build"
  }
}
```

---

## Best Practices Summary

### Architecture & Structure
1. **App Router First**: Use App Router for new projects, migrate gradually
2. **Server Components Default**: Use Server Components by default, Client Components when needed
3. **Atomic Design**: Organize components by atoms, molecules, organisms, templates
4. **Route Groups**: Use parentheses for logical organization without URL impact
5. **Colocate Logic**: Keep related components, styles, and tests together

### Performance & SEO
6. **Streaming**: Use Suspense boundaries for progressive loading
7. **Image Optimization**: Always use Next.js Image component with proper sizing
8. **Font Loading**: Use next/font for optimized font loading
9. **Caching Strategy**: Choose appropriate caching for different data types
10. **Bundle Splitting**: Use dynamic imports for heavy components

### Development Workflow
- **Biome**: Use for fast formatting and linting (25x faster than Prettier)
- **TypeScript**: Full type safety with proper Next.js types
- **Turbopack**: Enable for faster development builds
- **Error Boundaries**: Implement proper error handling at route levels

---

*This style guide covers Next.js 15 with App Router, React Server Components, and modern development practices as of 2024.*