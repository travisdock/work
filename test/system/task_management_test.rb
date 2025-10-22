require "application_system_test_case"

class TaskManagementTest < ApplicationSystemTestCase
  setup do
    @user = system_test_user
    @project = @user.projects.create!(
      name: "Test Project",
      description: "A project for testing tasks",
      status: :active,
      priority_number: 3
    )
  end

  test "user cannot access tasks from another user's project" do
    other_user = users(:two)
    other_project = other_user.projects.create!(
      name: "Other User Project",
      description: "Hidden from current user",
      status: :active,
      priority_number: 4
    )
    other_task = other_project.tasks.create!(
      title: "Other User Task",
      description: "Should not be visible",
      status: :todo,
      priority_number: 3
    )

    visit project_path(other_project)
    assert_text "ActiveRecord::RecordNotFound"

    visit project_task_path(other_project, other_task)
    assert_text "ActiveRecord::RecordNotFound"

    visit tasks_path
    assert_no_text other_task.title
  end

  test "user can create a task within a project" do
    visit project_path(@project)

    # Should see no tasks initially
    assert_text "No tasks yet"

    # Click to create a new task
    click_on "New Task"

    # Should be on the new task page
    assert_text "New Task"
    assert_text "in #{@project.name}"

    # Fill in the task form
    fill_in "Title", with: "First Task"
    fill_in "Description", with: "This is the first task in the project"
    select "3", from: "Priority (1-5)"
    fill_in "Effort estimate", with: "2 hours"
    check "Urgent"
    fill_in "Next action", with: "Start coding"

    # Submit the form
    click_on "Create Task"

    # Should be redirected to the task show page
    assert_text "First Task"
    assert_text "This is the first task in the project"
    assert_text "Task was successfully created"
  end

  test "user can view tasks within a project" do
    # Create some tasks
    @project.tasks.create!(
      title: "First Task",
      description: "Description of first task",
      priority_number: 4,
      status: :todo
    )

    @project.tasks.create!(
      title: "Second Task",
      description: "Description of second task",
      priority_number: 2,
      status: :in_progress
    )

    visit project_path(@project)

    # Should see both tasks (titles only, descriptions not shown in list view)
    assert_text "First Task"
    assert_text "Second Task"

    # Click on a task to view details
    click_on "First Task"

    # Should be on the task show page
    assert_text "First Task"
    assert_text "Description of first task"
  end

  test "user can edit a task" do
    task = @project.tasks.create!(
      title: "Editable Task",
      description: "Original description",
      priority_number: 2,
      status: :todo
    )

    visit project_task_path(@project, task)

    # Click edit button
    click_on "Edit"

    # Should be on edit page
    assert_current_path edit_project_task_path(@project, task)

    # Modify the task
    fill_in "Title", with: "Updated Task Title"
    fill_in "Description", with: "Updated description"
    select "5", from: "Priority (1-5)"
    fill_in "Effort estimate", with: "1 day"

    click_on "Update Task"

    # Should be redirected back to show page with updates
    assert_text "Updated Task Title"
    assert_text "Updated description"
    assert_text "Task was successfully updated"
  end

  test "user can view all tasks across projects" do
    # Create another project with tasks
    project2 = @user.projects.create!(name: "Second Project", status: :active, priority_number: 2)

    @project.tasks.create!(title: "Task in Project 1", status: :todo, priority_number: 3)
    project2.tasks.create!(title: "Task in Project 2", status: :in_progress, priority_number: 4)

    visit tasks_path

    # Should see tasks from both projects (titles only)
    assert_text "Task in Project 1"
    assert_text "Task in Project 2"
    # Note: Project names are not displayed in the task list view
  end

  test "user sees validation errors for invalid task" do
    visit new_project_task_path(@project)

    # Try to submit without required fields
    click_on "Create Task"

    # Should see validation errors
    assert_text "can't be blank"

    # Should still be on the new task page
    assert_current_path new_project_task_path(@project) # After failed create
  end

  test "user can create a subtask" do
    # Create a parent task first
    parent_task = @project.tasks.create!(
      title: "Parent Task",
      description: "This will have subtasks",
      priority_number: 3,
      status: :todo
    )

    visit new_project_task_path(@project)

    # Fill in subtask details
    fill_in "Title", with: "Subtask"
    fill_in "Description", with: "This is a subtask"
    select parent_task.title, from: "Parent Task"

    click_on "Create Task"

    # Visit the parent task to see the subtask
    visit project_task_path(@project, parent_task)

    # Should see the subtask listed (title only, description not shown in subtask list)
    assert_text "Subtask"
  end
end
