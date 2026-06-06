# Planning Methodology

> Extracted from industry best practices for autonomous development planning.

---

## Phase 0: Deep Codebase Investigation (MANDATORY)

**Before ANY planning, thoroughly investigate the existing codebase.**

### 0.1: Understand Project Structure

```bash
# Get comprehensive directory structure
find . -type f -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" | head -100
ls -la
```

Identify:
- Main entry points (main.py, app.py, index.ts, etc.)
- Configuration files (settings.py, config.py, .env.example)
- Directory organization patterns

### 0.2: Analyze Existing Patterns

**This is the most important step.** For whatever feature you're building, find SIMILAR existing features:

```bash
# Example: If building "caching", search for existing cache implementations
grep -r "cache" --include="*.py" . | head -30

# Example: If building "API endpoint", find existing endpoints
grep -r "@app.route\|@router\|def get_\|def post_" --include="*.py" . | head -30
```

**YOU MUST READ AT LEAST 3 PATTERN FILES** before planning:
- Files with similar functionality to what you're building
- Files in the same service you'll be modifying
- Configuration files for the technology you'll use

### 0.3: Document Your Findings

Before creating the implementation plan, explicitly document:

1. **Existing patterns found**: "The codebase uses X pattern for Y"
2. **Files that are relevant**: "app/services/cache.py already exists with..."
3. **Technology stack**: "Redis is already configured in settings.py"
4. **Conventions observed**: "All API endpoints follow the pattern..."

---

## Workflow Types

Different workflows require different phase structures:

### FEATURE Workflow (Multi-Service Features)

Phases follow service dependency order:
1. **Backend/API Phase** - Can be tested with curl
2. **Worker Phase** - Background jobs (depend on backend)
3. **Frontend Phase** - UI components (depend on backend APIs)
4. **Integration Phase** - Wire everything together

### REFACTOR Workflow (Stage-Based Changes)

Phases follow migration stages:
1. **Add New Phase** - Build new system alongside old
2. **Migrate Phase** - Move consumers to new system
3. **Remove Old Phase** - Delete deprecated code
4. **Cleanup Phase** - Polish and verify

### INVESTIGATION Workflow (Bug Hunting)

Phases follow debugging process:
1. **Reproduce Phase** - Create reliable reproduction, add logging
2. **Investigate Phase** - Analyze, form hypotheses, **output: root cause**
3. **Fix Phase** - Implement solution (BLOCKED until phase 2 completes)
4. **Harden Phase** - Add tests, prevent recurrence

### MIGRATION Workflow (Data Pipeline)

Phases follow data flow:
1. **Prepare Phase** - Write scripts, setup
2. **Test Phase** - Small batch, verify
3. **Execute Phase** - Full migration
4. **Cleanup Phase** - Remove old, verify

### SIMPLE Workflow (Single-Service Quick Tasks)

Minimal overhead - just subtasks, no phases.

---

## Subtask Decomposition

### Why Subtasks, Not Tests?

Tests verify outcomes. Subtasks define implementation steps.

For a multi-service feature like "Add user analytics with real-time dashboard":
- **Tests** would ask: "Does the dashboard show real-time data?" (But HOW do you get there?)
- **Subtasks** say: "First build the backend events API, then the aggregation worker, then the WebSocket service, then the dashboard component."

### Subtask Dependencies

```
Phase 1: Backend     [depends_on: []]           → Can start immediately
Phase 2: Worker      [depends_on: ["phase-1"]]  → Blocked until Phase 1 done
Phase 3: Frontend    [depends_on: ["phase-1"]]  → Blocked until Phase 1 done
Phase 4: Integration [depends_on: ["phase-2", "phase-3"]] → Blocked until both done
```

### Subtask Structure

```json
{
    "id": "subtask-1",
    "title": "Implement user events API",
    "service": "backend",
    "files_to_modify": ["app/routes/events.py", "app/models/event.py"],
    "patterns_from": ["app/routes/users.py"],
    "depends_on": [],
    "parallel_group": 1,
    "verification": {
        "type": "api",
        "command": "curl -X POST localhost:8000/api/events",
        "expected_status": 201
    },
    "status": "pending"
}
```

---

## Context Files

### Project Index (project structure)

```json
{
    "project_type": "single|monorepo",
    "services": {
        "backend": {
            "path": ".",
            "tech_stack": ["python", "fastapi"],
            "port": 8000,
            "dev_command": "uvicorn main:app --reload",
            "test_command": "pytest"
        }
    },
    "infrastructure": {
        "docker": false,
        "database": "postgresql"
    },
    "conventions": {
        "linter": "ruff",
        "formatter": "black",
        "testing": "pytest"
    }
}
```

### Task Context (what to modify)

```json
{
    "files_to_modify": {
        "backend": ["app/services/existing_service.py", "app/routes/api.py"]
    },
    "files_to_reference": ["app/services/similar_service.py"],
    "patterns": {
        "service_pattern": "All services inherit from BaseService",
        "route_pattern": "Routes use APIRouter with prefix and tags"
    },
    "existing_implementations": {
        "description": "Found existing caching in app/utils/cache.py",
        "relevant_files": ["app/utils/cache.py", "app/config.py"]
    }
}
```

---

## Harmony Integration

In Harmony Framework:
- Use `/harmony analyst` for requirements gathering
- Use `/harmony architect` for technical planning
- Leverage ARIA detector for context flags
- Store implementation plan in `.harmony/memory/plans/`
