# Domain Model (v1)

## Core Entities

### Project
- **Attributes:**
  - name, description
  - start_date, due_date (optional)
  - status: planned | active | on_hold | completed | cancelled
  - priority_number (1–5)
  - priority_tags (array)
  - next_action (short text, optional)
- **Relationships:**
  - has many Tasks
  - has many Entries (journal/notes)
  - has many ActivityLogs

### Task
- **Attributes:**
  - title, description
  - start_date, due_date (optional)
  - status: todo | in_progress | blocked | done | deferred
  - priority_number (1–5)
  - priority_tags (array)
  - effort_estimate (free-form string)
  - next_action (short text, optional)
  - is_blocked (computed)
- **Relationships:**
  - belongs to Project
  - belongs to parent Task (for subtasks)
  - has many subtasks
  - has many TaskDependencies
  - has many Entries
  - has many ActivityLogs

### TaskDependency
- **Attributes:**
  - predecessor_task_id
  - successor_task_id
  - type: finish_to_start (only in v1)

### Entry
- **Attributes:**
  - entry_type: progress | reflection | blocker | idea | decision | note
  - body (text)
  - tags (array, optional)
  - author: user | ai
  - created_at
- **Relationships:**
  - belongs to Project or Task (optional)
  - belongs to User
  - has many ActivityLogs

### ActivityLog
- **Attributes:**
  - actor: user | ai
  - action: created_task | updated_status | added_note | changed_priority | etc.
  - target (polymorphic)
  - payload (JSON snapshot)
  - created_at

### Conversation
- **Attributes:**
  - purpose (e.g., “Daily check-in”)
  - created_at
- **Relationships:**
  - has many Messages

### Message
- **Attributes:**
  - role: user | ai
  - content (text)
  - created_at
- **Relationships:**
  - belongs to Conversation
  - has many ToolActions

### ToolAction
- **Attributes:**
  - action_type: create_task | update_task | add_entry | set_dependency | etc.
  - params (JSON)
  - rationale (text)
  - created_at
- **Relationships:**
  - belongs to Message
  - belongs to target (polymorphic)

### Tags
- Tag (controlled vocab: urgent, important, quick_win, deep_work)
- Tagging (polymorphic link to Project, Task, Entry)

## Derived Objects
- StatusSnapshot: summarizes recent Entries, open tasks, blockers, next_action
- PriorityEngine: computes priority score from priority number, tags, due dates
