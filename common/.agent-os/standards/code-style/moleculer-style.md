# Moleculer Microservices Style Guide

A comprehensive style guide for modern Moleculer microservices development with TypeScript, focusing on scalable architecture, security, and maintainability.

## Core Principles

- **Microservices First**: Design services with clear boundaries and responsibilities
- **Type Safety**: Leverage TypeScript for robust service contracts and validation
- **Event-Driven Architecture**: Use Moleculer's built-in event system for service communication
- **Service Discovery**: Implement discoverable services with proper metadata
- **Observable Systems**: Built-in metrics, tracing, and health checks

## Table of Contents

1. [Project Structure](#project-structure)
2. [Service Definition Patterns](#service-definition-patterns)
3. [TypeScript Integration](#typescript-integration)
4. [Action and Event Patterns](#action-and-event-patterns)
5. [Validation and Schema Design](#validation-and-schema-design)
6. [Service Communication](#service-communication)
7. [Error Handling](#error-handling)
8. [Testing Strategies](#testing-strategies)
9. [Configuration Management](#configuration-management)
10. [Performance and Scaling](#performance-and-scaling)

---

## Project Structure

### Recommended Folder Structure

```
src/
├── services/           # Service implementations
│   ├── api/           # API Gateway services
│   │   ├── api.service.ts
│   │   └── gateway.service.ts
│   ├── auth/          # Authentication services
│   │   ├── auth.service.ts
│   │   └── user.service.ts
│   ├── business/      # Business logic services
│   │   ├── order.service.ts
│   │   ├── payment.service.ts
│   │   └── notification.service.ts
│   └── data/          # Data access services
│       ├── database.service.ts
│       └── cache.service.ts
├── mixins/            # Service mixins
│   ├── database.mixin.ts
│   ├── cache.mixin.ts
│   └── metrics.mixin.ts
├── types/             # TypeScript type definitions
│   ├── service.types.ts
│   ├── api.types.ts
│   └── events.types.ts
├── utils/             # Utility functions
│   ├── validators.ts
│   ├── transformers.ts
│   └── constants.ts
├── config/            # Configuration files
│   ├── moleculer.config.ts
│   ├── database.config.ts
│   └── env.config.ts
├── tests/             # Test files
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── moleculer.config.ts  # Main Moleculer configuration

docs/                  # Service documentation
templates/             # Service generation templates (hygen)
k8s/                   # Kubernetes manifests
docker/                # Docker configurations
```

---

## Service Definition Patterns

### Base Service Structure

```typescript
// ✅ Good - Comprehensive service definition
import { Service, ServiceBroker, Context, ServiceSchema, ActionSchema } from "moleculer";
import { z } from "zod";
import DatabaseMixin from "../mixins/database.mixin.js";
import CacheMixin from "../mixins/cache.mixin.js";

// Types
interface UserEntity {
  id: string;
  email: string;
  name: string;
  role: "admin" | "user";
  createdAt: Date;
  updatedAt: Date;
}

interface CreateUserParams {
  email: string;
  name: string;
  password: string;
  role?: "admin" | "user";
}

// Service Schema
const UserServiceSchema: ServiceSchema = {
  name: "user",
  version: "1",

  metadata: {
    description: "User management service",
    tags: ["auth", "user-management"],
    scalable: true,
  },

  settings: {
    defaultRole: "user",
    bcryptRounds: 12,
    jwtSecret: process.env.JWT_SECRET,
  },

  dependencies: ["auth", "notification"],

  mixins: [DatabaseMixin, CacheMixin],

  actions: {
    create: {
      params: {
        email: "string|email",
        name: "string|min:2|max:100",
        password: "string|min:8",
        role: { type: "enum", values: ["admin", "user"], optional: true },
      },
      handler: async (ctx: Context<CreateUserParams>): Promise<UserEntity> => {
        return this.createUser(ctx.params);
      },
    },

    get: {
      params: {
        id: "string|uuid",
      },
      cache: {
        keys: ["id"],
        ttl: 3600,
      },
      handler: async (
        ctx: Context<{ id: string }>,
      ): Promise<UserEntity | null> => {
        return this.getUserById(ctx.params.id);
      },
    },
  },

  events: {
    "user.created": {
      params: {
        user: "object",
      },
      handler: async (ctx: Context<{ user: UserEntity }>) => {
        await ctx.call("notification.sendWelcomeEmail", {
          user: ctx.params.user,
        });
      },
    },
  },

  methods: {
    async createUser(params: CreateUserParams): Promise<UserEntity> {
      // Implementation here
      const hashedPassword = await this.hashPassword(params.password);

      const user = await this.adapter.insert({
        id: this.generateId(),
        email: params.email,
        name: params.name,
        password: hashedPassword,
        role: params.role || this.settings.defaultRole,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      // Emit event
      this.broker.emit("user.created", { user });

      return this.sanitizeUser(user);
    },

    async getUserById(id: string): Promise<UserEntity | null> {
      const user = await this.adapter.findById(id);
      return user ? this.sanitizeUser(user) : null;
    },

    sanitizeUser(user: any): UserEntity {
      const { password, ...sanitized } = user;
      return sanitized;
    },
  },

  started() {
    this.logger.info("User service started");
  },

  stopped() {
    this.logger.info("User service stopped");
  },
};

export default UserServiceSchema;
```

### Service Naming Conventions

```typescript
// ✅ Good - Clear service naming
const ServiceSchema = {
  name: "user", // Singular noun
  version: "1", // Semantic versioning

  actions: {
    create: {}, // CRUD operations: create, get, list, update, remove
    get: {},
    list: {},
    update: {},
    remove: {},

    // Custom actions with clear verbs
    activate: {},
    deactivate: {},
    resetPassword: {},
    sendVerificationEmail: {},
  },

  events: {
    "user.created": {}, // Domain.action format
    "user.updated": {},
    "user.deleted": {},
    "auth.login.failed": {},
  },
};
```

---

## TypeScript Integration

### Service Type Definitions

```typescript
// types/service.types.ts
import { ServiceSchema, Context, ActionSchema } from "moleculer";

// Base service interface
export interface BaseService {
  name: string;
  version?: string;
  settings?: Record<string, any>;
  dependencies?: string[];
}

// Typed context for actions
export interface TypedContext<P = any, M = any> extends Context<P, M> {
  params: P;
  meta: M;
}

// Action parameter types
export interface PaginationParams {
  page?: number;
  pageSize?: number;
  sort?: string;
  search?: string;
}

export interface IdParams {
  id: string;
}

// Service response types
export interface ServiceResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: string[];
}

export interface PaginatedResponse<T = any> {
  rows: T[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}
```

### Typed Service Implementation

```typescript
// services/user.service.ts
import { ServiceSchema, Context } from "moleculer";
import {
  TypedContext,
  ServiceResponse,
  PaginatedResponse,
} from "../types/service.types";
import {
  UserEntity,
  CreateUserParams,
  UpdateUserParams,
  UserFilters,
} from "../types/user.types";

interface UserService {
  createUser(params: CreateUserParams): Promise<UserEntity>;
  updateUser(id: string, params: UpdateUserParams): Promise<UserEntity>;
  deleteUser(id: string): Promise<boolean>;
  listUsers(filters: UserFilters): Promise<PaginatedResponse<UserEntity>>;
}

const UserServiceSchema: ServiceSchema<UserService> = {
  name: "user",

  actions: {
    create: {
      params: {
        email: "string|email",
        name: "string|min:2|max:100",
        password: "string|min:8",
      },
      async handler(
        ctx: TypedContext<CreateUserParams>,
      ): Promise<ServiceResponse<UserEntity>> {
        try {
          const user = await this.createUser(ctx.params);
          return {
            success: true,
            data: user,
          };
        } catch (error) {
          throw new Error(`Failed to create user: ${error.message}`);
        }
      },
    },

    list: {
      params: {
        page: {
          type: "number",
          integer: true,
          min: 1,
          optional: true,
          default: 1,
        },
        pageSize: {
          type: "number",
          integer: true,
          min: 1,
          max: 100,
          optional: true,
          default: 20,
        },
        search: { type: "string", optional: true },
        role: { type: "enum", values: ["admin", "user"], optional: true },
      },
      async handler(
        ctx: TypedContext<UserFilters>,
      ): Promise<PaginatedResponse<UserEntity>> {
        return this.listUsers(ctx.params);
      },
    },
  },

  methods: {
    async createUser(params: CreateUserParams): Promise<UserEntity> {
      // Implementation with full type safety
      return this.transformDatabaseRecord(await this.adapter.insert(params));
    },

    async listUsers(
      filters: UserFilters,
    ): Promise<PaginatedResponse<UserEntity>> {
      const { rows, total } = await this.adapter.list({
        ...filters,
        offset: (filters.page - 1) * filters.pageSize,
        limit: filters.pageSize,
      });

      return {
        rows: rows.map(this.transformDatabaseRecord),
        total,
        page: filters.page,
        pageSize: filters.pageSize,
        totalPages: Math.ceil(total / filters.pageSize),
      };
    },
  },
};

export default UserServiceSchema;
```

---

## Action and Event Patterns

### Action Design

```typescript
// ✅ Good - RESTful action design
const ServiceSchema = {
  actions: {
    // CRUD operations
    create: {
      rest: "POST /",
      params: {
        /* validation */
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },

    get: {
      rest: "GET /:id",
      params: {
        id: "string|uuid",
      },
      cache: {
        keys: ["id"],
        ttl: 300,
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },

    list: {
      rest: "GET /",
      params: {
        page: {
          type: "number",
          integer: true,
          min: 1,
          optional: true,
          default: 1,
        },
        limit: {
          type: "number",
          integer: true,
          min: 1,
          max: 100,
          optional: true,
          default: 20,
        },
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },

    update: {
      rest: "PUT /:id",
      params: {
        id: "string|uuid",
        // Update fields
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },

    remove: {
      rest: "DELETE /:id",
      params: {
        id: "string|uuid",
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },

    // Business logic actions
    activate: {
      rest: "POST /:id/activate",
      params: {
        id: "string|uuid",
      },
      handler: async (ctx) => {
        /* implementation */
      },
    },
  },
};
```

### Event-Driven Communication

```typescript
// ✅ Good - Event-driven patterns
const OrderServiceSchema = {
  name: "order",

  actions: {
    create: {
      async handler(ctx: TypedContext<CreateOrderParams>) {
        const order = await this.createOrder(ctx.params);

        // Emit domain event
        this.broker.emit("order.created", {
          order,
          userId: ctx.meta.user.id,
          timestamp: new Date(),
        });

        return order;
      },
    },
  },

  events: {
    // Handle events from other services
    "payment.completed": {
      params: {
        orderId: "string|uuid",
        paymentId: "string|uuid",
        amount: "number|positive",
      },
      handler: async (ctx: TypedContext<PaymentCompletedEvent>) => {
        await this.fulfillOrder(ctx.params.orderId);

        // Chain events
        this.broker.emit("order.fulfilled", {
          orderId: ctx.params.orderId,
          timestamp: new Date(),
        });
      },
    },

    "user.deleted": {
      params: {
        userId: "string|uuid",
      },
      handler: async (ctx: TypedContext<{ userId: string }>) => {
        // Cleanup user's orders
        await this.cancelUserOrders(ctx.params.userId);
      },
    },
  },
};
```

---

## Validation and Schema Design

### Zod Integration

```typescript
// validators/user.validators.ts
import { z } from "zod";

export const CreateUserSchema = z.object({
  email: z.string().email().max(255),
  name: z.string().min(2).max(100).trim(),
  password: z
    .string()
    .min(8)
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
      "Password must contain uppercase, lowercase, number, and special character",
    ),
  role: z.enum(["admin", "user"]).default("user"),
});

export const UpdateUserSchema = CreateUserSchema.partial().omit({
  password: true,
});

export const UserFilterSchema = z.object({
  page: z.number().int().min(1).default(1),
  pageSize: z.number().int().min(1).max(100).default(20),
  search: z.string().optional(),
  role: z.enum(["admin", "user"]).optional(),
  status: z.enum(["active", "inactive"]).optional(),
});

export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserSchema>;
export type UserFilters = z.infer<typeof UserFilterSchema>;
```

### Custom Validation Middleware

```typescript
// mixins/validation.mixin.ts
import { ServiceMixin } from "moleculer";
import { ZodSchema, ZodError } from "zod";

export interface ValidationMixin {
  validateParams<T>(schema: ZodSchema<T>, params: any): T;
}

const ValidationMixin: ServiceMixin<ValidationMixin> = {
  methods: {
    validateParams<T>(schema: ZodSchema<T>, params: any): T {
      try {
        return schema.parse(params);
      } catch (error) {
        if (error instanceof ZodError) {
          const validationErrors = error.errors.map((err) => ({
            field: err.path.join("."),
            message: err.message,
            code: err.code,
          }));

          throw new this.broker.errors.ValidationError(
            "Invalid parameters",
            null,
            validationErrors,
          );
        }
        throw error;
      }
    },
  },

  created() {
    // Auto-validate action parameters
    if (this.schema.actions) {
      Object.keys(this.schema.actions).forEach((actionName) => {
        const action = this.schema.actions![actionName];
        if (action.zodSchema) {
          const originalHandler = action.handler;
          action.handler = async (ctx: any) => {
            ctx.params = this.validateParams(action.zodSchema, ctx.params);
            return originalHandler.call(this, ctx);
          };
        }
      });
    }
  },
};

export default ValidationMixin;
```

### Service with Validation

```typescript
// services/user.service.ts
import ValidationMixin from "../mixins/validation.mixin";
import {
  CreateUserSchema,
  UpdateUserSchema,
} from "../validators/user.validators";

const UserServiceSchema = {
  name: "user",

  mixins: [ValidationMixin],

  actions: {
    create: {
      zodSchema: CreateUserSchema,
      async handler(ctx: TypedContext<CreateUserInput>) {
        // ctx.params is now validated and typed
        return this.createUser(ctx.params);
      },
    },

    update: {
      params: {
        id: "string|uuid",
      },
      zodSchema: UpdateUserSchema,
      async handler(ctx: TypedContext<UpdateUserInput & { id: string }>) {
        const { id, ...updateData } = ctx.params;
        return this.updateUser(id, updateData);
      },
    },
  },
};
```

---

## Service Communication

### Inter-Service Calls

```typescript
// ✅ Good - Typed service calls
class OrderService {
  async createOrder(params: CreateOrderParams, userId: string) {
    // Call user service to validate user
    const user = await this.broker.call<UserEntity>("user.get", { id: userId });

    if (!user) {
      throw new this.broker.errors.ValidationError("User not found");
    }

    // Call inventory service to check availability
    const availability = await this.broker.call<InventoryCheck>(
      "inventory.check",
      {
        productId: params.productId,
        quantity: params.quantity,
      },
    );

    if (!availability.available) {
      throw new this.broker.errors.ValidationError("Product not available");
    }

    // Create order
    const order = await this.adapter.insert({
      ...params,
      userId,
      status: "pending",
      createdAt: new Date(),
    });

    // Emit event for other services
    this.broker.emit("order.created", { order, user });

    return order;
  }
}
```

### Circuit Breaker Pattern

```typescript
// mixins/circuit-breaker.mixin.ts
import { ServiceMixin } from "moleculer";

const CircuitBreakerMixin: ServiceMixin = {
  settings: {
    circuitBreaker: {
      threshold: 5, // failures before opening
      timeout: 10000, // reset timeout
      windowTime: 60000, // evaluation window
    },
  },

  methods: {
    async callWithCircuitBreaker(
      action: string,
      params: any,
      options: any = {},
    ) {
      try {
        return await this.broker.call(action, params, {
          ...options,
          timeout: 5000,
          retry: 3,
          fallbackResponse: null,
        });
      } catch (error) {
        this.logger.warn(`Circuit breaker triggered for ${action}`, error);

        if (options.fallback) {
          return options.fallback();
        }

        throw error;
      }
    },
  },
};

export default CircuitBreakerMixin;
```

---

## Error Handling

### Custom Error Classes

```typescript
// utils/errors.ts
import { Errors } from "moleculer";

export class BusinessLogicError extends Errors.MoleculerError {
  constructor(
    message: string,
    code: string = "BUSINESS_LOGIC_ERROR",
    data?: any,
  ) {
    super(message, 422, "BUSINESS_LOGIC_ERROR", data);
    this.name = "BusinessLogicError";
  }
}

export class ResourceNotFoundError extends Errors.MoleculerError {
  constructor(resource: string, id?: string) {
    const message = id
      ? `${resource} with id '${id}' not found`
      : `${resource} not found`;
    super(message, 404, "RESOURCE_NOT_FOUND", { resource, id });
    this.name = "ResourceNotFoundError";
  }
}

export class ConflictError extends Errors.MoleculerError {
  constructor(message: string, data?: any) {
    super(message, 409, "CONFLICT", data);
    this.name = "ConflictError";
  }
}
```

### Error Handling Patterns

```typescript
// ✅ Good - Comprehensive error handling
const UserServiceSchema = {
  actions: {
    create: {
      async handler(ctx: TypedContext<CreateUserParams>) {
        try {
          // Check for existing user
          const existingUser = await this.adapter.findOne({
            email: ctx.params.email,
          });
          if (existingUser) {
            throw new ConflictError("User with this email already exists", {
              email: ctx.params.email,
            });
          }

          // Create user
          const user = await this.createUser(ctx.params);

          // Log success
          this.logger.info("User created successfully", {
            userId: user.id,
            email: user.email,
          });

          return user;
        } catch (error) {
          // Log error with context
          this.logger.error("Failed to create user", {
            params: this.sanitizeForLog(ctx.params),
            error: error.message,
            stack: error.stack,
          });

          // Re-throw or handle specific errors
          if (error instanceof ConflictError) {
            throw error;
          }

          throw new BusinessLogicError("User creation failed");
        }
      },
    },
  },

  methods: {
    sanitizeForLog(obj: any) {
      const sensitive = ["password", "token", "secret"];
      const sanitized = { ...obj };

      for (const key of Object.keys(sanitized)) {
        if (sensitive.some((s) => key.toLowerCase().includes(s))) {
          sanitized[key] = "[REDACTED]";
        }
      }

      return sanitized;
    },
  },
};
```

---

## Testing Strategies

### Service Testing Structure

```typescript
// tests/unit/user.service.test.ts
import { ServiceBroker } from "moleculer";
import UserService from "../../src/services/user.service";
import { CreateUserInput } from "../../src/types/user.types";

describe("User Service", () => {
  let broker: ServiceBroker;
  let service: any;

  beforeAll(async () => {
    broker = new ServiceBroker({
      logger: false,
      transporter: null,
    });

    service = broker.createService(UserService);
    await broker.start();
  });

  afterAll(async () => {
    await broker.stop();
  });

  beforeEach(async () => {
    // Reset database or mock state
    await service.adapter.clear();
  });

  describe("create action", () => {
    it("should create user with valid parameters", async () => {
      const params: CreateUserInput = {
        email: "test@example.com",
        name: "Test User",
        password: "SecurePass123!",
        role: "user",
      };

      const result = await broker.call("user.create", params);

      expect(result).toMatchObject({
        email: params.email,
        name: params.name,
        role: "user",
      });
      expect(result).not.toHaveProperty("password");
      expect(result.id).toBeDefined();
    });

    it("should throw validation error for invalid email", async () => {
      const params = {
        email: "invalid-email",
        name: "Test User",
        password: "SecurePass123!",
      };

      await expect(broker.call("user.create", params)).rejects.toThrow(
        "Validation error",
      );
    });

    it("should throw conflict error for duplicate email", async () => {
      const params: CreateUserInput = {
        email: "duplicate@example.com",
        name: "Test User",
        password: "SecurePass123!",
      };

      // Create first user
      await broker.call("user.create", params);

      // Try to create duplicate
      await expect(broker.call("user.create", params)).rejects.toThrow(
        "User with this email already exists",
      );
    });
  });

  describe("events", () => {
    it("should emit user.created event", async () => {
      const eventHandler = jest.fn();
      broker.on("user.created", eventHandler);

      const params: CreateUserInput = {
        email: "test@example.com",
        name: "Test User",
        password: "SecurePass123!",
      };

      await broker.call("user.create", params);

      expect(eventHandler).toHaveBeenCalledWith(
        expect.objectContaining({
          user: expect.objectContaining({
            email: params.email,
            name: params.name,
          }),
        }),
      );
    });
  });
});
```

### Integration Testing

```typescript
// tests/integration/user-flow.test.ts
import { ServiceBroker } from "moleculer";
import UserService from "../../src/services/user.service";
import AuthService from "../../src/services/auth.service";
import NotificationService from "../../src/services/notification.service";

describe("User Registration Flow", () => {
  let broker: ServiceBroker;

  beforeAll(async () => {
    broker = new ServiceBroker({
      logger: false,
    });

    // Load all services
    broker.createService(UserService);
    broker.createService(AuthService);
    broker.createService(NotificationService);

    await broker.start();
  });

  afterAll(async () => {
    await broker.stop();
  });

  it("should complete full user registration flow", async () => {
    // Create user
    const user = await broker.call("user.create", {
      email: "newuser@example.com",
      name: "New User",
      password: "SecurePass123!",
    });

    expect(user.id).toBeDefined();

    // Verify user can login
    const loginResult = await broker.call("auth.login", {
      email: "newuser@example.com",
      password: "SecurePass123!",
    });

    expect(loginResult.token).toBeDefined();
    expect(loginResult.user.id).toBe(user.id);

    // Verify notification was sent
    const notifications = await broker.call("notification.list", {
      userId: user.id,
    });

    expect(notifications.rows).toHaveLength(1);
    expect(notifications.rows[0].type).toBe("welcome");
  });
});
```

---

## Configuration Management

### Environment-Based Configuration

```typescript
// config/moleculer.config.ts
import { BrokerOptions } from "moleculer";
import { z } from "zod";
import { hostname } from "os";
import pino from "pino";

const ConfigSchema = z.object({
  NODE_ENV: z
    .enum(["development", "production", "test"])
    .default("development"),
  PORT: z.string().transform(Number).default(3000),

  // Service Discovery
  TRANSPORTER_URL: z.string().url().optional(),
  REDIS_URL: z.string().url().optional(),

  // Database
  DATABASE_URL: z.string().url(),
  DATABASE_POOL_MIN: z.string().transform(Number).default(2),
  DATABASE_POOL_MAX: z.string().transform(Number).default(20),

  // Security
  JWT_SECRET: z.string().min(32),
  BCRYPT_ROUNDS: z.string().transform(Number).default(12),

  // Observability
  METRICS_ENABLED: z
    .string()
    .transform((val) => val === "true")
    .default(false),
  TRACING_ENABLED: z
    .string()
    .transform((val) => val === "true")
    .default(false),
});

type Config = z.infer<typeof ConfigSchema>;

let config: Config;

try {
  config = ConfigSchema.parse(process.env);
} catch (error) {
  console.error("Invalid environment configuration:", error.errors);
  process.exit(1);
}

const brokerConfig: BrokerOptions = {
  namespace: "myapp",
  nodeID: process.env.HOSTNAME || hostname(),

  // Service registry
  registry: {
    strategy: "RoundRobin",
    preferLocal: true,
  },

  // Transporter configuration
  transporter:
    config.TRANSPORTER_URL ||
    (config.NODE_ENV === "production" ? "NATS" : null),

  // Request timeout
  requestTimeout: 30000,
  retryPolicy: {
    enabled: true,
    retries: 3,
    delay: 100,
    maxDelay: 2000,
    factor: 2,
    check: (err: any) => err && !!err.retryable,
  },

  // Circuit breaker
  circuitBreaker: {
    enabled: true,
    threshold: 0.5,
    windowTime: 60,
    minRequestCount: 20,
    halfOpenTime: 10 * 1000,
  },

  // Caching
  cacher: config.REDIS_URL
    ? {
        type: "Redis",
        options: {
          redis: config.REDIS_URL,
          ttl: 30,
        },
      }
    : "Memory",

  // Serialization
  serializer: "JSON",

  // Metrics
  metrics: {
    enabled: config.METRICS_ENABLED,
    reporter: [
      {
        type: "Prometheus",
        options: {
          port: 3030,
          path: "/metrics",
        },
      },
    ],
  },

  // Tracing
  tracing: {
    enabled: config.TRACING_ENABLED,
    exporter: {
      type: "Jaeger",
      options: {
        endpoint:
          process.env.JAEGER_ENDPOINT || "http://localhost:14268/api/traces",
      },
    },
  },

  // Logger
  logger:
    config.NODE_ENV === "production"
      ? {
          type: "Pino",
          options: {
            level: "info",
            pino: pino({
              transport: {
                target: "pino/file",
                options: {
                  destination: "logs/moleculer.log",
                },
              },
            }),
          },
        }
      : true,
};

export default brokerConfig;
export { config };
```

---

## Performance and Scaling

### Caching Strategies

```typescript
// mixins/cache.mixin.ts
import { ServiceMixin } from "moleculer";

interface CacheMixin {
  getCacheKey(prefix: string, params: any): string;
  cacheGet(key: string): Promise<any>;
  cacheSet(key: string, value: any, ttl?: number): Promise<void>;
  cacheClean(pattern: string): Promise<void>;
}

const CacheMixin: ServiceMixin<CacheMixin> = {
  settings: {
    cache: {
      enabled: true,
      ttl: 3600,
      prefix: "",
    },
  },

  methods: {
    getCacheKey(prefix: string, params: any): string {
      const servicePrefix = this.settings.cache.prefix || this.name;
      const paramHash = this.broker.utils.hash(JSON.stringify(params));
      return `${servicePrefix}:${prefix}:${paramHash}`;
    },

    async cacheGet(key: string): Promise<any> {
      if (!this.settings.cache.enabled) return null;

      try {
        return await this.broker.cacher?.get(key);
      } catch (error) {
        this.logger.warn("Cache get error:", error);
        return null;
      }
    },

    async cacheSet(key: string, value: any, ttl?: number): Promise<void> {
      if (!this.settings.cache.enabled) return;

      try {
        await this.broker.cacher?.set(
          key,
          value,
          ttl || this.settings.cache.ttl,
        );
      } catch (error) {
        this.logger.warn("Cache set error:", error);
      }
    },

    async cacheClean(pattern: string): Promise<void> {
      if (!this.settings.cache.enabled) return;

      try {
        await this.broker.cacher?.clean(pattern);
      } catch (error) {
        this.logger.warn("Cache clean error:", error);
      }
    },
  },
};

export default CacheMixin;
```

### Service with Optimized Caching

```typescript
// services/product.service.ts
import CacheMixin from "../mixins/cache.mixin";

const ProductServiceSchema = {
  name: "product",

  mixins: [CacheMixin],

  settings: {
    cache: {
      enabled: true,
      ttl: 1800, // 30 minutes
      prefix: "product",
    },
  },

  actions: {
    get: {
      params: {
        id: "string|uuid",
      },
      async handler(ctx: TypedContext<{ id: string }>) {
        const cacheKey = this.getCacheKey("get", ctx.params);

        // Try cache first
        let product = await this.cacheGet(cacheKey);

        if (!product) {
          product = await this.adapter.findById(ctx.params.id);
          if (product) {
            await this.cacheSet(cacheKey, product);
          }
        }

        return product;
      },
    },

    list: {
      params: {
        category: { type: "string", optional: true },
        status: {
          type: "enum",
          values: ["active", "inactive"],
          optional: true,
        },
        page: { type: "number", integer: true, min: 1, default: 1 },
        limit: { type: "number", integer: true, min: 1, max: 100, default: 20 },
      },
      async handler(ctx: TypedContext<ProductFilters>) {
        const cacheKey = this.getCacheKey("list", ctx.params);

        let result = await this.cacheGet(cacheKey);

        if (!result) {
          result = await this.listProducts(ctx.params);
          await this.cacheSet(cacheKey, result, 300); // 5 minutes for lists
        }

        return result;
      },
    },

    update: {
      params: {
        id: "string|uuid",
      },
      async handler(ctx: TypedContext<UpdateProductParams & { id: string }>) {
        const { id, ...updateData } = ctx.params;

        const product = await this.adapter.updateById(id, updateData);

        // Invalidate related caches
        await this.cacheClean(`product:get:*${id}*`);
        await this.cacheClean("product:list:*");

        return product;
      },
    },
  },

  events: {
    "product.updated": {
      handler: async (ctx: Context<{ productId: string }>) => {
        // Clean cache when product is updated from other services
        await this.cacheClean(`product:*${ctx.params.productId}*`);
      },
    },
  },
};
```

---

## Best Practices Summary

### Service Design

1. **Single Responsibility**: Each service owns a specific business domain
2. **Stateless Services**: Services should be stateless and horizontally scalable
3. **Event-Driven**: Use events for loose coupling between services
4. **Versioning**: Version your services and maintain backward compatibility
5. **Health Checks**: Implement health check endpoints

### Performance & Scalability

6. **Caching**: Implement multi-level caching strategies
7. **Connection Pooling**: Use database connection pooling
8. **Circuit Breaker**: Implement circuit breaker pattern for external calls
9. **Async Operations**: Use async/await and event-driven patterns
10. **Resource Management**: Monitor memory usage and connection limits

### Code Quality & Maintainability

- **TypeScript**: Full type safety with interfaces and schemas
- **Validation**: Use Zod for runtime validation and type generation
- **Error Handling**: Structured error handling with custom error classes
- **Testing**: Comprehensive unit and integration test coverage
- **Documentation**: Maintain service documentation and API schemas

---

_This Moleculer style guide extends the Node.js best practices with microservices-specific patterns focusing on service architecture, communication, and scalability as of 2024._
