# UI Design Guide: Notebook Aesthetic

## Design Philosophy
A digital tool that feels like a fresh, professional notebook with subtle character. The interface should evoke the feeling of pencil on graph paper - primarily clean and minimal, but with thoughtful hand-drawn accents that make it feel human. Older content gradually gains character, like pages naturally wearing over time.

## Visual Foundation

### Color Palette
```css
/* Primary Colors - Pencil on Paper */
--pencil-dark: #2B2B2B;      /* Main text - soft graphite */
--pencil-medium: #5A5A5A;    /* Secondary text - lighter pencil */
--pencil-light: #8A8A8A;     /* Tertiary text - faint pencil */
--pencil-faint: #CACACA;     /* Very light marks - erased pencil */

/* Paper Colors */
--paper-white: #FAFAF8;      /* Slightly warm white - notebook paper */
--paper-aged: #F5F5F0;       /* Older pages - subtle yellowing */
--grid-line: #D6E3F0;        /* Light blue grid lines */
--grid-line-faint: #E8F0F7; /* Aged grid lines */

/* Accent Colors (used sparingly) */
--accent-blue: #4A90E2;      /* Light blue for subtle accents */
--highlight-yellow: #FFF3CD;  /* Yellow highlighter effect */
--highlight-yellow-faint: #FFFBEB; /* Faded highlighter */

/* Minimal Additional Colors */
--error-red: #E74C3C;        /* Only for critical errors */
--success-green: #27AE60;    /* Only for success confirmations */
```

### Typography
```css
/* Font Stack */
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-decorative: 'Kalam', 'Marker Felt', cursive; /* For handwritten accents */

/* Font Weights - Mimicking pencil pressure */
--weight-light: 300;    /* Light pencil strokes */
--weight-regular: 400;  /* Normal writing */
--weight-medium: 500;   /* Pressed pencil */
--weight-bold: 600;     /* Heavy pencil emphasis */

/* Font Sizes */
--text-xs: 0.75rem;     /* Margin notes */
--text-sm: 0.875rem;    /* Secondary text */
--text-base: 1rem;      /* Body text */
--text-lg: 1.125rem;    /* Subheadings */
--text-xl: 1.25rem;     /* Headings */
--text-2xl: 1.5rem;     /* Page titles */
```

### Background & Textures
```css
/* Graph Paper Background */
.notebook-page {
  background-color: var(--paper-white);
  background-image:
    /* Subtle paper texture */
    url('data:image/svg+xml;...'), /* noise texture */
    /* Grid pattern */
    linear-gradient(var(--grid-line) 1px, transparent 1px),
    linear-gradient(90deg, var(--grid-line) 1px, transparent 1px);
  background-size:
    100% 100%,
    20px 20px,
    20px 20px;
  background-position:
    0 0,
    -1px -1px,
    -1px -1px;
}

/* Subtle paper shadow for depth */
.page-container {
  box-shadow:
    0 1px 3px rgba(0, 0, 0, 0.05),
    0 10px 40px rgba(0, 0, 0, 0.02);
}
```

## Component Design Patterns

### 1. Page Layout
```
+----------------------------------------------------------+
|  [Clean notebook page with subtle grid]                  |
|  +----------------------------------------------------+  |
|  |                                                    |  |
|  |  Single Column Content (on grid background)        |  |
|  |                                                    |  |
|  |  • Left margin: 60px (for priority marks)         |  |
|  |  • Right margin: 40px                             |  |
|  |  • Max width: 720px (single column)               |  |
|  |  • Top/bottom padding: 40px                       |  |
|  |                                                    |  |
|  +----------------------------------------------------+  |
|                                                          |
+----------------------------------------------------------+
```

### 2. Navigation
- **Notebook Tabs**: Clean tabbed sections like notebook dividers
  - Projects, Tasks, Notes sections as tabs
  - Simple underline for active tab
  - Tab labels in clean sans-serif
  - Optional: Small hand-drawn asterisk next to active tab

### 3. Projects List
```css
.project-card {
  /* Looks like a notebook section divider */
  border-bottom: 2px solid var(--pencil-light);
  position: relative;
}

.project-card::before {
  /* Decorative asterisk or bullet point in margin */
  content: "✱";
  position: absolute;
  left: -30px;
  color: var(--pencil-light);
  font-family: var(--font-decorative);
}

.project-priority {
  /* Circled numbers in margin for priority */
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 1.5px solid var(--pencil-medium);
  border-radius: 50%;
  /* Slightly imperfect circle */
  border-radius: 48% 52% 49% 51%;
}
```

### 4. Task Lists
```css
.task-item {
  /* Indented outline style */
  padding-left: calc(var(--indent-level) * 24px);
  position: relative;
}

/* Connecting lines for hierarchy */
.task-item::before {
  content: "";
  position: absolute;
  left: calc(var(--indent-level) * 24px - 12px);
  top: 12px;
  width: 10px;
  border-bottom: 1px solid var(--pencil-faint);
  border-left: 1px solid var(--pencil-faint);
}

.task-checkbox {
  /* Hand-drawn checkbox appearance */
  width: 16px;
  height: 16px;
  border: 1.5px solid var(--pencil-medium);
  border-radius: 2px;
  /* Slightly imperfect square */
  transform: rotate(-0.5deg);
}

.task-checkbox:checked::after {
  /* Checkmark that looks hand-drawn */
  content: "✓";
  font-family: var(--font-decorative);
  color: var(--pencil-dark);
  font-size: 14px;
}

.task-blocked {
  /* Simple faded appearance for now */
  opacity: 0.7;
  color: var(--pencil-light);
}
```

### 5. Forms & Inputs
```css
.input-box {
  /* Hand-drawn box appearance */
  border: 1.5px solid var(--pencil-medium);
  border-radius: 3px;
  background: transparent;
  padding: 8px 12px;
  /* Slightly imperfect rectangle */
  border-radius: 4px 3px 4px 3px;
  transform: rotate(-0.2deg);
}

.input-box:focus {
  /* Darker pencil when active */
  border-color: var(--pencil-dark);
  outline: none;
  transform: rotate(0deg); /* Straighten on focus */
}

.input-field {
  /* Alternative: underline style for inline edits */
  border: none;
  border-bottom: 1px solid var(--pencil-light);
  background: transparent;
  padding: 4px 0;
}

.textarea-field {
  /* Lined paper effect */
  background-image: repeating-linear-gradient(
    var(--paper-white) 0px,
    var(--paper-white) 24px,
    var(--pencil-faint) 25px
  );
  line-height: 25px;
  padding: 0;
  border: 1.5px solid var(--pencil-light);
  border-radius: 3px 4px 3px 4px;
}
```

### 6. Buttons
```css
.btn-primary {
  /* Clean, modern button */
  background: var(--accent-blue);
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 16px;
  font-weight: var(--weight-medium);
  transition: all 0.2s ease;
}

.btn-primary:hover {
  /* Standard hover state */
  background: darken(var(--accent-blue), 10%);
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-secondary {
  /* Outlined button */
  background: transparent;
  color: var(--pencil-dark);
  border: 1px solid var(--pencil-medium);
  border-radius: 4px;
  padding: 8px 16px;
}

.btn-secondary:hover {
  background: var(--paper-shadow);
  border-color: var(--pencil-dark);
}

.btn-text {
  /* Text-only button with subtle underline */
  background: none;
  border: none;
  color: var(--accent-blue);
  text-decoration: underline;
  text-underline-offset: 2px;
  text-decoration-thickness: 1px;
}
```

### 7. Status Indicators
```css
/* Priority Marks (in margin) - Hand-drawn style */
.priority-mark {
  position: absolute;
  left: -30px;
  font-family: var(--font-decorative);
  color: var(--pencil-medium);
}

.priority-high::before {
  content: "!!!";
  color: var(--pencil-dark);
}
.priority-medium::before {
  content: "!!";
}
.priority-low::before {
  content: "!";
}

/* Hand-drawn checkbox states */
.checkbox-empty {
  border: 1.5px solid var(--pencil-medium);
  border-radius: 2px 3px 2px 3px;
}

.checkbox-checked::after {
  content: "✓";
  font-family: var(--font-decorative);
  color: var(--pencil-dark);
}

/* Status Badges */
.status-todo {
  /* Empty checkbox */
  opacity: 0.8;
}
.status-in-progress {
  /* Partially filled with blue accent */
  background: linear-gradient(90deg, var(--accent-blue) 50%, transparent 50%);
}
.status-done {
  /* Checkmark */
  text-decoration: line-through;
  opacity: 0.6;
}
.status-blocked {
  /* Simple faded state */
  opacity: 0.5;
  color: var(--pencil-light);
}

/* Due Date Indicators */
.due-soon {
  /* Yellow highlighter effect */
  background: linear-gradient(transparent 60%, var(--highlight-yellow) 60%);
}

.overdue {
  /* Subtle red accent */
  color: var(--error-red);
}
```

## Decorative Elements

### Margin Doodles
Subtle hand-drawn elements that appear sparingly:
- Simple arrows (→, ↗, ↩) for active items
- Asterisks (✱) for important items
- Small circles (◯) for bullet points
- Check marks (✓) for completed items
- Brackets { } for grouped content
- Underlines for emphasis
- Appear primarily on hover or for active states

### Empty States
```css
.empty-state {
  /* Centered doodle with handwritten text */
  text-align: center;
  opacity: 0.5;
}

.empty-state::before {
  /* Large decorative doodle */
  content: "";
  display: block;
  width: 120px;
  height: 120px;
  background: url('notebook-doodle-empty.svg');
  margin: 0 auto 20px;
}

.empty-state-text {
  font-family: var(--font-decorative);
  color: var(--pencil-light);
  font-size: var(--text-lg);
}
```

### Loading States
- Pencil drawing effect animation
- Dots appearing like writing "..."
- Page flip animation

### Page Aging Effects
```css
/* Fresh pages (new projects/tasks) */
.page-fresh {
  background-color: var(--paper-white);
  --grid-color: var(--grid-line);
}

/* Aged pages (older projects > 30 days) */
.page-aged {
  background-color: var(--paper-aged);
  --grid-color: var(--grid-line-faint);
  /* Subtle wear */
  box-shadow:
    inset 0 0 20px rgba(0, 0, 0, 0.02),
    0 1px 3px rgba(0, 0, 0, 0.05);
}

/* Well-worn pages (> 90 days) */
.page-worn {
  background-color: var(--paper-aged);
  --grid-color: var(--grid-line-faint);
  /* More visible wear */
  box-shadow:
    inset 0 0 30px rgba(0, 0, 0, 0.03),
    0 1px 5px rgba(0, 0, 0, 0.06);
  /* Slight texture */
  background-image:
    url('paper-texture-worn.svg'),
    linear-gradient(var(--grid-color) 1px, transparent 1px),
    linear-gradient(90deg, var(--grid-color) 1px, transparent 1px);
}

/* Completed/archived content */
.content-archived {
  opacity: 0.6;
  filter: sepia(0.1);
}
```

## Interaction Patterns

### Hover Effects
```css
.interactive-element:hover {
  /* Standard hover - slightly darker */
  color: var(--pencil-dark);
  cursor: pointer;
}

.task-item:hover {
  /* Subtle background highlight */
  background: linear-gradient(transparent 70%, var(--highlight-yellow-faint) 70%);
}

.clickable-item:hover::before {
  /* Optional: Small margin indicator */
  content: "•";
  position: absolute;
  left: -15px;
  color: var(--accent-blue);
  opacity: 0;
  animation: fade-in 0.2s forwards;
}
```

### Focus States
```css
.focused-element {
  /* Dotted pencil outline */
  outline: 1px dashed var(--pencil-medium);
  outline-offset: 4px;
  background: rgba(255, 255, 255, 0.5);
}
```

### Transitions
```css
/* Soft, paper-like transitions */
* {
  transition-duration: 0.2s;
  transition-timing-function: ease-out;
}

/* Page transitions */
.page-transition {
  animation: paper-flip 0.3s ease-in-out;
}
```

## Responsive Considerations

### Mobile (< 768px)
- Single column layout (already default)
- Grid background scales to 15px
- Margins reduced to 20px
- Touch-friendly tap targets (44px minimum)
- Simplified margin decorations

### Tablet (768px - 1024px)
- Single column maintained
- Grid maintains 20px
- Side margins at 40px
- Full decorative elements visible

### Desktop (> 1024px)
- Single column with generous margins
- Maximum content width: 720px (like a notebook page)
- Full margin space for priority marks and doodles
- Grid at 20px for clarity

## Implementation Notes

### CSS Architecture
- **No external CSS frameworks** (no Tailwind, Bootstrap, etc.)
- **Pure CSS only** - no preprocessors (SCSS, LESS, etc.)
- Use CSS custom properties (CSS variables) for theming
- Modern CSS features (Grid, Flexbox, custom properties)
- Component-based CSS architecture with BEM naming convention
- All styles in standard .css files

### File Organization
```
app/assets/stylesheets/
├── application.css       # Main stylesheet, imports all others
├── base/
│   ├── reset.css         # Normalize browser defaults
│   ├── variables.css     # CSS custom properties
│   ├── typography.css    # Font definitions and text styles
│   └── grid.css          # Graph paper background
├── components/
│   ├── buttons.css       # Button styles
│   ├── forms.css         # Input and form elements
│   ├── cards.css         # Project and task cards
│   ├── checkboxes.css    # Hand-drawn checkbox styles
│   └── navigation.css    # Tabs and nav elements
├── layouts/
│   ├── page.css          # Page container and margins
│   └── notebook.css      # Notebook-specific layouts
└── utilities/
    ├── spacing.css       # Margin and padding utilities
    ├── states.css        # Hover, focus, active states
    └── aging.css         # Page wear effects
```

### CSS Naming Convention (BEM)
```css
/* Block */
.task-card { }

/* Element */
.task-card__title { }
.task-card__checkbox { }

/* Modifier */
.task-card--blocked { }
.task-card--priority-high { }

/* State classes */
.is-active { }
.is-completed { }
.has-children { }
```

### SVG Assets Needed
1. Paper texture pattern
2. Scribble/cross-out patterns
3. Margin doodles set (10-15 variations)
4. Hand-drawn checkbox styles
5. Eraser smudge effects
6. Loading animation pencil

### JavaScript Enhancements
- Age calculation for page wear (based on created_at)
- Slight rotation on hand-drawn elements (-0.5 to 0.5 degrees)
- Smooth transitions between states
- Optional: subtle animation for checkbox checking

### Accessibility
- Maintain WCAG AA contrast ratios
- Decorative elements marked as aria-hidden
- Clear focus indicators
- Semantic HTML structure preserved
- Alternative text for all meaningful doodles

## Example Component Compositions

### Project Card
```html
<div class="project-card">
  <div class="margin-mark priority-3">③</div>
  <h3 class="project-title">Website Redesign</h3>
  <span class="task-count">12 tasks</span>
  <span class="due-date">Due in 5 days</span>
  <div class="margin-doodle">→</div>
</div>
```

### Task Item
```html
<div class="task-item indent-1">
  <input type="checkbox" class="task-checkbox">
  <span class="task-title">Create wireframes</span>
  <span class="effort-estimate">(~2h)</span>
  <span class="status-indicator in-progress">◐</span>
</div>
```

## Do's and Don'ts

### Do's ✓
- Keep the overall design clean and professional
- Use hand-drawn elements sparingly as accents
- Maintain consistent grid alignment for content
- Let whitespace breathe like a real notebook page
- Use subtle aging effects for older content
- Keep buttons modern and functional
- Use light blue and yellow accents thoughtfully

### Don'ts ✗
- Don't overuse decorative elements
- Don't make it look too playful or childish
- Avoid too many imperfections - keep it mostly clean
- Don't use hand-drawn styles for critical UI (buttons)
- Don't clutter margins - keep them mostly empty
- Avoid strong colors - stay subtle

## Brand Personality
**Professional • Minimal • Thoughtful • Clean • Subtly Human**

The UI should feel like a fresh, professional notebook with just enough character to feel approachable - clean lines with occasional hand-drawn accents that add warmth without compromising functionality.