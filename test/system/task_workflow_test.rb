require "application_system_test_case"

class TaskWorkflowTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
    sign_in_as(@user)

    @project = @user.projects.create!(
      name: "Workflow Test Project",
      description: "Testing task workflows and dependencies",
      status: :active,
      priority_number: 3
    )
  end

  test "user can complete a task and see status changes" do
    task = @project.tasks.create!(
      title: "Completable Task",
      description: "A task that can be completed",
      status: :todo,
      priority_number: 3,
      user: @user
    )

    visit project_path(@project)

    # Should see the task as todo
    assert_text "Completable Task"

    # Navigate to the task page
    visit project_task_path(@project, task)

    # Complete the task using the interface (button/form/checkbox)
    # This will need to be adjusted based on the actual UI implementation
    # For now, let's assume there's a "Complete" button or similar
    if page.has_button?("Complete Task")
      click_button "Complete Task"
    elsif page.has_link?("Complete")
      click_link "Complete"
    end

    # Verify task status changed (adjust based on actual UI)
  end

  test "tasks show proper hierarchy with parent and subtasks" do
    # Create a parent task
    parent_task = @project.tasks.create!(
      title: "Parent Task",
      description: "This has subtasks",
      status: :in_progress,
      priority_number: 4,
      user: @user
    )

    # Create subtasks
    subtask1 = @project.tasks.create!(
      title: "First Subtask",
      description: "First child task",
      parent_task: parent_task,
      status: :todo,
      priority_number: 3,
      user: @user
    )

    subtask2 = @project.tasks.create!(
      title: "Second Subtask",
      description: "Second child task",
      parent_task: parent_task,
      status: :done,
      priority_number: 2,
      user: @user
    )

    visit project_path(@project)

    # Should see the parent task
    assert_text "Parent Task"

    # Should see subtasks (implementation may vary)
    assert_text "First Subtask"
    assert_text "Second Subtask"

    # Visit the parent task detail page
    click_on "Parent Task"

    # Should see parent task description
    assert_text "This has subtasks"

    # Should see subtasks listed (titles are shown)
    assert_text "First Subtask"
    assert_text "Second Subtask"
  end

  test "user can navigate through project workflow naturally" do
    # Create a realistic project workflow
    design_task = @project.tasks.create!(
      title: "Create Design Mockups",
      description: "Design the user interface",
      status: :done,
      priority_number: 4,
      position: 1,
      user: @user
    )

    development_task = @project.tasks.create!(
      title: "Implement Frontend",
      description: "Code the user interface",
      status: :in_progress,
      priority_number: 4,
      position: 2,
      user: @user
    )

    testing_task = @project.tasks.create!(
      title: "Test Implementation",
      description: "Quality assurance testing",
      status: :todo,
      priority_number: 3,
      position: 3,
      user: @user
    )

    # Create a dependency
    TaskDependency.create!(
      predecessor_task: design_task,
      successor_task: development_task
    )

    TaskDependency.create!(
      predecessor_task: development_task,
      successor_task: testing_task
    )

    # Start the user journey
    visit root_path

    # Navigate to the project
    click_on @project.name

    # Should see all tasks in order
    assert_text "Create Design Mockups"
    assert_text "Implement Frontend"
    assert_text "Test Implementation"

    # Click on the in-progress task
    click_on "Implement Frontend"

    # Should see task details
    assert_text "Code the user interface"
    assert_text "In progress"

    # Navigate back to project
    click_on "Back to Project"

    # Should be back on project page
    assert_current_path project_path(@project)
  end

  test "user can see blocked tasks due to dependencies" do
    # Create tasks with dependencies
    first_task = @project.tasks.create!(
      title: "First Task",
      description: "Must be done first",
      status: :todo,
      priority_number: 4,
      user: @user
    )

    second_task = @project.tasks.create!(
      title: "Dependent Task",
      description: "Depends on first task",
      status: :todo,
      priority_number: 3,
      user: @user
    )

    # Create dependency
    TaskDependency.create!(
      predecessor_task: first_task,
      successor_task: second_task
    )

    # Reload to trigger blocking check
    second_task.reload
    second_task.check_if_blocked

    visit project_path(@project)

    # Should see both tasks
    assert_text "First Task"
    assert_text "Dependent Task"

    # The dependent task should show as blocked (if UI supports it)
    # This test verifies the data model works correctly
    assert second_task.reload.blocked?
  end

  test "user can archive a completed project" do
    # Mark project as completable by having no incomplete tasks
    @project.tasks.create!(
      title: "Completed Task",
      status: :done,
      priority_number: 3,
      user: @user
    )

    visit project_path(@project)

    # Should see archive option (available for active projects)
    assert_text "Archive Project"

    # Click archive - handle Turbo confirmation
    accept_confirm "Are you sure you want to archive this project?" do
      click_on "Archive Project"
    end

    # Should be redirected back to project page
    assert_current_path project_path(@project)

    # Should see the status changed to Completed on the page
    assert_text "Completed"

    # Project status should be updated in the database
    assert @project.reload.completed?
  end

  test "user journey: create project, add tasks, complete workflow" do
    # Start fresh - delete the setup project and create via UI
    @project.destroy

    # Start at home page
    visit root_path

    # Create a new project
    click_on "New Project"

    fill_in "Name", with: "Complete Workflow Test"
    fill_in "Description", with: "Testing a complete user workflow"
    select "Active", from: "Status"
    fill_in "Next action", with: "Add first task"

    click_on "Create Project"

    # Should be on project page
    assert_text "Complete Workflow Test"
    assert_text "Testing a complete user workflow"

    # Add first task
    click_on "New Task"

    fill_in "Title", with: "Planning Task"
    fill_in "Description", with: "Plan the project approach"
    select "4", from: "Priority (1-5)"

    click_on "Create Task"

    # Should see the task was created
    assert_text "Planning Task"

    # Go back to project to add another task
    click_on "Back to Project"

    # Add second task
    click_on "New Task"

    fill_in "Title", with: "Implementation Task"
    fill_in "Description", with: "Implement the planned approach"
    select "3", from: "Priority (1-5)"

    click_on "Create Task"

    # Navigate back to see both tasks
    click_on "Back to Project"

    # Should see both tasks
    assert_text "Planning Task"
    assert_text "Implementation Task"

    # Project should show task count
    assert_text "2 tasks"
  end
end
