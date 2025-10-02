require "application_system_test_case"

class ProjectManagementTest < ApplicationSystemTestCase
  test "user can create a new project and view it" do
    # Start at the home page
    visit root_path

    # Should see the projects index
    assert_text "Projects"

    # Click to create a new project
    click_on "New Project"

    # Fill in the project form
    fill_in "Name", with: "System Test Project"
    fill_in "Description", with: "This is a project created during system testing"
    select "Active", from: "Status"
    select "4", from: "Priority (1-5)"
    check "Urgent"
    check "Important"
    fill_in "Next action", with: "Start working on the first task"

    # Submit the form
    click_on "Create Project"

    # Should be redirected to the project show page
    assert_text "System Test Project"
    assert_text "This is a project created during system testing"
    assert_text "Active"
    assert_text "Start working on the first task"

    # Should see no tasks initially
    assert_text "No tasks yet"
    assert_text "Create your first task to get started"
  end

  test "user can navigate between projects and see project list" do
    # Create some test projects
    project1 = Project.create!(
      name: "First Project",
      description: "First test project",
      status: :active,
      priority_number: 3
    )

    project2 = Project.create!(
      name: "Second Project",
      description: "Second test project",
      status: :planned,
      priority_number: 5
    )

    # Visit the home page
    visit root_path

    # Should see both projects
    assert_text "First Project"
    assert_text "Second Project"
    assert_text "First test project"
    assert_text "Second test project"

    # Click on the first project
    click_on "First Project"

    # Should be on the project show page
    assert_text "First Project"
    assert_current_path project_path(project1)

    # Navigate back to all projects
    click_on "All Projects"

    # Should be back on the projects index
    assert_current_path projects_path
    assert_text "Projects"
  end

  test "user can edit a project" do
    project = Project.create!(
      name: "Editable Project",
      description: "Original description",
      status: :planned,
      priority_number: 2
    )

    visit project_path(project)

    # Click edit button
    click_on "Edit Project"

    # Should be on edit page
    assert_current_path edit_project_path(project)

    # Modify the project
    fill_in "Name", with: "Updated Project Name"
    fill_in "Description", with: "Updated description"
    select "Active", from: "Status"
    select "5", from: "Priority (1-5)"

    click_on "Update Project"

    # Should be redirected back to show page with updates
    assert_text "Updated Project Name"
    assert_text "Updated description"
    assert_text "Active"
    assert_text "Project was successfully updated"
  end

  test "user sees validation errors for invalid project" do
    visit new_project_path

    # Try to submit without required fields
    click_on "Create Project"

    # Should see validation errors
    assert_text "can't be blank"

    # Should still be on the new project page
    assert_current_path new_project_path # After failed create, it renders new
  end
end
