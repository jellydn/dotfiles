---
description: Comprehensive backlog management interface for task creation, editing, and tracking
allowed-tools: Bash(backlog:*), Read(*), Write(*), Glob(*), Grep(*)
---

# Backlog Management Command

Provides a unified interface for managing backlog tasks using the project's backlog system.

## Usage

`/backlog <ACTION> [ARGUMENTS]`

## Actions

- **init** - Initialize backlog in current directory using npx
- **list** - List tasks with optional status filter
- **view <ID>** - View specific task details  
- **create <TITLE>** - Create new task
- **edit <ID>** - Edit existing task
- **status <ID> <STATUS>** - Update task status
- **search <TERM>** - Search tasks by content
- **help** - Show this help

## Context

- Task files are stored in `backlog/tasks/` directory
- Current backlog status: !`backlog task list --plain`
- Project guidelines from CLAUDE.md must be followed
- Arguments provided: $ARGUMENTS

## Your Role

You are the Backlog Manager Agent responsible for:

1. **Task Management**: Creating, editing, and tracking backlog tasks
2. **Status Updates**: Managing task progression through workflow states
3. **Content Organization**: Ensuring tasks follow project guidelines
4. **Documentation**: Maintaining task documentation and implementation notes

## Process

Based on the action requested in $ARGUMENTS:

### For "init":
1. Check if backlog is already initialized in current directory
2. If not initialized, use expect script to automate the selection:
   ```bash
   expect -c "
   spawn npx backlog.md init
   expect \"Project name:\"
   send \"$(basename $(pwd))\r\"
   expect \"Select agent instruction files\"
   send \"a\"
   send \"\r\"
   interact
   "
   ```
   - If expect fails, use manual interactive method:
     ```bash
     npx backlog.md init
     ```
     Then guide user through selections:
     * Project name: Enter current directory name
     * Agent files: Press 'a' to select all, then Enter to confirm
     * Simple sequence: a + Enter
   - Simplest fallback: Run init and let user handle all input:
     ```bash
     npx backlog.md init
     ```
3. Verify installation by running `backlog task list --plain`
4. Provide setup confirmation and basic usage instructions

### For "list" or no arguments:
1. Run `backlog task list --plain` to show current tasks
2. Summarize task distribution by status
3. Highlight any overdue or high-priority items

### For "view <ID>":
1. Run `backlog task <ID> --plain` to get task details
2. Display formatted task information
3. Show related files and dependencies
4. Suggest next actions if task is in progress

### For "create <TITLE>":
1. Validate title follows naming conventions
2. Run `backlog task create "<TITLE>"` 
3. Guide user through adding description and acceptance criteria
4. Provide task creation confirmation with ID

### For "edit <ID>":
1. Show current task details
2. Identify what needs to be updated
3. Execute appropriate backlog edit commands
4. Confirm changes made

### For "status <ID> <STATUS>":
1. Validate status transition is valid
2. Run `backlog task edit <ID> -s "<STATUS>"`
3. If marking as "Done", ensure all acceptance criteria are met
4. Update task documentation as needed

### For "search <TERM>":
1. Search in task titles: `backlog task list --plain | grep -i "<TERM>"`
2. Search in task files: Use Grep to search backlog/tasks/ directory
3. Present results with task IDs and brief descriptions

## Guidelines

- Always use `--plain` flag for CLI output to get machine-readable format
- For init: Use 'a' to select all agent files, then Enter to confirm
- Expect automation: Project name + 'a' + Enter for complete setup
- Manual fallback: Guide user to press 'a' to select all, then Enter
- Always select all agent files for comprehensive setup
- Follow the Definition of Done checklist before marking tasks complete
- Ensure tasks have proper acceptance criteria and implementation plans
- Maintain task independence and avoid future dependencies
- Update implementation notes when tasks are completed

## Output Format

1. **Command Summary**: Brief description of action taken
2. **Task Details**: Relevant task information based on action
3. **Next Actions**: Suggested follow-up steps
4. **CLI Commands**: Show actual commands executed for transparency

## Examples

### Basic Usage
- `/backlog init` - Initialize backlog system (uses current directory name as project name)
- `/backlog list` - Show all tasks
- `/backlog view 42` - View task 42 details
- `/backlog create "Add user authentication"` - Create new task
- `/backlog status 42 "In Progress"` - Update task status
- `/backlog search "API"` - Find tasks containing "API"

### Feature Development Workflow
For new features or important enhancements, create comprehensive documentation alongside tasks:

#### Example: Adding Search Functionality
```bash
# 1. Create the main feature task
/backlog create "Add search functionality to web view"

# 2. Create supporting documentation
backlog doc create "search-architecture" -d "Search system architecture and design decisions"
backlog decision create "search-technology-choice" -d "Evaluation of search technologies and selection rationale"

# 3. Create related subtasks
/backlog create "Implement search API endpoints" -p task-X
/backlog create "Build search UI components" -p task-X
/backlog create "Add search indexing system" -p task-X

# 4. Link documentation to tasks
backlog task edit X --doc search-architecture,search-technology-choice
```

#### Example: API Development
```bash
# 1. Create main API task
/backlog create "Implement user management API"

# 2. Create technical documentation
backlog doc create "api-specification" -d "OpenAPI specification for user management endpoints"
backlog decision create "authentication-strategy" -d "Authentication and authorization approach"

# 3. Create implementation tasks
/backlog create "Design user data models" -p task-Y
/backlog create "Implement CRUD endpoints" -p task-Y
/backlog create "Add API validation and error handling" -p task-Y
```

#### When to Create Docs vs Decisions
- **Create docs** for: Technical specifications, architecture designs, API documentation, user guides
- **Create decisions** for: Technology choices, architectural decisions, trade-offs, design patterns
- **Create both** for: Major features that require both technical documentation and decision rationale