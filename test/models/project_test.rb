require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = Project.new(name: "Test Project", description: "Testing project model")
  end

  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "can't be blank"
  end

  test "should have default status of planned" do
    @project.save!
    assert_equal "planned", @project.status
  end

  test "should have default priority of 3" do
    @project.save!
    assert_equal 3, @project.priority_number
  end

  test "should validate priority number is between 1 and 5" do
    @project.priority_number = 0
    assert_not @project.valid?
    assert_includes @project.errors[:priority_number], "is not included in the list"

    @project.priority_number = 6
    assert_not @project.valid?
    assert_includes @project.errors[:priority_number], "is not included in the list"

    @project.priority_number = 3
    assert @project.valid?
  end

  test "should serialize priority_tags as array" do
    @project.priority_tags = [ "urgent", "important" ]
    @project.save!
    @project.reload
    assert_equal [ "urgent", "important" ], @project.priority_tags
  end

  test "should initialize empty priority_tags array" do
    @project.save!
    assert_equal [], @project.priority_tags
  end

  test "should have many tasks" do
    @project.save!
    task1 = @project.tasks.create!(title: "Task 1")
    task2 = @project.tasks.create!(title: "Task 2")
    assert_equal 2, @project.tasks.count
    assert_includes @project.tasks, task1
    assert_includes @project.tasks, task2
  end

  test "should destroy associated tasks when destroyed" do
    @project.save!
    task = @project.tasks.create!(title: "Task 1")
    task_id = task.id

    @project.destroy
    assert_raises(ActiveRecord::RecordNotFound) { Task.find(task_id) }
  end

  test "status enum should work correctly" do
    @project.save!

    assert @project.planned?
    @project.active!
    assert @project.active?
    @project.on_hold!
    assert @project.on_hold?

    # completed! and cancelled! should automatically set completed_at via callback
    @project.completed!
    assert @project.completed?
    assert_not_nil @project.completed_at

    @project.cancelled!
    assert @project.cancelled?
    assert_not_nil @project.completed_at

    # Going back to active should clear completed_at
    @project.active!
    assert @project.active?
    assert_nil @project.completed_at
  end

  test "active scope should return only active projects" do
    active_project = Project.create!(name: "Active", status: :active)
    planned_project = Project.create!(name: "Planned", status: :planned)

    active_projects = Project.active
    assert_includes active_projects, active_project
    assert_not_includes active_projects, planned_project
  end

  test "by_priority scope should order by priority descending" do
    # Use separate test projects to avoid fixture interference
    low_priority = Project.create!(name: "Test Low Priority", priority_number: 1)
    high_priority = Project.create!(name: "Test High Priority", priority_number: 5)
    medium_priority = Project.create!(name: "Test Medium Priority", priority_number: 3)

    # Only check our test projects
    test_projects = Project.where(name: [ "Test Low Priority", "Test High Priority", "Test Medium Priority" ])
    ordered = test_projects.by_priority.to_a
    assert_equal [ high_priority, medium_priority, low_priority ], ordered
  end
end
