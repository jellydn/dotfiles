# JavaScript Style Guide

A comprehensive style guide for modern JavaScript development following industry best practices.

## Core Principles

- **Readability**: Write code that tells a story - make it clear, self-documenting
- **Single Responsibility**: Functions should do one thing and do it well
- **Meaningful Names**: Use searchable, pronounceable, descriptive names
- **Consistency**: Maintain uniform code style across the entire codebase
- **Modern Standards**: Use latest ES6+ features and established patterns
- **Performance**: Leverage fast, Rust-based tooling for instant feedback

## Table of Contents

1. [Variables & Constants](#variables--constants)
2. [Functions](#functions)
3. [Objects](#objects)
4. [Arrays](#arrays)
5. [Classes](#classes)
6. [Modules](#modules)
7. [Conditionals](#conditionals)
8. [Loops](#loops)
9. [Promises & Async/Await](#promises--asyncawait)
10. [Comments](#comments)
11. [Formatting](#formatting)
12. [Modern JavaScript Features](#modern-javascript-features)
13. [Tool Configuration](#tool-configuration)

---

## Variables & Constants

### Use `const` by default, `let` when reassignment needed

```javascript
// ❌ Bad
var name = 'John';
var age = 30;

// ✅ Good
const name = 'John';
let age = 30;
```

### Use meaningful and searchable names

```javascript
// ❌ Bad - What is 'd'? What is '86400000'?
const d = new Date();
const u = users.filter(x => x.active);
setTimeout(blastOff, 86400000);

// ✅ Good - Names tell a story
const currentDate = new Date();
const activeUsers = users.filter(user => user.active);
const MILLISECONDS_IN_DAY = 86400000;
setTimeout(blastOff, MILLISECONDS_IN_DAY);
```

### Avoid mental mapping

```javascript
// ❌ Bad - What does 'i' represent here?
const locations = ['Austin', 'New York', 'San Francisco'];
locations.forEach(i => {
  doStuff();
  doSomeOtherStuff();
  // ...
  dispatch(i);
});

// ✅ Good - Explicit is better
locations.forEach(location => {
  doStuff();
  doSomeOtherStuff();
  // ...
  dispatch(location);
});
```

### Use camelCase for variables and functions

```javascript
// ❌ Bad
const user_name = 'john';
const USER_ID = 123;

// ✅ Good
const userName = 'john';
const userId = 123;
```

---

## Functions

### Use arrow functions for callbacks and short functions

```javascript
// ❌ Bad
const numbers = [1, 2, 3];
const doubled = numbers.map(function(num) {
  return num * 2;
});

// ✅ Good
const numbers = [1, 2, 3];
const doubled = numbers.map(num => num * 2);
```

### Use function declarations for named functions

```javascript
// ❌ Bad
const calculateArea = function(radius) {
  return Math.PI * radius * radius;
};

// ✅ Good
function calculateArea(radius) {
  return Math.PI * radius * radius;
}
```

### Use default parameters

```javascript
// ❌ Bad
function greet(name) {
  name = name || 'Guest';
  return `Hello, ${name}!`;
}

// ✅ Good
function greet(name = 'Guest') {
  return `Hello, ${name}!`;
}
```

### Use rest parameters instead of `arguments`

```javascript
// ❌ Bad
function sum() {
  const args = Array.prototype.slice.call(arguments);
  return args.reduce((total, num) => total + num, 0);
}

// ✅ Good
function sum(...numbers) {
  return numbers.reduce((total, num) => total + num, 0);
}
```

### Limit function arguments (ideally ≤ 2)

```javascript
// ❌ Bad - Too many parameters
function createMenu(title, body, buttonText, cancellable) {
  // ...
}

// ✅ Good - Use object parameters
function createMenu({ title, body, buttonText, cancellable }) {
  // ...
}

createMenu({
  title: 'Foo',
  body: 'Bar',
  buttonText: 'Baz',
  cancellable: true
});
```

---

## Objects

### Use object shorthand

```javascript
const name = 'John';
const age = 30;

// ❌ Bad
const user = {
  name: name,
  age: age,
  greet: function() {
    return `Hello, I'm ${this.name}`;
  }
};

// ✅ Good
const user = {
  name,
  age,
  greet() {
    return `Hello, I'm ${this.name}`;
  }
};
```

### Use destructuring

```javascript
const user = { name: 'John', age: 30, city: 'NYC' };

// ❌ Bad
const name = user.name;
const age = user.age;

// ✅ Good
const { name, age } = user;
```

### Only quote properties that are invalid identifiers

```javascript
// ❌ Bad
const config = {
  'apiUrl': 'https://api.example.com',
  'timeout': 5000,
  'data-source': 'database'
};

// ✅ Good
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  'data-source': 'database'
};
```

### Use computed property names when appropriate

```javascript
const key = 'dynamicKey';

// ❌ Bad
const obj = {};
obj[key] = 'value';

// ✅ Good
const obj = {
  [key]: 'value'
};
```

---

## Arrays

### Use array literals

```javascript
// ❌ Bad
const items = new Array();

// ✅ Good
const items = [];
```

### Use destructuring for array assignment

```javascript
const coords = [10, 20];

// ❌ Bad
const x = coords[0];
const y = coords[1];

// ✅ Good
const [x, y] = coords;
```

### Use spread operator for copying arrays

```javascript
const original = [1, 2, 3];

// ❌ Bad
const copy = original.slice();

// ✅ Good
const copy = [...original];
```

### Use array methods instead of loops when possible

```javascript
const numbers = [1, 2, 3, 4, 5];

// ❌ Bad
const doubled = [];
for (let i = 0; i < numbers.length; i++) {
  doubled.push(numbers[i] * 2);
}

// ✅ Good
const doubled = numbers.map(num => num * 2);
```

---

## Classes

### Use class syntax

```javascript
// ❌ Bad
function Person(name, age) {
  this.name = name;
  this.age = age;
}
Person.prototype.greet = function() {
  return `Hello, I'm ${this.name}`;
};

// ✅ Good
class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  greet() {
    return `Hello, I'm ${this.name}`;
  }
}
```

### Use class methods that reference `this` or make them static

```javascript
// ❌ Bad
class MathUtils {
  add(a, b) {
    return a + b; // doesn't use this
  }
}

// ✅ Good
class MathUtils {
  static add(a, b) {
    return a + b;
  }

  calculate() {
    return this.value * 2; // uses this
  }
}
```

---

## Modules

### Use ES6 modules

```javascript
// ❌ Bad
const utils = require('./utils');
module.exports = MyClass;

// ✅ Good
import { utilities } from './utils.js';
export default MyClass;
```

### Use named exports for utilities, default for main classes

```javascript
// utils.js
export const formatDate = (date) => { /* */ };
export const calculateAge = (birthDate) => { /* */ };

// User.js
export default class User {
  /* */
}

// importing
import User from './User.js';
import { formatDate, calculateAge } from './utils.js';
```

### Group imports logically

```javascript
// ✅ Good
// External libraries
import React from 'react';
import axios from 'axios';

// Internal modules
import User from './User.js';
import { formatDate } from './utils.js';

// Relative imports
import './styles.css';
```

---

## Conditionals

### Use strict equality

```javascript
// ❌ Bad
if (value == 10) { /* */ }

// ✅ Good
if (value === 10) { /* */ }
```

### Use explicit comparisons for strings and numbers

```javascript
// ❌ Bad
if (name) { /* */ }
if (items.length) { /* */ }

// ✅ Good
if (name !== '') { /* */ }
if (items.length > 0) { /* */ }
```

### Use ternary operators for simple conditions

```javascript
// ❌ Bad
let message;
if (isLoggedIn) {
  message = 'Welcome back!';
} else {
  message = 'Please log in';
}

// ✅ Good
const message = isLoggedIn ? 'Welcome back!' : 'Please log in';
```

---

## Loops

### Use `for...of` for arrays, `for...in` for objects

```javascript
const items = ['a', 'b', 'c'];
const obj = { a: 1, b: 2, c: 3 };

// ✅ Good
for (const item of items) {
  console.log(item);
}

for (const key in obj) {
  if (obj.hasOwnProperty(key)) {
    console.log(key, obj[key]);
  }
}
```

### Prefer array methods over traditional loops

```javascript
const numbers = [1, 2, 3, 4, 5];

// ❌ Bad
const evens = [];
for (let i = 0; i < numbers.length; i++) {
  if (numbers[i] % 2 === 0) {
    evens.push(numbers[i]);
  }
}

// ✅ Good
const evens = numbers.filter(num => num % 2 === 0);
```

---

## Promises & Async/Await

### Use async/await over raw Promises

```javascript
// ❌ Bad
function fetchUser(id) {
  return fetch(`/users/${id}`)
    .then(response => response.json())
    .then(user => {
      console.log(user);
      return user;
    })
    .catch(error => {
      console.error(error);
      throw error;
    });
}

// ✅ Good
async function fetchUser(id) {
  try {
    const response = await fetch(`/users/${id}`);
    const user = await response.json();
    console.log(user);
    return user;
  } catch (error) {
    console.error(error);
    throw error;
  }
}
```

### Handle errors properly

```javascript
// ✅ Good
async function processData() {
  try {
    const data = await fetchData();
    const processed = await processItem(data);
    return processed;
  } catch (error) {
    logger.error('Failed to process data:', error);
    throw new ProcessingError('Data processing failed', error);
  }
}
```

---

## Comments

### Use `//` for single line comments

```javascript
// ✅ Good
// Calculate the total price including tax
const totalPrice = basePrice * (1 + taxRate);
```

### Use JSDoc for function documentation

```javascript
/**
 * Calculates the area of a circle
 * @param {number} radius - The radius of the circle
 * @returns {number} The area of the circle
 */
function calculateCircleArea(radius) {
  return Math.PI * radius * radius;
}
```

### Add space after comment delimiters

```javascript
// ❌ Bad
//This is a comment
/*This is a block comment*/

// ✅ Good
// This is a comment
/* This is a block comment */
```

---

## Formatting

### Use 2-space indentation

```javascript
// ✅ Good
function example() {
  if (condition) {
    doSomething();
  }
}
```

### Use trailing commas in multiline structures

```javascript
// ✅ Good
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
};

const items = [
  'first',
  'second',
  'third',
];
```

### Use consistent spacing

```javascript
// ✅ Good
const result = calculate(a, b);
const obj = { key: 'value' };
if (condition) { /* */ }
function test() { return true; }
```

### Use proper line breaks for method chaining

```javascript
// ✅ Good
const result = data
  .filter(item => item.active)
  .map(item => item.name)
  .sort()
  .join(', ');
```

### Single newline at end of files

```javascript
// ✅ Good - file ends with single newline
export default MyClass;

```

---

## Modern JavaScript Features

### Use ES2023+ Array Methods

```javascript
// ✅ Good - Use new array methods that don't mutate
const numbers = [3, 1, 4, 1, 5];

// Instead of sort() which mutates
const sorted = numbers.toSorted(); 

// Instead of reverse() which mutates  
const reversed = numbers.toReversed();

// Find from the end
const lastEven = numbers.findLast(n => n % 2 === 0);
const lastEvenIndex = numbers.findLastIndex(n => n % 2 === 0);

// Safe array updates
const updated = numbers.with(2, 999); // Replace index 2 with 999
```

### Use Optional Chaining and Nullish Coalescing

```javascript
// ✅ Good
const userEmail = user?.profile?.email ?? 'no-email@example.com';
const port = process.env.PORT ?? 3000;

// ✅ Good - Safe method calls
api?.connect?.();
```

### Use Private Class Fields

```javascript
// ✅ Good
class BankAccount {
  #balance = 0;
  #accountNumber;

  constructor(initialBalance, accountNumber) {
    this.#balance = initialBalance;
    this.#accountNumber = accountNumber;
  }

  getBalance() {
    return this.#balance;
  }

  #validateTransaction(amount) {
    return amount > 0 && amount <= this.#balance;
  }
}
```

### Use Template Literals

```javascript
// ❌ Bad
const message = 'Hello, ' + name + '! You have ' + count + ' items.';

// ✅ Good
const message = `Hello, ${name}! You have ${count} items.`;
```

---

## Modern Tooling

### Biome - All-in-One Toolchain (Recommended)

**Why Biome?** 25x faster than Prettier, 15x faster than ESLint. Single tool for formatting and linting.

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
    "include": ["src/**/*.js", "src/**/*.ts", "src/**/*.jsx", "src/**/*.tsx"],
    "ignore": ["node_modules", "dist", "build"]
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
        "noDoubleEquals": "error",
        "noDebugger": "warn"
      },
      "style": {
        "useConst": "error",
        "useTemplate": "error",
        "noVar": "error"
      },
      "correctness": {
        "noUnusedVariables": "error"
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

#### Package.json Scripts (Biome)

```json
{
  "scripts": {
    "lint": "biome lint ./src",
    "lint:fix": "biome lint --apply ./src",
    "format": "biome format --write ./src",
    "check": "biome check --apply ./src",
    "ci": "biome ci ./src"
  }
}
```

---

### oxlint - Ultra-Fast Linter Alternative

**Why oxlint?** 50-100x faster than ESLint. 500+ ESLint rules supported.

#### Installation & Usage

```bash
# Quick try without installation
npx --yes oxlint@latest

# Install globally
npm install -g oxlint

# Run oxlint
oxlint
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
    "eslint/no-unused-vars": "error",
    "eslint/no-debugger": "warn",
    "eslint/eqeqeq": "error",
    "typescript/no-explicit-any": "warn",
    "react/jsx-no-undef": "error"
  },
  "plugins": ["react", "typescript", "jsx-a11y"],
  "ignorePatterns": ["dist/", "node_modules/", "*.config.js"],
  "settings": {
    "react": {
      "version": "detect"
    }
  }
}
```

#### Hybrid ESLint + oxlint Setup

```bash
# Install oxlint plugin for ESLint
npm install -D eslint-plugin-oxlint
```

```javascript
// eslint.config.js (ESLint v9)
import oxlint from 'eslint-plugin-oxlint';

export default [
  // your other configs
  ...oxlint.configs['flat/recommended'], // oxlint should be last
];
```

#### Package.json Scripts (oxlint)

```json
{
  "scripts": {
    "lint": "oxlint",
    "lint:fix": "oxlint --fix",
    "format": "biome format --write ./src",
    "check": "oxlint && biome check --apply ./src"
  }
}
```

---

### Tool Comparison

| Tool | Speed | Features | Setup |
|------|-------|----------|-------|
| **Biome** | 25x faster | Format + Lint | Single config |
| **oxlint** | 50-100x faster | Lint only | Minimal config |  
| ESLint + Prettier | Baseline | Full ecosystem | Complex setup |

### Recommended Stack

**For new projects:** Biome (all-in-one)  
**For performance-critical:** oxlint + Biome formatter  
**For maximum compatibility:** ESLint + Prettier (legacy)

---

## Best Practices Summary

### Clean Code Principles
1. **Single Responsibility**: Each function does one thing well
2. **Meaningful Names**: Use searchable, pronounceable, intention-revealing names  
3. **Function Arguments**: Limit to 2 or fewer parameters using objects
4. **No Mental Mapping**: Explicit is better than implicit
5. **Remove Duplication**: Abstract common functionality

### Modern Development
6. **Performance Tooling**: Use Rust-based tools (Biome, oxlint) for instant feedback
7. **Modern Syntax**: Leverage ES2023+ features like `toSorted()`, `findLast()`
8. **Functional Approach**: Prefer immutable operations and array methods
9. **Error Handling**: Always handle errors appropriately with try/catch
10. **Type Safety**: Consider TypeScript for larger projects

### Automation
- **Biome**: All-in-one formatting and linting (25x faster)
- **oxlint**: Ultra-fast linting only (50-100x faster)  
- **CI Integration**: Use `biome ci` or `oxlint` in pipelines
- **Editor Integration**: Configure auto-fix on save

---

*This style guide follows modern JavaScript best practices as of 2024, incorporating clean code principles and the latest ES2023/ES2024 features with performance-focused Rust tooling.*
