# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data in development
if Rails.env.development?
  TaskDependency.destroy_all
  Task.destroy_all
  Project.destroy_all
end

# Create sample projects
project1 = Project.create!(
  name: "Website Redesign",
  description: "Complete overhaul of company website with modern design and improved user experience",
  status: :active,
  priority_number: 4,
  priority_tags: [ "urgent", "important" ],
  start_date: 1.week.ago,
  due_date: 2.months.from_now,
  next_action: "Finalize wireframes with design team"
)

project2 = Project.create!(
  name: "Q4 Marketing Campaign",
  description: "Plan and execute marketing campaign for Q4 product launch",
  status: :planned,
  priority_number: 3,
  priority_tags: [ "important" ],
  start_date: 2.weeks.from_now,
  due_date: 3.months.from_now,
  next_action: "Schedule kickoff meeting with marketing team"
)

project3 = Project.create!(
  name: "Internal Tool Development",
  description: "Build internal productivity tools for team collaboration",
  status: :active,
  priority_number: 2,
  priority_tags: [ "deep_work" ],
  start_date: 3.days.ago,
  due_date: 6.weeks.from_now,
  next_action: "Research existing tools and define requirements"
)

# Create tasks for Website Redesign
wireframes = project1.tasks.create!(
  title: "Create wireframes",
  description: "Design wireframes for all main pages including homepage, about, and contact",
  status: :in_progress,
  priority_number: 4,
  priority_tags: [ "urgent" ],
  effort_estimate: "1 week",
  position: 1
)

research = project1.tasks.create!(
  title: "User research",
  description: "Conduct user interviews and analyze current website analytics",
  status: :done,
  priority_number: 3,
  effort_estimate: "3 days",
  position: 2
)

development = project1.tasks.create!(
  title: "Frontend development",
  description: "Implement the new design using modern web technologies",
  status: :todo,
  priority_number: 4,
  priority_tags: [ "important" ],
  effort_estimate: "3 weeks",
  position: 3
)

testing = project1.tasks.create!(
  title: "Testing and QA",
  description: "Comprehensive testing across different browsers and devices",
  status: :todo,
  priority_number: 3,
  effort_estimate: "1 week",
  position: 4
)

# Create subtasks for frontend development
frontend_setup = project1.tasks.create!(
  title: "Set up development environment",
  description: "Configure build tools, frameworks, and development workflow",
  parent_task: development,
  status: :todo,
  priority_number: 4,
  effort_estimate: "1 day",
  position: 1
)

frontend_components = project1.tasks.create!(
  title: "Build reusable components",
  description: "Create component library for consistent UI elements",
  parent_task: development,
  status: :todo,
  priority_number: 3,
  effort_estimate: "1 week",
  position: 2
)

# Create dependencies
TaskDependency.create!(predecessor_task: research, successor_task: wireframes)
TaskDependency.create!(predecessor_task: wireframes, successor_task: development)
TaskDependency.create!(predecessor_task: development, successor_task: testing)
TaskDependency.create!(predecessor_task: frontend_setup, successor_task: frontend_components)

# Create tasks for Marketing Campaign
campaign_strategy = project2.tasks.create!(
  title: "Develop campaign strategy",
  description: "Define target audience, messaging, and campaign objectives",
  status: :todo,
  priority_number: 4,
  effort_estimate: "1 week",
  position: 1
)

content_creation = project2.tasks.create!(
  title: "Create campaign content",
  description: "Design graphics, write copy, and produce video content",
  status: :todo,
  priority_number: 3,
  effort_estimate: "2 weeks",
  position: 2
)

# Create tasks for Internal Tool
requirements = project3.tasks.create!(
  title: "Gather requirements",
  description: "Interview team members and document tool requirements",
  status: :in_progress,
  priority_number: 3,
  effort_estimate: "1 week",
  position: 1
)

prototype = project3.tasks.create!(
  title: "Build prototype",
  description: "Create basic prototype to validate concepts",
  status: :todo,
  priority_number: 2,
  effort_estimate: "2 weeks",
  position: 2
)

# Add dependency for marketing campaign
TaskDependency.create!(predecessor_task: campaign_strategy, successor_task: content_creation)

# Add dependency for internal tool
TaskDependency.create!(predecessor_task: requirements, successor_task: prototype)

puts "Created #{Project.count} projects with #{Task.count} tasks and #{TaskDependency.count} dependencies"
