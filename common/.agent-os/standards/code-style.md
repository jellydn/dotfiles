# Code Style Guide

## Context

Global code style rules for Agent OS projects.

<conditional-block context-check="general-formatting">
IF this General Formatting section already read in current context:
  SKIP: Re-reading this section
  NOTE: "Using General Formatting rules already in context"
ELSE:
  READ: The following formatting rules

## General Formatting

### Indentation
- Use 2 spaces for indentation (never tabs)
- Maintain consistent indentation throughout files
- Align nested structures for readability

### Naming Conventions
- **Methods and Variables**: Use snake_case (e.g., `user_profile`, `calculate_total`)
- **Classes and Modules**: Use PascalCase (e.g., `UserProfile`, `PaymentProcessor`)
- **Constants**: Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### String Formatting
- Use single quotes for strings: `'Hello World'`
- Use double quotes only when interpolation is needed
- Use template literals for multi-line strings or complex interpolation

### Code Comments
- Add brief comments above non-obvious business logic
- Document complex algorithms or calculations
- Explain the "why" behind implementation choices
- Never remove existing comments unless removing the associated code
- Update comments when modifying code to maintain accuracy
- Keep comments concise and relevant
</conditional-block>

<conditional-block task-condition="html-css" context-check="html-css-style">
IF current task involves writing or updating HTML or CSS:
  IF html-style.md AND css-style.md already in context:
    SKIP: Re-reading these files
    NOTE: "Using HTML/CSS style guides already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get HTML formatting rules from code-style/html-style.md"
        REQUEST: "Get CSS rules from code-style/css-style.md"
        PROCESS: Returned style rules
      ELSE:
        READ the following style guides (only if not already in context):
        - @.agent-os/standards/code-style/html-style.md (if not in context)
        - @.agent-os/standards/code-style/css-style.md (if not in context)
    </context_fetcher_strategy>
ELSE:
  SKIP: HTML/CSS style guides not relevant to current task
</conditional-block>

<conditional-block task-condition="tailwindcss" context-check="tailwindcss-style">
IF current task involves writing or updating TailwindCSS:
  IF tailwindcss-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using TailwindCSS style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get TailwindCSS style rules from code-style/tailwindcss-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/tailwindcss-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: TailwindCSS style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="javascript" context-check="javascript-style">
IF current task involves writing or updating JavaScript:
  IF javascript-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using JavaScript style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get JavaScript style rules from code-style/javascript-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/javascript-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: JavaScript style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="typescript" context-check="typescript-style">
IF current task involves writing or updating TypeScript:
  IF typescript-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using TypeScript style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get TypeScript style rules from code-style/typescript-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/typescript-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: TypeScript style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="react" context-check="react-style">
IF current task involves writing or updating React components:
  IF react-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using React style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get React style rules from code-style/react-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/react-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: React style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="react-native" context-check="react-native-style">
IF current task involves writing or updating React Native code:
  IF react-native-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using React Native style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get React Native style rules from code-style/react-native-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/react-native-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: React Native style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="nextjs" context-check="nextjs-style">
IF current task involves writing or updating Next.js code:
  IF nextjs-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Next.js style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Next.js style rules from code-style/nextjs-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/nextjs-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Next.js style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="nodejs" context-check="nodejs-style">
IF current task involves writing or updating Node.js code:
  IF nodejs-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Node.js style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Node.js style rules from code-style/nodejs-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/nodejs-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Node.js style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="bun" context-check="bun-style">
IF current task involves writing or updating Bun code:
  IF bun-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Bun style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Bun style rules from code-style/bun-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/bun-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Bun style guide not relevant to current task
</conditional-block>

<conditional-block task-condition="moleculer" context-check="moleculer-style">
IF current task involves writing or updating Moleculer microservices:
  IF moleculer-style.md already in context:
    SKIP: Re-reading this file
    NOTE: "Using Moleculer style guide already in context"
  ELSE:
    <context_fetcher_strategy>
      IF current agent is Claude Code AND context-fetcher agent exists:
        USE: @agent:context-fetcher
        REQUEST: "Get Moleculer microservices style rules from code-style/moleculer-style.md"
        PROCESS: Returned style rules
      ELSE:
        read: @.agent-os/standards/code-style/moleculer-style.md
    </context_fetcher_strategy>
ELSE:
  SKIP: Moleculer style guide not relevant to current task
</conditional-block>
