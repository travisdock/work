# Phase 1: Basic Project & Task Tracking - Detailed Implementation Plan

## Executive Summary
Phase 1 implements the core project and task management functionality, creating a standalone, usable tracking system without AI integration. This foundation will support hierarchical tasks, dependencies, and priority management.

## Goals
- Create a fully functional project/task tracker usable without AI
- Establish the data model foundation for future phases
- Implement core business logic for task dependencies and blocking
- Provide a clean, intuitive user interface

## Core Entities

### 1. Project Model
**Attributes:**
- `name` (string, required): Project title
- `description` (text): Detailed project description
- `start_date` (date, optional): When project begins
- `due_date` (date, optional): Target completion date
- `status` (enum): planned | active | on_hold | completed | cancelled
- `priority_number` (integer): 1-5 scale (5 = highest)
- `priority_tags` (array): Tags like urgent, important, quick_win, deep_work
- `next_action` (string, optional): Brief description of immediate next step

**Key Methods:**
- `active?`, `completed?`, `overdue?`: Status helpers
- `high_priority?`: Returns true if priority_number >= 4
- `tasks_summary`: Returns count of tasks by status
- `blocked_tasks`: Returns all blocked tasks in project

### 2. Task Model
**Attributes:**
- `title` (string, required): Task name
- `description` (text): Detailed task description
- `project_id` (reference, required): Parent project
- `parent_task_id` (reference, optional): For subtask hierarchy
- `start_date` (date, optional): When task can begin
- `due_date` (date, optional): Target completion date
- `status` (enum): todo | in_progress | blocked | done | deferred
- `priority_number` (integer): 1-5 scale
- `priority_tags` (array): Inherited or custom tags
- `effort_estimate` (string): Free-form (e.g., "2 hours", "1 day")
- `next_action` (string, optional): Immediate next step
- `position` (integer): For ordering within project/parent

**Key Methods:**
- `subtasks`: Returns child tasks
- `is_blocked?`: Checks if blocked by dependencies
- `blocking_tasks`: Returns tasks that must complete first
- `can_start?`: Checks if all dependencies are met
- `mark_as_blocked!`: Updates status if dependencies incomplete
- `complete!`: Marks done and checks dependent tasks

### 3. TaskDependency Model
**Attributes:**
- `predecessor_task_id` (reference, required): Task that must complete first
- `successor_task_id` (reference, required): Task that depends on predecessor
- `dependency_type` (string): "finish_to_start" (only type in Phase 1)

**Validations:**
- Prevent self-dependencies
- Prevent duplicate dependencies
- Detect and prevent circular dependencies
- Ensure tasks are in same project

## Implementation Breakdown

### Step 1: Database Schema (Day 1)
```ruby
# Migration: create_projects
- name: string, null: false
- description: text
- start_date: date
- due_date: date
- status: integer, default: 0
- priority_number: integer, default: 3
- priority_tags: text (serialized array)
- next_action: string
- timestamps

# Migration: create_tasks
- title: string, null: false
- description: text
- project_id: references, null: false, foreign_key: true
- parent_task_id: references, foreign_key: { to_table: :tasks }
- start_date: date
- due_date: date
- status: integer, default: 0
- priority_number: integer, default: 3
- priority_tags: text (serialized array)
- effort_estimate: string
- next_action: string
- position: integer
- timestamps
- indexes on [project_id, status], [parent_task_id]

# Migration: create_task_dependencies
- predecessor_task_id: references, null: false, foreign_key: { to_table: :tasks }
- successor_task_id: references, null: false, foreign_key: { to_table: :tasks }
- dependency_type: string, default: "finish_to_start"
- timestamps
- unique index on [predecessor_task_id, successor_task_id]
```

### Step 2: Model Implementation (Day 1-2)

**Project Model:**
- Validations for required fields, status, priority range
- Has_many associations with dependent: :destroy
- Scopes: active, by_priority, overdue
- Methods for status management and task summaries

**Task Model:**
- Self-referential association for subtasks
- Validations including custom validator for circular parent references
- Callbacks to check blocking status after save
- Scopes: root_tasks, blocked, by_priority, incomplete
- Complex logic for dependency checking

**TaskDependency Model:**
- Custom validator for circular dependency detection using graph traversal
- Callbacks to update successor task blocking status

### Step 3: Controllers (Day 2-3)

**ProjectsController:**
```ruby
# Actions: index, show, new, create, edit, update, destroy, archive
- Strong parameters for all project attributes
- Set project priority tags from checkboxes
- Handle status transitions
```

**TasksController:**
```ruby
# Nested under projects
# Actions: index, show, new, create, edit, update, destroy, complete
- Handle parent_task_id for subtask creation
- Ajax support for status updates
- Reordering support for task position
```

**TaskDependenciesController:**
```ruby
# Actions: create, destroy
- Ajax-only controller
- Return updated blocking status after changes
```

### Step 4: Views and UI (Day 3-4)

**Layouts:**
- Application layout with navigation
- Project sidebar for active project context
- Flash messages for success/error notifications

**Project Views:**
- `index`: Grid/list view with status badges, priority indicators
- `show`: Task tree with expand/collapse, dependency visualization
- `_form`: Fields for all attributes, priority tag checkboxes
- `_project_card`: Reusable component for project display

**Task Views:**
- `_task_tree`: Recursive partial for hierarchical display
- `_task_row`: Individual task with inline status editing
- `_form`: Parent task selector, dependency management
- `new_subtask`: Modal for quick subtask creation
- Visual indicators: 🔒 for blocked, 🔥 for high priority, ⏰ for overdue

**Styling:**
- Use Tailwind CSS or Bootstrap 5
- Color coding: red for blocked, yellow for in_progress, green for done
- Indent subtasks visually
- Hover effects for interactive elements

### Step 5: Features Implementation (Day 4-5)

**Priority System:**
- Combined score from priority_number and tags
- Sort tasks by calculated priority
- Visual priority indicators (colors, icons)

**Dependency Management:**
- Dropdown to add dependencies when editing task
- Visual graph showing task dependencies
- Automatic blocked status calculation
- Clear blocking reason display

**Task Hierarchy:**
- Drag-and-drop to reorganize (using Sortable.js)
- Bulk operations on parent + subtasks
- Collapse/expand tree nodes
- Breadcrumb navigation

**Quick Actions:**
- One-click status changes
- Inline edit for next_action field
- Keyboard shortcuts (n for new task, p for new project)

### Step 6: Testing (Day 5-6)

**Model Tests:**
```ruby
# test/models/project_test.rb
- Validation tests
- Status transition tests
- Priority calculation tests
- Association tests

# test/models/task_test.rb
- Blocking logic tests
- Subtask hierarchy tests
- Dependency validation tests
- Status update cascade tests

# test/models/task_dependency_test.rb
- Circular dependency prevention tests
- Cross-project dependency tests
```

**Controller Tests:**
```ruby
- CRUD operations for all controllers
- Authorization tests (if implementing)
- Ajax response tests
- Error handling tests
```

**System Tests:**
```ruby
# test/system/project_management_test.rb
- Create project with tasks flow
- Add dependencies and verify blocking
- Complete task and verify unblocking
- Reorder tasks flow
```

### Step 7: Seed Data (Day 6)

Create realistic sample data:
```ruby
# db/seeds.rb
- 3 sample projects (Website Redesign, Product Launch, Q4 Planning)
- 15-20 tasks with subtasks
- Various dependency chains
- Different priority levels and statuses
- Examples of blocked tasks
```

## User Flows

### Flow 1: Create Project with Initial Tasks
1. Click "New Project" button
2. Fill in project details, set priority and tags
3. Save project, redirect to project page
4. Click "Add Task" to create first task
5. Add subtasks using "Add Subtask" button
6. Set dependencies between tasks

### Flow 2: Manage Task Dependencies
1. Edit a task
2. In dependencies section, select predecessor task
3. Save task
4. System automatically marks as blocked if predecessor incomplete
5. Complete predecessor task
6. System automatically unblocks dependent task

### Flow 3: Update Task Status
1. View project task list
2. Click status dropdown on task row
3. Select new status
4. Ajax update without page reload
5. If marking complete, check for dependent tasks to unblock

## Success Criteria

### Functional Requirements
✅ Projects can be created, edited, archived
✅ Tasks support full hierarchy with unlimited nesting
✅ Dependencies prevent task completion order violations
✅ Blocked tasks are automatically detected and marked
✅ Priority system combines number and tags effectively
✅ All CRUD operations work correctly

### Performance Requirements
✅ Task tree loads quickly even with 100+ tasks
✅ Status updates happen without page reload
✅ Dependency checks complete in < 100ms

### Usability Requirements
✅ Clear visual hierarchy for tasks
✅ Obvious indicators for blocked/high-priority tasks
✅ Intuitive dependency management
✅ Mobile-responsive design

## Technical Decisions

### Architecture Choices
- **Monolithic Rails app**: Simpler for Phase 1, can extract services later
- **Server-side rendering**: Use Turbo for interactivity, avoid SPA complexity
- **PostgreSQL**: Better for arrays (priority_tags) if switching from SQLite
- **Stimulus.js**: For JavaScript interactivity within Rails conventions

### Code Organization
- Fat models, thin controllers
- Service objects for complex operations (e.g., `DependencyValidator`)
- View components for reusable UI elements
- Concerns for shared model behavior

### Future Considerations
- API endpoints for Phase 3 AI integration
- Event sourcing preparation via ActivityLog
- Soft deletes for data recovery
- Multi-tenancy support structure

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|---------|------------|
| Circular dependency edge cases | High | Comprehensive graph traversal algorithm with tests |
| Performance with deep task trees | Medium | Implement counter caches, consider nested set model |
| Complex UI for dependencies | Medium | Start simple, iterate based on user feedback |
| Status transition bugs | Low | State machine gem (AASM) if needed |

## Definition of Done

Phase 1 is complete when:
1. All models, controllers, and views are implemented
2. Test coverage is above 90%
3. Manual testing confirms all user flows work
4. Seed data demonstrates all features
5. Documentation is complete (README, CLAUDE.md updates)
6. Code passes all linting checks (RuboCop)
7. Performance benchmarks are met
8. Basic responsive design works on mobile

## Next Steps (Phase 2 Preview)
- Add Entry model for notes and journaling
- Implement ActivityLog for audit trail
- Create StatusSnapshot for project summaries
- Add tagging system for entries
- Build timeline view of activities

## Estimated Timeline
- **Day 1**: Database schema and models
- **Day 2**: Model completion and controllers
- **Day 3**: Views and basic UI
- **Day 4**: Advanced features and interactivity
- **Day 5**: Testing and bug fixes
- **Day 6**: Seed data, documentation, and polish

Total: 6 development days for fully functional Phase 1