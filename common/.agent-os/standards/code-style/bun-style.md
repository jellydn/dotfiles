# Bun Style Guide

A comprehensive style guide for Bun development as both a runtime and package manager, focusing on performance and modern JavaScript patterns.

## Core Principles

- **Performance First**: Leverage Bun's speed advantages for development and runtime
- **Modern JavaScript**: Use latest ECMAScript features with Bun's native TypeScript support
- **Security Conscious**: Understand Bun's security model and trusted dependencies
- **Ecosystem Compatibility**: Maintain Node.js compatibility while leveraging Bun features
- **Developer Experience**: Optimize for fast iteration and build times

## Table of Contents

1. [Package Management](#package-management)
2. [Runtime Patterns](#runtime-patterns)
3. [TypeScript Integration](#typescript-integration)
4. [Performance Optimization](#performance-optimization)
5. [Security Considerations](#security-considerations)
6. [Testing with Bun](#testing-with-bun)
7. [Build and Bundling](#build-and-bundling)
8. [Development Workflow](#development-workflow)

---

## Package Management

### Installation and Configuration

```bash
# ✅ Good - Basic Bun setup
curl -fsSL https://bun.sh/install | bash
bun init # Initialize new project
```

```json
// package.json - Bun-optimized configuration
{
  "name": "my-bun-app",
  "module": "src/index.ts",
  "type": "module",
  "scripts": {
    "dev": "bun --hot src/index.ts",
    "start": "bun src/index.ts",
    "build": "bun build src/index.ts --outdir ./dist --target node",
    "test": "bun test",
    "install:clean": "rm -rf node_modules bun.lockb && bun install"
  },
  "dependencies": {
    "@types/node": "^20.0.0"
  },
  "trustedDependencies": [
    "sharp",
    "sqlite3",
    "@prisma/client"
  ]
}
```

### Dependency Management Best Practices

```json
// bun.toml - Bun configuration file
[install]
# Registry configuration
registry = "https://registry.npmjs.org/"
cache = true

# Security settings
exact = true
production = false

[install.lockfile]
# Lockfile settings
save = true
print = "yarn"

[test]
# Test configuration
preload = ["./tests/setup.ts"]
```

```javascript
// ✅ Good - Workspace configuration for monorepos
// package.json root
{
  "workspaces": [
    "packages/*",
    "apps/*"
  ]
}

// Install dependencies for all workspaces
// bun install

// Install for specific workspace
// bun install --filter my-package
```

### Trusted Dependencies

```json
// ✅ Good - Managing trusted dependencies
{
  "trustedDependencies": [
    "sharp",          // Image processing
    "sqlite3",        // Native database bindings
    "@prisma/client", // Database ORM with postinstall scripts
    "puppeteer",      // Browser automation
    "bcrypt"          // Password hashing with native bindings
  ]
}
```

---

## Runtime Patterns

### Modern JavaScript with Bun

```typescript
// ✅ Good - Leveraging Bun's built-in APIs
import { serve } from "bun";
import { file } from "bun";
import { Database } from "bun:sqlite";

// Bun's HTTP server
const server = serve({
  port: 3000,
  async fetch(req) {
    const url = new URL(req.url);
    
    // Serve static files efficiently
    if (url.pathname.startsWith("/static/")) {
      const filePath = `./public${url.pathname}`;
      const staticFile = file(filePath);
      
      if (await staticFile.exists()) {
        return new Response(staticFile);
      }
    }
    
    // API routes
    if (url.pathname.startsWith("/api/")) {
      return await handleApiRequest(req);
    }
    
    return new Response("Not found", { status: 404 });
  },
});

console.log(`Server running on http://localhost:${server.port}`);
```

### File System Operations

```typescript
// ✅ Good - Using Bun's file API
import { file, write } from "bun";

export class FileService {
  // Fast file reading
  static async readJSON(path: string) {
    const f = file(path);
    if (!(await f.exists())) {
      throw new Error(`File not found: ${path}`);
    }
    return await f.json();
  }
  
  // Efficient file writing
  static async writeJSON(path: string, data: any) {
    await write(path, JSON.stringify(data, null, 2));
  }
  
  // Stream large files
  static async processLargeFile(path: string) {
    const f = file(path);
    const stream = f.stream();
    
    for await (const chunk of stream) {
      // Process chunk by chunk
      await this.processChunk(chunk);
    }
  }
}

// ✅ Good - Bun's built-in utilities
import { password } from "bun";

export class AuthService {
  static async hashPassword(plaintext: string): Promise<string> {
    return await password.hash(plaintext, {
      algorithm: "bcrypt",
      cost: 12
    });
  }
  
  static async verifyPassword(plaintext: string, hash: string): Promise<boolean> {
    return await password.verify(plaintext, hash);
  }
}
```

### Database Integration

```typescript
// ✅ Good - Using Bun's SQLite integration
import { Database } from "bun:sqlite";

export class DatabaseService {
  private db: Database;
  
  constructor(path: string = "app.db") {
    this.db = new Database(path);
    this.initTables();
  }
  
  private initTables() {
    this.db.exec(`
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);
  }
  
  // Prepared statements for performance
  private getUserStmt = this.db.prepare("SELECT * FROM users WHERE id = ?");
  private createUserStmt = this.db.prepare(`
    INSERT INTO users (email, name) VALUES (?, ?) RETURNING *
  `);
  
  getUser(id: number) {
    return this.getUserStmt.get(id);
  }
  
  createUser(email: string, name: string) {
    return this.createUserStmt.get(email, name);
  }
  
  // Transaction support
  createUserWithProfile(userData: any, profileData: any) {
    const transaction = this.db.transaction(() => {
      const user = this.createUser(userData.email, userData.name);
      const profile = this.createProfile(user.id, profileData);
      return { user, profile };
    });
    
    return transaction();
  }
}
```

---

## TypeScript Integration

### Native TypeScript Support

```typescript
// ✅ Good - No build step required
// src/index.ts
import type { Server } from "bun";

interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
}

interface User {
  id: number;
  email: string;
  name: string;
}

export class ApiServer {
  private server: Server;
  
  constructor(port: number = 3000) {
    this.server = Bun.serve({
      port,
      fetch: this.handleRequest.bind(this),
    });
  }
  
  private async handleRequest(req: Request): Promise<Response> {
    try {
      const url = new URL(req.url);
      const response = await this.routeRequest(req, url);
      
      return new Response(JSON.stringify(response), {
        headers: { "Content-Type": "application/json" },
      });
    } catch (error) {
      return this.errorResponse(error as Error);
    }
  }
  
  private async routeRequest(req: Request, url: URL): Promise<ApiResponse> {
    switch (`${req.method} ${url.pathname}`) {
      case "GET /api/users":
        return this.getUsers();
      case "POST /api/users":
        return this.createUser(await req.json());
      default:
        throw new Error("Route not found");
    }
  }
  
  private async getUsers(): Promise<ApiResponse<User[]>> {
    // Implementation
    return {
      success: true,
      data: [],
      timestamp: new Date().toISOString(),
    };
  }
  
  private errorResponse(error: Error): Response {
    const response: ApiResponse = {
      success: false,
      error: error.message,
      timestamp: new Date().toISOString(),
    };
    
    return new Response(JSON.stringify(response), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
}

// Start server
const api = new ApiServer(3000);
console.log("Server running on port 3000");
```

### Configuration Files

```json
// tsconfig.json - Optimized for Bun
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "noEmit": true,
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "types": ["bun-types"],
    "lib": ["ESNext", "DOM"]
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

---

## Performance Optimization

### Leveraging Bun's Speed

```typescript
// ✅ Good - Fast HTTP server patterns
import { serve } from "bun";

// Connection pooling for external APIs
const httpPool = new Map<string, Response>();

const server = serve({
  port: 3000,
  
  // Fast request handling
  async fetch(req) {
    const start = performance.now();
    
    try {
      const response = await handleRequest(req);
      
      // Log performance
      const duration = performance.now() - start;
      console.log(`${req.method} ${req.url} - ${duration.toFixed(2)}ms`);
      
      return response;
    } catch (error) {
      return new Response("Internal Server Error", { status: 500 });
    }
  },
  
  // Error handling
  error(error) {
    console.error("Server error:", error);
    return new Response("Server Error", { status: 500 });
  }
});

// ✅ Good - Efficient data processing
export class DataProcessor {
  // Use Bun's fast JSON parsing
  static async processJsonFile(path: string) {
    const file = Bun.file(path);
    const data = await file.json(); // Faster than JSON.parse
    
    return this.transformData(data);
  }
  
  // Parallel processing
  static async processBatch(files: string[]) {
    const results = await Promise.all(
      files.map(file => this.processJsonFile(file))
    );
    
    return results;
  }
}
```

### Memory and Resource Management

```typescript
// ✅ Good - Efficient resource usage
export class ResourceManager {
  private static connections = new Map<string, any>();
  
  static async getConnection(url: string) {
    if (!this.connections.has(url)) {
      // Create new connection
      const connection = await this.createConnection(url);
      this.connections.set(url, connection);
    }
    
    return this.connections.get(url);
  }
  
  static cleanup() {
    for (const [url, connection] of this.connections) {
      connection.close?.();
    }
    this.connections.clear();
  }
}

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("Shutting down gracefully...");
  ResourceManager.cleanup();
  process.exit(0);
});
```

---

## Security Considerations

### Trusted Dependencies Management

```typescript
// ✅ Good - Security-conscious dependency handling
// Only run postinstall scripts for trusted packages
// Configure in package.json:
{
  "trustedDependencies": [
    "package-with-postinstall-script"
  ]
}

// Runtime security checks
export class SecurityService {
  private static allowedOrigins = new Set([
    "https://yourdomain.com",
    "https://api.yourdomain.com"
  ]);
  
  static validateOrigin(origin: string): boolean {
    return this.allowedOrigins.has(origin);
  }
  
  static sanitizeInput(input: string): string {
    // Basic input sanitization
    return input
      .replace(/[<>]/g, '')
      .slice(0, 1000); // Limit length
  }
}
```

### Environment and Configuration Security

```typescript
// ✅ Good - Environment variable validation
import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
  PORT: z.string().transform(Number).default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  ALLOWED_ORIGINS: z.string().transform(str => str.split(',')),
});

export const env = envSchema.parse(process.env);

// ✅ Good - Secure headers middleware
export function securityHeaders(): Record<string, string> {
  return {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "X-XSS-Protection": "1; mode=block",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "Referrer-Policy": "strict-origin-when-cross-origin"
  };
}
```

---

## Testing with Bun

### Built-in Test Runner

```typescript
// tests/api.test.ts
import { expect, test, describe, beforeAll, afterAll } from "bun:test";
import { ApiServer } from "../src/api-server";

describe("API Server", () => {
  let server: any;
  
  beforeAll(async () => {
    server = new ApiServer(3001);
    // Wait for server to be ready
    await new Promise(resolve => setTimeout(resolve, 100));
  });
  
  afterAll(() => {
    server?.stop();
  });
  
  test("should respond to health check", async () => {
    const response = await fetch("http://localhost:3001/health");
    expect(response.status).toBe(200);
    
    const data = await response.json();
    expect(data.status).toBe("ok");
  });
  
  test("should handle user creation", async () => {
    const userData = {
      email: "test@example.com",
      name: "Test User"
    };
    
    const response = await fetch("http://localhost:3001/api/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(userData)
    });
    
    expect(response.status).toBe(201);
    
    const data = await response.json();
    expect(data.success).toBe(true);
    expect(data.data.email).toBe(userData.email);
  });
});

// tests/utils.test.ts
import { expect, test } from "bun:test";
import { FileService } from "../src/file-service";

test("FileService.readJSON", async () => {
  const testData = { test: "data" };
  const testFile = "./test-temp.json";
  
  // Write test data
  await FileService.writeJSON(testFile, testData);
  
  // Read and verify
  const result = await FileService.readJSON(testFile);
  expect(result).toEqual(testData);
  
  // Cleanup
  await Bun.file(testFile).delete();
});
```

---

## Build and Bundling

### Production Builds

```typescript
// build.ts - Custom build script
import { build } from "bun";

const result = await build({
  entrypoints: ['./src/index.ts'],
  outdir: './dist',
  target: 'node',
  minify: true,
  sourcemap: 'external',
  splitting: true,
  format: 'esm',
  define: {
    'process.env.NODE_ENV': '"production"',
  },
  external: ['sqlite3', 'sharp'] // Don't bundle native modules
});

if (result.success) {
  console.log('Build successful!');
  console.log(`Built ${result.outputs.length} files`);
} else {
  console.error('Build failed:', result.logs);
  process.exit(1);
}
```

### Docker Integration

```dockerfile
# Dockerfile
FROM oven/bun:1-alpine

WORKDIR /app

# Copy package files
COPY package.json bun.lockb ./

# Install dependencies
RUN bun install --frozen-lockfile --production

# Copy source code
COPY src ./src

# Expose port
EXPOSE 3000

# Run with Bun
CMD ["bun", "src/index.ts"]
```

---

## Development Workflow

### Development Scripts and Tools

```json
// package.json scripts optimized for Bun
{
  "scripts": {
    "dev": "bun --hot --watch src/index.ts",
    "dev:debug": "bun --inspect --hot src/index.ts",
    "start": "bun src/index.ts",
    "build": "bun build.ts",
    "test": "bun test",
    "test:watch": "bun test --watch",
    "lint": "biome lint ./src",
    "format": "biome format --write ./src",
    "check": "bun run lint && bun run test && bun run build",
    "upgrade": "bun update && bun outdated"
  }
}
```

### Debugging and Development

```typescript
// ✅ Good - Development utilities
export class DevTools {
  static isDev = process.env.NODE_ENV === "development";
  
  static log(...args: any[]) {
    if (this.isDev) {
      console.log(...args);
    }
  }
  
  static time<T>(label: string, fn: () => T): T {
    if (this.isDev) {
      console.time(label);
      const result = fn();
      console.timeEnd(label);
      return result;
    }
    return fn();
  }
  
  static async timeAsync<T>(label: string, fn: () => Promise<T>): Promise<T> {
    if (this.isDev) {
      console.time(label);
      const result = await fn();
      console.timeEnd(label);
      return result;
    }
    return fn();
  }
}
```

---

## Best Practices Summary

### Performance & Speed
1. **Use Bun's APIs**: Leverage built-in file, HTTP, and SQLite APIs for maximum performance
2. **Hot Reloading**: Use `--hot` flag for instant development feedback
3. **Native TypeScript**: No build step needed for development
4. **Fast Package Management**: Bun install is 10-100x faster than npm

### Security & Reliability  
5. **Trusted Dependencies**: Carefully manage which packages can run postinstall scripts
6. **Environment Validation**: Use schemas to validate environment variables
7. **Input Sanitization**: Always validate and sanitize user inputs

### Development Experience
8. **Built-in Testing**: Use Bun's fast test runner instead of external tools
9. **Watch Mode**: Use `--watch` for file watching and automatic restarts  
10. **Modern JavaScript**: Leverage ES modules and latest JavaScript features

### Deployment & Production
- **Docker**: Use official Bun Docker images for consistent deployments
- **Build Optimization**: Use Bun's bundler for optimized production builds
- **Resource Management**: Implement proper connection pooling and cleanup
- **Monitoring**: Add performance logging and health checks

---

*This style guide covers Bun best practices for both development and production use, focusing on performance, security, and modern JavaScript patterns as of 2024.*