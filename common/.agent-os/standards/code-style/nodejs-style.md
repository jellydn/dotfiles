# Node.js Style Guide

A comprehensive style guide for modern Node.js development focusing on security, performance, and maintainability.

## Core Principles

- **Security First**: Follow security best practices to prevent common vulnerabilities
- **Performance Oriented**: Write efficient, scalable server-side code
- **Modern JavaScript**: Use latest Node.js features and ES modules
- **Clean Architecture**: Implement layered architecture with clear separation of concerns
- **Error Handling**: Comprehensive error handling and logging strategies

## Table of Contents

1. [Project Structure](#project-structure)
2. [Modern JavaScript Patterns](#modern-javascript-patterns)
3. [Security Best Practices](#security-best-practices)
4. [Data Validation with Zod](#data-validation-with-zod)
5. [Performance Optimization](#performance-optimization)
6. [Error Handling & Logging](#error-handling--logging)
7. [Database & Data Access](#database--data-access)
8. [API Design](#api-design)
9. [Testing Strategies](#testing-strategies)
10. [Modern Tooling](#modern-tooling)

---

## Project Structure

### Recommended Folder Structure

```
src/
├── controllers/        # HTTP request handlers
│   ├── auth.controller.js
│   ├── user.controller.js
│   └── post.controller.js
├── services/          # Business logic layer
│   ├── auth.service.js
│   ├── user.service.js
│   └── email.service.js
├── models/            # Data models
│   ├── user.model.js
│   └── post.model.js
├── middleware/        # Custom middleware
│   ├── auth.middleware.js
│   ├── validation.middleware.js
│   └── error.middleware.js
├── routes/            # Route definitions
│   ├── api/
│   │   ├── auth.routes.js
│   │   ├── users.routes.js
│   │   └── posts.routes.js
│   └── index.routes.js
├── config/            # Configuration files
│   ├── database.js
│   ├── redis.js
│   └── env.js
├── utils/             # Utility functions
│   ├── logger.js
│   ├── validation.js
│   └── crypto.js
├── tests/             # Test files
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── app.js            # Application entry point

config/               # Environment configurations
├── development.json
├── production.json
└── test.json

docs/                 # API documentation
logs/                 # Application logs
scripts/              # Deployment and utility scripts
```

### Layered Architecture Pattern

```javascript
// ✅ Good - Clear separation of concerns

// controllers/user.controller.js
import { userService } from '../services/user.service.js';
import { logger } from '../utils/logger.js';

export class UserController {
  async createUser(req, res, next) {
    try {
      const userData = req.body;
      const user = await userService.createUser(userData);
      
      res.status(201).json({
        success: true,
        data: user
      });
    } catch (error) {
      logger.error('Error creating user:', error);
      next(error);
    }
  }
}

// services/user.service.js  
import { userModel } from '../models/user.model.js';
import { emailService } from './email.service.js';

export class UserService {
  async createUser(userData) {
    // Business logic here
    const user = await userModel.create(userData);
    await emailService.sendWelcomeEmail(user.email);
    return user;
  }
}

// models/user.model.js
import { db } from '../config/database.js';

export class UserModel {
  async create(userData) {
    // Data access logic here
    return await db.users.create(userData);
  }
}
```

---

## Modern JavaScript Patterns

### ES Modules and Modern Syntax

```javascript
// ✅ Good - Use ES modules
import { promises as fs } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// ✅ Good - Modern async/await patterns
export class FileService {
  async readConfigFile(filename) {
    try {
      const filePath = join(__dirname, '..', 'config', filename);
      const data = await fs.readFile(filePath, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      throw new Error(`Failed to read config file: ${error.message}`);
    }
  }

  // ✅ Good - Parallel execution
  async processMultipleFiles(filenames) {
    try {
      const results = await Promise.all(
        filenames.map(filename => this.readConfigFile(filename))
      );
      return results;
    } catch (error) {
      logger.error('Error processing files:', error);
      throw error;
    }
  }
}
```

### TypeScript Integration

```typescript
// types/user.types.ts
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'admin' | 'user';
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserRequest {
  email: string;
  name: string;
  password: string;
}

export interface AuthenticatedRequest extends Request {
  user: User;
}

// services/user.service.ts
import type { User, CreateUserRequest } from '../types/user.types.js';

export class UserService {
  async createUser(userData: CreateUserRequest): Promise<User> {
    // Implementation with full type safety
    const hashedPassword = await this.hashPassword(userData.password);
    
    const user = await this.userRepository.create({
      ...userData,
      password: hashedPassword,
    });

    return this.sanitizeUser(user);
  }

  private sanitizeUser(user: any): User {
    const { password, ...sanitized } = user;
    return sanitized;
  }
}
```

---

## Security Best Practices

### Input Validation and Sanitization

```javascript
// ✅ Good - Use Joi for validation
import Joi from 'joi';

export const userValidation = {
  createUser: {
    body: Joi.object({
      email: Joi.string()
        .email()
        .required()
        .max(255),
      name: Joi.string()
        .trim()
        .min(2)
        .max(100)
        .required(),
      password: Joi.string()
        .min(8)
        .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
        .required()
        .messages({
          'string.pattern.base': 'Password must contain uppercase, lowercase, number, and special character'
        })
    })
  }
};

// middleware/validation.middleware.js
export const validateRequest = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        details: error.details.map(detail => detail.message)
      });
    }
    
    req.body = value; // Use sanitized values
    next();
  };
};
```

### Authentication and Authorization

```javascript
// middleware/auth.middleware.js
import jwt from 'jsonwebtoken';
import { promisify } from 'util';

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRE = process.env.JWT_EXPIRE || '7d';

export class AuthMiddleware {
  static async authenticate(req, res, next) {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');
      
      if (!token) {
        return res.status(401).json({
          success: false,
          message: 'Access token required'
        });
      }

      const decoded = await promisify(jwt.verify)(token, JWT_SECRET);
      const user = await userService.findById(decoded.userId);
      
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Invalid token'
        });
      }

      req.user = user;
      next();
    } catch (error) {
      logger.error('Authentication error:', error);
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }
  }

  static authorize(roles = []) {
    return (req, res, next) => {
      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: 'Authentication required'
        });
      }

      if (roles.length && !roles.includes(req.user.role)) {
        return res.status(403).json({
          success: false,
          message: 'Insufficient permissions'
        });
      }

      next();
    };
  }
}
```

### Security Headers and CORS

```javascript
// middleware/security.middleware.js
import helmet from 'helmet';
import cors from 'cors';
import rateLimit from 'express-rate-limit';

// ✅ Good - Security headers
export const securityMiddleware = [
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true
    }
  }),

  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
    credentials: true,
    optionsSuccessStatus: 200
  }),

  // Rate limiting
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP',
    standardHeaders: true,
    legacyHeaders: false,
  })
];
```

### Environment Variables and Secrets

```javascript
// config/env.js
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default(3000),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  REDIS_URL: z.string().url().optional(),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info')
});

let env;

try {
  env = envSchema.parse(process.env);
} catch (error) {
  console.error('Invalid environment variables:', error.errors);
  process.exit(1);
}

export { env };

// ✅ Good - Never log sensitive data
export const sanitizeForLog = (obj) => {
  const sensitive = ['password', 'token', 'secret', 'key', 'authorization'];
  const sanitized = { ...obj };
  
  for (const key of Object.keys(sanitized)) {
    if (sensitive.some(s => key.toLowerCase().includes(s))) {
      sanitized[key] = '[REDACTED]';
    }
  }
  
  return sanitized;
};
```

---

## Data Validation with Zod

### Schema Definition and Organization

```typescript
// schemas/user.schema.ts
import { z } from 'zod';

// Base schemas for reusability
const PasswordSchema = z
  .string()
  .min(8, 'Password must be at least 8 characters')
  .max(128, 'Password must not exceed 128 characters')
  .regex(
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/,
    'Password must contain uppercase, lowercase, number, and special character'
  );

const EmailSchema = z
  .string()
  .email('Invalid email format')
  .max(255, 'Email must not exceed 255 characters')
  .toLowerCase()
  .trim();

// User schemas
export const CreateUserSchema = z.object({
  email: EmailSchema,
  name: z
    .string()
    .min(2, 'Name must be at least 2 characters')
    .max(100, 'Name must not exceed 100 characters')
    .trim(),
  password: PasswordSchema,
  role: z.enum(['admin', 'user', 'moderator']).default('user'),
  preferences: z
    .object({
      theme: z.enum(['light', 'dark']).default('light'),
      notifications: z.boolean().default(true),
      language: z.string().length(2).default('en'),
    })
    .optional(),
});

export const UpdateUserSchema = CreateUserSchema.partial().omit({ password: true });

export const LoginSchema = z.object({
  email: EmailSchema,
  password: z.string().min(1, 'Password is required'),
});

export const ChangePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: PasswordSchema,
  confirmPassword: z.string(),
}).refine(
  (data) => data.newPassword === data.confirmPassword,
  {
    message: 'Passwords do not match',
    path: ['confirmPassword'],
  }
);

// Export types
export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type UpdateUserInput = z.infer<typeof UpdateUserSchema>;
export type LoginInput = z.infer<typeof LoginSchema>;
export type ChangePasswordInput = z.infer<typeof ChangePasswordSchema>;
```

### API Route Validation Middleware

```typescript
// middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { AppError } from '../utils/errors.js';

export interface ValidatedRequest<T = any> extends Request {
  validatedData: T;
}

export function validateRequest<T>(
  schema: ZodSchema<T>,
  target: 'body' | 'query' | 'params' = 'body'
) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const data = req[target];
      const validated = schema.parse(data);
      
      // Add validated data to request object
      (req as ValidatedRequest<T>).validatedData = validated;
      
      // Replace original data with validated/transformed data
      req[target] = validated;
      
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const validationErrors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));

        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: validationErrors,
        });
      }
      
      next(error);
    }
  };
}

// Validation for nested request parts
export function validateMultiple(schemas: {
  body?: ZodSchema;
  query?: ZodSchema;
  params?: ZodSchema;
}) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const validated: any = {};

      if (schemas.body) {
        validated.body = schemas.body.parse(req.body);
        req.body = validated.body;
      }

      if (schemas.query) {
        validated.query = schemas.query.parse(req.query);
        req.query = validated.query;
      }

      if (schemas.params) {
        validated.params = schemas.params.parse(req.params);
        req.params = validated.params;
      }

      (req as any).validatedData = validated;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const validationErrors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));

        return res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors: validationErrors,
        });
      }
      
      next(error);
    }
  };
}
```

### Environment Variable Validation

```typescript
// config/env.ts - Enhanced with Zod
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z
    .string()
    .transform((val) => parseInt(val, 10))
    .refine((val) => val > 0 && val < 65536, 'Port must be between 1 and 65535')
    .default('3000'),
  
  // Database
  DATABASE_URL: z.string().url('Invalid database URL'),
  DATABASE_POOL_MIN: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 2))
    .refine((val) => val >= 0, 'Database pool min must be non-negative'),
  DATABASE_POOL_MAX: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 20))
    .refine((val) => val > 0, 'Database pool max must be positive'),
  
  // Authentication
  JWT_SECRET: z
    .string()
    .min(32, 'JWT secret must be at least 32 characters')
    .refine(
      (val) => !/^[a-zA-Z0-9]*$/.test(val),
      'JWT secret should contain special characters for better security'
    ),
  JWT_EXPIRE: z.string().default('7d'),
  
  // External services
  REDIS_URL: z.string().url('Invalid Redis URL').optional(),
  EMAIL_SERVICE_URL: z.string().url('Invalid email service URL').optional(),
  
  // Logging
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
  LOG_FILE_SIZE: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 5242880))
    .refine((val) => val > 0, 'Log file size must be positive'),
  
  // Security
  ALLOWED_ORIGINS: z
    .string()
    .transform((val) => val.split(',').map((origin) => origin.trim()))
    .default('http://localhost:3000'),
  RATE_LIMIT_WINDOW_MS: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 15 * 60 * 1000))
    .refine((val) => val > 0, 'Rate limit window must be positive'),
  RATE_LIMIT_MAX: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 100))
    .refine((val) => val > 0, 'Rate limit max must be positive'),
});

export type EnvConfig = z.infer<typeof EnvSchema>;

let env: EnvConfig;

try {
  env = EnvSchema.parse(process.env);
} catch (error) {
  if (error instanceof z.ZodError) {
    console.error('❌ Invalid environment configuration:');
    error.errors.forEach((err) => {
      console.error(`  ${err.path.join('.')}: ${err.message}`);
    });
    process.exit(1);
  }
  throw error;
}

export { env };
```

### Database Model Validation

```typescript
// models/user.model.ts
import { z } from 'zod';
import { CreateUserSchema } from '../schemas/user.schema.js';

// Database-specific schema with additional fields
const UserDbSchema = CreateUserSchema.extend({
  id: z.string().uuid(),
  hashedPassword: z.string(),
  emailVerified: z.boolean().default(false),
  lastLoginAt: z.date().nullable(),
  createdAt: z.date().default(() => new Date()),
  updatedAt: z.date().default(() => new Date()),
}).omit({ password: true });

export type UserDb = z.infer<typeof UserDbSchema>;

export class UserModel {
  async create(userData: CreateUserInput): Promise<UserDb> {
    // Validate input before database operation
    const validated = CreateUserSchema.parse(userData);
    
    const dbUser = {
      id: crypto.randomUUID(),
      ...validated,
      hashedPassword: await this.hashPassword(validated.password),
      emailVerified: false,
      lastLoginAt: null,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Validate complete database record
    const validatedDbUser = UserDbSchema.parse(dbUser);
    
    const result = await db.query(
      `INSERT INTO users (id, email, name, role, hashed_password, email_verified, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        validatedDbUser.id,
        validatedDbUser.email,
        validatedDbUser.name,
        validatedDbUser.role,
        validatedDbUser.hashedPassword,
        validatedDbUser.emailVerified,
        validatedDbUser.createdAt,
        validatedDbUser.updatedAt,
      ]
    );

    return UserDbSchema.parse(result.rows[0]);
  }

  async findById(id: string): Promise<UserDb | null> {
    const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
    
    if (result.rows.length === 0) return null;
    
    // Validate data coming from database
    return UserDbSchema.parse(result.rows[0]);
  }
}
```

### API Route Integration

```typescript
// routes/user.routes.ts
import { Router } from 'express';
import { validateRequest, validateMultiple } from '../middleware/validation.middleware.js';
import { authenticate, authorize } from '../middleware/auth.middleware.js';
import { 
  CreateUserSchema,
  UpdateUserSchema,
  UserFilterSchema,
  IdParamSchema 
} from '../schemas/user.schema.js';
import { UserController } from '../controllers/user.controller.js';

const router = Router();
const userController = new UserController();

// POST /api/users - Create user
router.post(
  '/',
  validateRequest(CreateUserSchema, 'body'),
  userController.createUser
);

// GET /api/users - List users with filters
router.get(
  '/',
  authenticate,
  authorize(['admin']),
  validateRequest(UserFilterSchema, 'query'),
  userController.getUsers
);

// PUT /api/users/:id - Update user
router.put(
  '/:id',
  authenticate,
  validateMultiple({
    params: IdParamSchema,
    body: UpdateUserSchema,
  }),
  userController.updateUser
);

export { router as userRoutes };
```

---

## Performance Optimization

### Clustering and Process Management

```javascript
// cluster.js - For production use
import cluster from 'cluster';
import os from 'os';
import { logger } from './src/utils/logger.js';

const numCPUs = os.cpus().length;

if (cluster.isPrimary) {
  logger.info(`Primary ${process.pid} is running`);
  
  // Fork workers
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    logger.warn(`Worker ${worker.process.pid} died`);
    cluster.fork(); // Replace dead worker
  });
} else {
  // Worker processes
  import('./src/app.js');
  logger.info(`Worker ${process.pid} started`);
}
```

### Caching Strategies

```javascript
// services/cache.service.js
import Redis from 'ioredis';
import { env } from '../config/env.js';

class CacheService {
  constructor() {
    this.redis = new Redis(env.REDIS_URL);
  }

  async get(key) {
    try {
      const data = await this.redis.get(key);
      return data ? JSON.parse(data) : null;
    } catch (error) {
      logger.error('Cache get error:', error);
      return null;
    }
  }

  async set(key, value, ttl = 3600) {
    try {
      await this.redis.setex(key, ttl, JSON.stringify(value));
    } catch (error) {
      logger.error('Cache set error:', error);
    }
  }

  async del(key) {
    try {
      await this.redis.del(key);
    } catch (error) {
      logger.error('Cache delete error:', error);
    }
  }

  // ✅ Good - Cache wrapper pattern
  async cached(key, fn, ttl = 3600) {
    const cached = await this.get(key);
    if (cached) return cached;

    const result = await fn();
    await this.set(key, result, ttl);
    return result;
  }
}

export const cacheService = new CacheService();

// Usage example
export class UserService {
  async getUserProfile(userId) {
    return await cacheService.cached(
      `user:profile:${userId}`,
      () => this.userRepository.findById(userId),
      1800 // 30 minutes
    );
  }
}
```

### Database Optimization

```javascript
// ✅ Good - Connection pooling and optimization
import { Pool } from 'pg';
import { env } from '../config/env.js';

const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max: 20, // Maximum pool size
  min: 2,  // Minimum pool connections
  idle: 10000, // Close connections after 10 seconds of inactivity
  acquireTimeoutMillis: 60000,
  createTimeoutMillis: 30000,
  destroyTimeoutMillis: 5000,
  reapIntervalMillis: 1000,
});

export class DatabaseService {
  async query(text, params = []) {
    const start = Date.now();
    
    try {
      const result = await pool.query(text, params);
      const duration = Date.now() - start;
      
      logger.debug('Database query executed', {
        query: text,
        duration,
        rows: result.rowCount
      });
      
      return result;
    } catch (error) {
      logger.error('Database query error:', {
        query: text,
        params: sanitizeForLog(params),
        error: error.message
      });
      throw error;
    }
  }

  async transaction(callback) {
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');
      const result = await callback(client);
      await client.query('COMMIT');
      return result;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }
}

export const db = new DatabaseService();
```

---

## Error Handling & Logging

### Structured Error Handling

```javascript
// utils/errors.js
export class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;
    
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message, field = null) {
    super(message, 400, 'VALIDATION_ERROR');
    this.field = field;
  }
}

export class NotFoundError extends AppError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized access') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

// middleware/error.middleware.js
export const errorHandler = (error, req, res, next) => {
  let { statusCode = 500, message, code } = error;

  // Handle specific error types
  if (error.name === 'ValidationError') {
    statusCode = 400;
    code = 'VALIDATION_ERROR';
  } else if (error.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
    code = 'INVALID_ID';
  }

  logger.error('Request error:', {
    message: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    }
  });
};
```

### Advanced Logging

```javascript
// utils/logger.js
import winston from 'winston';
import { env } from '../config/env.js';

const logFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf(({ timestamp, level, message, stack, ...meta }) => {
    return JSON.stringify({
      timestamp,
      level,
      message,
      ...(stack && { stack }),
      ...meta
    });
  })
);

export const logger = winston.createLogger({
  level: env.LOG_LEVEL,
  format: logFormat,
  defaultMeta: { service: 'api' },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    }),
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
      maxsize: 5242880,
      maxFiles: 5
    })
  ]
});

// Request logging middleware
export const requestLogger = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    
    logger.info('HTTP Request', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration,
      userAgent: req.get('User-Agent'),
      ip: req.ip
    });
  });
  
  next();
};
```

---

## Modern Tooling

### Biome Configuration for Node.js

```json
{
  "$schema": "https://biomejs.dev/schemas/1.8.0/schema.json",
  "files": {
    "include": [
      "src/**/*.js",
      "src/**/*.ts",
      "tests/**/*.js",
      "tests/**/*.ts"
    ],
    "ignore": [
      "node_modules",
      "dist",
      "build",
      "logs"
    ]
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "suspicious": {
        "noExplicitAny": "error",
        "noDebugger": "error"
      },
      "security": {
        "noDangerouslySetInnerHtml": "error"
      },
      "correctness": {
        "noUnusedVariables": "error"
      }
    }
  }
}
```

### Package.json Scripts

```json
{
  "type": "module",
  "scripts": {
    "dev": "nodemon --exec node --loader ts-node/esm src/app.ts",
    "build": "tsc",
    "start": "node dist/app.js",
    "start:cluster": "node cluster.js",
    "lint": "biome lint ./src",
    "lint:fix": "biome lint --apply ./src", 
    "format": "biome format --write ./src",
    "type-check": "tsc --noEmit",
    "test": "NODE_ENV=test vitest",
    "test:coverage": "NODE_ENV=test vitest --coverage",
    "check": "biome check --apply && npm run type-check",
    "ci": "npm run check && npm run test && npm run build"
  }
}
```

### Environment Management

```bash
# .env.example
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname
JWT_SECRET=your-super-secure-secret-key-at-least-32-characters
JWT_EXPIRE=7d
REDIS_URL=redis://localhost:6379
LOG_LEVEL=info
ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

---

## Best Practices Summary

### Security & Safety
1. **Input Validation**: Always validate and sanitize user input
2. **Environment Variables**: Use proper env validation and never log secrets
3. **Security Headers**: Implement helmet, CORS, and rate limiting
4. **Authentication**: Use JWT with proper expiration and secure storage
5. **Error Handling**: Never expose sensitive information in errors

### Performance & Scalability
6. **Clustering**: Use cluster module or PM2 for production
7. **Caching**: Implement Redis caching for frequently accessed data
8. **Database**: Use connection pooling and optimize queries
9. **Async Patterns**: Use Promise.all for parallel operations
10. **Memory Management**: Monitor and prevent memory leaks

### Code Quality & Maintainability
- **Biome**: Use for fast, consistent formatting and linting
- **TypeScript**: Add type safety to catch errors early
- **Testing**: Write comprehensive unit and integration tests
- **Logging**: Structured logging with proper log levels
- **Documentation**: Keep API documentation up to date

---

*This style guide covers modern Node.js best practices focusing on security, performance, and maintainability as of 2024.*