# TypeScript Style Guide

A comprehensive style guide for modern TypeScript development following industry best practices and clean code principles.

## Core Principles

- **Type Safety First**: Leverage TypeScript's type system for robust, maintainable code
- **Clean Code**: Write readable, reusable, and refactorable software
- **Single Responsibility**: Each function and class should do one thing well
- **Meaningful Names**: Use descriptive, pronounceable, searchable names
- **Modern Patterns**: Use latest TypeScript features and established patterns
- **Performance**: Leverage fast, Rust-based tooling for instant feedback

## Table of Contents

1. [Types & Interfaces](#types--interfaces)
2. [Variables & Constants](#variables--constants)
3. [Functions](#functions)
4. [Classes](#classes)
5. [Modules & Imports](#modules--imports)
6. [Error Handling](#error-handling)
7. [Modern TypeScript Features](#modern-typescript-features)
8. [Clean Code Patterns](#clean-code-patterns)
9. [Modern Tooling](#modern-tooling)

---

## Types & Interfaces

### Prefer interfaces over type aliases for object types

```typescript
// ❌ Bad
type User = {
  id: number;
  name: string;
  email: string;
};

// ✅ Good
interface User {
  readonly id: number;
  name: string;
  email: string;
}
```

### Use readonly for immutable properties

```typescript
// ❌ Bad
interface Config {
  host: string;
  port: number;
  database: string;
}

// ✅ Good
interface Config {
  readonly host: string;
  readonly port: number;
  readonly database: string;
}

// For arrays
const numbers: ReadonlyArray<number> = [1, 2, 3];
// numbers.push(4); // Error: Property 'push' does not exist
```

### Use discriminated unions for complex state

```typescript
// ✅ Good
type ApiResponse<T> = 
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string };

function handleResponse<T>(response: ApiResponse<T>) {
  switch (response.status) {
    case 'loading':
      return 'Loading...';
    case 'success':
      return response.data; // TypeScript knows data exists
    case 'error':
      return `Error: ${response.error}`; // TypeScript knows error exists
  }
}
```

### Use generic constraints effectively

```typescript
// ❌ Bad
function getId<T>(obj: T): any {
  return (obj as any).id;
}

// ✅ Good
interface HasId {
  id: string | number;
}

function getId<T extends HasId>(obj: T): T['id'] {
  return obj.id;
}
```

### Use branded types for sensitive data

```typescript
// ✅ Good - Create branded types for type safety
type UserId = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  // Validation logic here
  return id as UserId;
}

function sendEmail(userId: UserId, email: Email) {
  // Type system prevents mixing up parameters
}
```

---

## Variables & Constants

### Use meaningful and searchable names

```typescript
// ❌ Bad - What is 'd'? What is '86400000'?
const d = new Date();
const u = users.filter(x => x.active);
setTimeout(cleanup, 86400000);

// ✅ Good - Names tell a story
const currentDate = new Date();
const activeUsers = users.filter(user => user.active);
const MILLISECONDS_IN_DAY = 86_400_000;
setTimeout(cleanup, MILLISECONDS_IN_DAY);
```

### Avoid redundant context in type definitions

```typescript
// ❌ Bad
interface Car {
  carMake: string;
  carModel: string;
  carColor: string;
}

function printCar(car: Car): void {
  console.log(`${car.carMake} ${car.carModel} (${car.carColor})`);
}

// ✅ Good
interface Car {
  make: string;
  model: string;
  color: string;
}

function printCar(car: Car): void {
  console.log(`${car.make} ${car.model} (${car.color})`);
}
```

### Use const assertions for immutable data

```typescript
// ❌ Bad
const colors = ['red', 'green', 'blue']; // string[]

// ✅ Good  
const colors = ['red', 'green', 'blue'] as const; // readonly ["red", "green", "blue"]

// ✅ Good - Object const assertion
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} as const;
```

---

## Functions

### Limit function arguments (ideally ≤ 2)

```typescript
// ❌ Bad - Too many parameters
function createUser(
  firstName: string,
  lastName: string,
  email: string,
  age: number,
  isActive: boolean
): User {
  // ...
}

// ✅ Good - Use object parameters with interface
interface CreateUserParams {
  firstName: string;
  lastName: string;
  email: string;
  age: number;
  isActive: boolean;
}

function createUser(params: CreateUserParams): User {
  // ...
}

createUser({
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
  age: 30,
  isActive: true
});
```

### Use proper return types

```typescript
// ❌ Bad - No return type
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ✅ Good - Explicit return type
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ✅ Good - Let TypeScript infer when obvious
function double(x: number) {
  return x * 2; // return type inferred as number
}
```

### Use type guards for type narrowing

```typescript
// ✅ Good
function isString(value: unknown): value is string {
  return typeof value === 'string';
}

function processValue(value: unknown) {
  if (isString(value)) {
    return value.toUpperCase(); // TypeScript knows it's a string
  }
  throw new Error('Value must be a string');
}
```

### Use function overloads for complex signatures

```typescript
// ✅ Good
function createElement(tag: 'div'): HTMLDivElement;
function createElement(tag: 'span'): HTMLSpanElement;
function createElement(tag: string): HTMLElement;
function createElement(tag: string): HTMLElement {
  return document.createElement(tag);
}
```

---

## Classes

### Use access modifiers appropriately

```typescript
// ✅ Good
class BankAccount {
  readonly accountNumber: string;
  private balance = 0;
  protected accountType: string;

  constructor(accountNumber: string, accountType: string) {
    this.accountNumber = accountNumber;
    this.accountType = accountType;
  }

  public getBalance(): number {
    return this.balance;
  }

  protected validateTransaction(amount: number): boolean {
    return amount > 0 && amount <= this.balance;
  }

  private logTransaction(type: string, amount: number): void {
    console.log(`${type}: ${amount}`);
  }
}
```

### Use parameter properties for cleaner constructors

```typescript
// ❌ Bad
class User {
  private id: string;
  private name: string;
  private email: string;

  constructor(id: string, name: string, email: string) {
    this.id = id;
    this.name = name;
    this.email = email;
  }
}

// ✅ Good
class User {
  constructor(
    private readonly id: string,
    private name: string,
    private email: string
  ) {}
}
```

### Implement method chaining for fluent APIs

```typescript
// ✅ Good
class QueryBuilder {
  private table = '';
  private conditions: string[] = [];
  private orderBy = '';

  from(table: string): this {
    this.table = table;
    return this;
  }

  where(condition: string): this {
    this.conditions.push(condition);
    return this;
  }

  order(field: string): this {
    this.orderBy = field;
    return this;
  }

  build(): string {
    // Build query string
    return `SELECT * FROM ${this.table}...`;
  }
}

// Usage
const query = new QueryBuilder()
  .from('users')
  .where('age > 18')
  .order('name')
  .build();
```

---

## Modules & Imports

### Use modern ES modules

```typescript
// ❌ Bad
const utils = require('./utils');
module.exports = MyClass;

// ✅ Good
import { formatDate, calculateAge } from './utils.js';
export default class MyClass {}
```

### Use type-only imports when appropriate

```typescript
// ✅ Good
import type { User } from './types.js';
import { createUser } from './user-service.js';

function processUser(user: User): void {
  // Use User as type only
}
```

### Group and organize imports logically

```typescript
// ✅ Good
// Node.js built-ins
import { readFile } from 'fs/promises';
import { join } from 'path';

// External libraries
import axios from 'axios';
import { z } from 'zod';

// Internal modules
import type { User, ApiResponse } from './types.js';
import { logger } from './utils/logger.js';
import { validateUser } from './validators/user-validator.js';

// Relative imports
import './styles.css';
```

### Use namespace imports for large APIs

```typescript
// ✅ Good for large APIs
import * as fs from 'fs/promises';
import * as path from 'path';

// ✅ Good for selective imports
import { readFile, writeFile } from 'fs/promises';
```

---

## Error Handling

### Use custom error classes

```typescript
// ✅ Good
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string,
    public readonly code: string
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}

class NetworkError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number
  ) {
    super(message);
    this.name = 'NetworkError';
  }
}
```

### Use Result types for error handling

```typescript
// ✅ Good - Result type pattern
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

async function fetchUser(id: string): Promise<Result<User, string>> {
  try {
    const user = await api.getUser(id);
    return { success: true, data: user };
  } catch (error) {
    return { success: false, error: 'Failed to fetch user' };
  }
}

// Usage
const userResult = await fetchUser('123');
if (userResult.success) {
  console.log(userResult.data.name); // TypeScript knows data exists
} else {
  console.error(userResult.error); // TypeScript knows error exists
}
```

### Use proper async/await error handling

```typescript
// ✅ Good
async function processData(id: string): Promise<ProcessedData> {
  try {
    const rawData = await fetchData(id);
    const validatedData = validateData(rawData);
    const processedData = await transformData(validatedData);
    
    return processedData;
  } catch (error) {
    logger.error('Failed to process data:', { id, error });
    
    if (error instanceof ValidationError) {
      throw new ProcessingError(`Invalid data: ${error.message}`);
    }
    
    throw new ProcessingError('Failed to process data');
  }
}
```

---

## Modern TypeScript Features

### Use Template Literal Types

```typescript
// ✅ Good - Template literal types for API endpoints
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type ApiEndpoint = `/api/${string}`;
type HttpUrl = `http${'s' | ''}://${string}`;

function apiCall<T>(method: HttpMethod, endpoint: ApiEndpoint): Promise<T> {
  // ...
}

// ✅ Good - Template literal types for CSS
type CssUnit = 'px' | 'em' | 'rem' | '%' | 'vh' | 'vw';
type CssSize = `${number}${CssUnit}`;

function setWidth(element: HTMLElement, width: CssSize) {
  element.style.width = width;
}
```

### Use Conditional Types

```typescript
// ✅ Good - Conditional types
type ApiResponse<T> = T extends string 
  ? { text: T } 
  : T extends number 
  ? { count: T }
  : { data: T };

// ✅ Good - Extract function parameters
type Parameters<T> = T extends (...args: infer P) => any ? P : never;
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : any;
```

### Use Mapped Types and Key Remapping

```typescript
// ✅ Good - Make all properties optional
type Partial<T> = {
  [P in keyof T]?: T[P];
};

// ✅ Good - Create getters for all properties
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

interface User {
  name: string;
  age: number;
}

// Results in: { getName: () => string; getAge: () => number; }
type UserGetters = Getters<User>;
```

### Use satisfies operator

```typescript
// ✅ Good - satisfies operator (TypeScript 4.9+)
const colors = {
  red: '#ff0000',
  green: '#00ff00',
  blue: '#0000ff'
} satisfies Record<string, string>;

// colors.red is inferred as '#ff0000', not string
// colors.yellow would be an error
```

---

## Data Validation with Zod

### Schema Definition and Type Inference

```typescript
// ✅ Good - Zod schemas with TypeScript integration
import { z } from 'zod';

// User schema with validation rules
export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email().max(255),
  name: z.string().min(2).max(100).trim(),
  age: z.number().int().min(13).max(120),
  role: z.enum(['admin', 'user', 'moderator']),
  isActive: z.boolean().default(true),
  createdAt: z.date(),
  preferences: z.object({
    theme: z.enum(['light', 'dark']).default('light'),
    notifications: z.boolean().default(true),
    language: z.string().regex(/^[a-z]{2}$/).default('en'),
  }),
  tags: z.array(z.string()).max(10).default([]),
});

// Infer TypeScript type from Zod schema
export type User = z.infer<typeof UserSchema>;

// Partial schemas for different use cases
export const CreateUserSchema = UserSchema.omit({ 
  id: true, 
  createdAt: true 
});

export const UpdateUserSchema = UserSchema.partial().omit({ 
  id: true, 
  createdAt: true 
});

export type CreateUserRequest = z.infer<typeof CreateUserSchema>;
export type UpdateUserRequest = z.infer<typeof UpdateUserSchema>;
```

### Advanced Zod Patterns

```typescript
// ✅ Good - Complex validation with transformations
export const ProductSchema = z.object({
  name: z.string()
    .min(1, 'Product name is required')
    .max(200, 'Product name too long')
    .transform(val => val.trim()),
  
  price: z.string()
    .regex(/^\d+(\.\d{2})?$/, 'Invalid price format')
    .transform(val => parseFloat(val))
    .refine(val => val > 0, 'Price must be positive'),
  
  category: z.enum(['electronics', 'clothing', 'books', 'home']),
  
  tags: z.string()
    .transform(val => val.split(',').map(tag => tag.trim()))
    .pipe(z.array(z.string().min(1)).max(5)),
  
  metadata: z.record(z.unknown()).optional(),
  
  // Conditional validation
  discountPrice: z.number().optional(),
}).refine(
  data => !data.discountPrice || data.discountPrice < data.price,
  {
    message: 'Discount price must be less than regular price',
    path: ['discountPrice'],
  }
);

// ✅ Good - API response schemas
export const ApiResponseSchema = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    success: z.boolean(),
    data: dataSchema.optional(),
    error: z.object({
      code: z.string(),
      message: z.string(),
      details: z.record(z.unknown()).optional(),
    }).optional(),
    pagination: z.object({
      page: z.number(),
      limit: z.number(),
      total: z.number(),
    }).optional(),
  });

// Usage
export const UserListResponseSchema = ApiResponseSchema(z.array(UserSchema));
export type UserListResponse = z.infer<typeof UserListResponseSchema>;
```

### Runtime Validation Utilities

```typescript
// ✅ Good - Validation utilities
export class ValidationService {
  static validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
    const result = schema.safeParse(data);
    
    if (!result.success) {
      throw new ValidationError(
        'Validation failed',
        result.error.errors.map(err => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }))
      );
    }
    
    return result.data;
  }

  static async validateAsync<T>(
    schema: z.ZodSchema<T>, 
    data: unknown
  ): Promise<T> {
    const result = await schema.safeParseAsync(data);
    
    if (!result.success) {
      throw new ValidationError(
        'Async validation failed',
        result.error.errors.map(err => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }))
      );
    }
    
    return result.data;
  }

  static createValidator<T>(schema: z.ZodSchema<T>) {
    return (data: unknown): data is T => {
      return schema.safeParse(data).success;
    };
  }
}

// ✅ Good - Form validation hook
export function useValidation<T>(schema: z.ZodSchema<T>) {
  return {
    validate: (data: unknown) => ValidationService.validate(schema, data),
    isValid: ValidationService.createValidator(schema),
    schema,
  };
}
```

### Environment and Configuration Validation

```typescript
// ✅ Good - Environment validation with Zod
export const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  REDIS_URL: z.string().url().optional(),
  
  // API Keys with custom validation
  STRIPE_PUBLIC_KEY: z.string().startsWith('pk_'),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  
  // Feature flags
  ENABLE_ANALYTICS: z.string()
    .transform(val => val.toLowerCase() === 'true')
    .default(false),
  
  // Array from comma-separated string
  ALLOWED_ORIGINS: z.string()
    .transform(val => val.split(',').map(origin => origin.trim()))
    .pipe(z.array(z.string().url())),
});

export const env = EnvSchema.parse(process.env);

// ✅ Good - Config validation
export const AppConfigSchema = z.object({
  database: z.object({
    host: z.string(),
    port: z.number().int().min(1).max(65535),
    name: z.string(),
    ssl: z.boolean().default(true),
  }),
  
  cache: z.object({
    ttl: z.number().int().positive(),
    maxSize: z.number().int().positive(),
  }),
  
  features: z.object({
    enableNewUI: z.boolean().default(false),
    maxFileSize: z.number().int().positive().default(10485760), // 10MB
  }),
});

export type AppConfig = z.infer<typeof AppConfigSchema>;
```

---

## Clean Code Patterns

### Eliminate duplicate code with abstractions

```typescript
// ❌ Bad - Duplicate logic
function showDeveloperList(developers: Developer[]) {
  developers.forEach((developer) => {
    const expectedSalary = developer.calculateExpectedSalary();
    const experience = developer.getExperience();
    const githubLink = developer.getGithubLink();

    render({ expectedSalary, experience, githubLink });
  });
}

function showManagerList(managers: Manager[]) {
  managers.forEach((manager) => {
    const expectedSalary = manager.calculateExpectedSalary();
    const experience = manager.getExperience();
    const portfolio = manager.getMBAProjects();

    render({ expectedSalary, experience, portfolio });
  });
}

// ✅ Good - Abstract common pattern
interface Employee {
  calculateExpectedSalary(): number;
  getExperience(): number;
  getExtraDetails(): Record<string, any>;
}

class Developer implements Employee {
  calculateExpectedSalary(): number { /* */ }
  getExperience(): number { /* */ }
  getExtraDetails() {
    return { githubLink: this.githubLink };
  }
}

class Manager implements Employee {
  calculateExpectedSalary(): number { /* */ }
  getExperience(): number { /* */ }
  getExtraDetails() {
    return { portfolio: this.portfolio };
  }
}

function showEmployeeList(employees: Employee[]) {
  employees.forEach((employee) => {
    const expectedSalary = employee.calculateExpectedSalary();
    const experience = employee.getExperience();
    const extra = employee.getExtraDetails();

    render({ expectedSalary, experience, extra });
  });
}
```

### Use the Dependency Inversion Principle

```typescript
// ❌ Bad - Depends on concrete implementations
class ReportReader {
  async read(path: string): Promise<ReportData> {
    const text = await readFile(path, 'UTF8');
    
    if (path.endsWith('.xml')) {
      // Parse XML
    } else if (path.endsWith('.json')) {
      // Parse JSON
    }
  }
}

// ✅ Good - Depends on abstraction
interface Formatter {
  parse<T>(content: string): T;
}

class XmlFormatter implements Formatter {
  parse<T>(content: string): T {
    // XML parsing logic
  }
}

class JsonFormatter implements Formatter {
  parse<T>(content: string): T {
    // JSON parsing logic
  }
}

class ReportReader {
  constructor(private readonly formatter: Formatter) {}

  async read(path: string): Promise<ReportData> {
    const text = await readFile(path, 'UTF8');
    return this.formatter.parse<ReportData>(text);
  }
}

// Usage
const xmlReader = new ReportReader(new XmlFormatter());
const jsonReader = new ReportReader(new JsonFormatter());
```

### Keep functions close to their callers

```typescript
// ✅ Good - Functions ordered by call hierarchy
class PerformanceReview {
  constructor(private readonly employee: Employee) {}

  // Main public method at top
  review() {
    this.getPeerReviews();
    this.getManagerReview();
    this.getSelfReview();
    // ...
  }

  // Called functions follow immediately
  private getPeerReviews() {
    const peers = this.lookupPeers();
    // ...
  }

  private lookupPeers() {
    return db.lookup(this.employee.id, 'peers');
  }

  private getManagerReview() {
    const manager = this.lookupManager();
    // ...
  }

  private lookupManager() {
    return db.lookup(this.employee.id, 'manager');
  }

  private getSelfReview() {
    // ...
  }
}
```

---

## Modern Tooling

### Biome - All-in-One Toolchain (Recommended)

**Why Biome?** 25x faster than Prettier, 15x faster than ESLint. Full TypeScript support.

#### Installation & Setup

```bash
npm install --save-dev @biomejs/biome
npx @biomejs/biome init
```

#### Biome Configuration (biome.json)

```json
{
  "$schema": "https://biomejs.dev/schemas/1.8.0/schema.json",
  "files": {
    "include": ["src/**/*.ts", "src/**/*.tsx"],
    "ignore": ["node_modules", "dist", "build", "*.d.ts"]
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
        "noExplicitAny": "error",
        "noDoubleEquals": "error"
      },
      "style": {
        "useConst": "error",
        "useTemplate": "error",
        "noVar": "error"
      },
      "correctness": {
        "noUnusedVariables": "error",
        "useExhaustiveDependencies": "warn"
      }
    }
  },
  "typescript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always",
      "trailingComma": "es5"
    }
  }
}
```

#### Package.json Scripts (Biome)

```json
{
  "scripts": {
    "lint": "biome lint ./src",
    "lint:fix": "biome lint --apply ./src",
    "format": "biome format --write ./src",
    "check": "biome check --apply ./src",
    "ci": "biome ci ./src",
    "type-check": "tsc --noEmit"
  }
}
```

---

### TypeScript Configuration (tsconfig.json)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM"],
    
    // Type Checking
    "strict": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    
    // Modules
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    // Output
    "outDir": "./dist",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // Performance
    "skipLibCheck": true,
    "incremental": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

---

### oxlint for Ultra-Fast Linting

```bash
# Quick setup
npx --yes oxlint@latest

# With TypeScript support
npm install -g oxlint
```

#### Oxlint Configuration (.oxlintrc.json)

```json
{
  "$schema": "./node_modules/oxlint/configuration_schema.json",
  "categories": {
    "correctness": "warn",
    "suspicious": "warn", 
    "pedantic": "warn"
  },
  "rules": {
    "typescript/no-explicit-any": "error",
    "typescript/no-unused-vars": "error",
    "typescript/prefer-as-const": "warn",
    "typescript/no-non-null-assertion": "warn",
    "eslint/no-debugger": "warn",
    "eslint/eqeqeq": "error"
  },
  "plugins": ["typescript", "react", "jsx-a11y"],
  "ignorePatterns": ["dist/", "node_modules/", "*.d.ts"]
}
```

---

## Best Practices Summary

### Type Safety & Clean Code
1. **Strict TypeScript**: Use strict mode and enable all type-checking options
2. **Meaningful Types**: Create interfaces and types that express business logic
3. **Single Responsibility**: Each type, function, and class should have one purpose
4. **Immutability**: Prefer `readonly` and const assertions
5. **Error Handling**: Use Result types and proper error boundaries

### Modern Development
6. **Performance Tooling**: Use Biome or oxlint for instant feedback
7. **Template Literals**: Leverage type-safe string patterns
8. **Conditional Types**: Build flexible, reusable type utilities
9. **Method Chaining**: Create fluent APIs with proper return types
10. **Dependency Injection**: Use interfaces for loose coupling

### Automation
- **Biome**: All-in-one TypeScript formatting and linting (25x faster)
- **oxlint**: Ultra-fast TypeScript linting (50-100x faster)  
- **Type Checking**: Separate `tsc --noEmit` for type validation
- **CI Integration**: Use `biome ci` in pipelines
- **Editor Integration**: Configure auto-fix on save

---

*This style guide follows modern TypeScript best practices as of 2024, incorporating clean code principles, advanced type patterns, and performance-focused Rust tooling for optimal developer experience.*