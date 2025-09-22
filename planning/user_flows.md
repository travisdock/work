# Example User Flows

## Phase 1: Basic Project & Task Tracking

### Create a new project with tasks
1. User creates project "Redesign Website" with start date, high priority, tags.
2. System saves Project.
3. User adds tasks (wireframes, stakeholder review).
4. System creates Tasks and Dependency.

### Check blocked tasks
1. User opens project.
2. System shows tasks, flags blocked ones.

---

## Phase 2: Notes & Journaling

### Add a progress entry
1. User marks wireframes task as done.
2. System updates status, logs ActivityLog.
3. User adds Entry: "Wireframes finished...".

### Review snapshot
1. User opens project after break.
2. System shows snapshot with last entry, next task, status.

---

## Phase 3: AI Integration

### Ask "Where was I?"
1. User: "Where was I on Redesign Website?"
2. AI reads last entry, open tasks.
3. AI responds with summary of progress and suggestions.

### Ask "What should I work on today?"
1. User: "What should I work on today?"
2. AI applies PriorityEngine, finds top task.
3. AI suggests task, offers to mark as next action.
4. User confirms.
5. AI updates Task via ToolAction.

### Journal via AI
1. User: "I'm stuck on Task Y."
2. AI adds blocker Entry, suggests follow-up subtask.
3. User agrees.
4. AI creates subtask and dependency.
