require "test_helper"

class TaskDependencyTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", user: users(:one))
    @task1 = Task.create!(title: "Task 1", project: @project)
    @task2 = Task.create!(title: "Task 2", project: @project)
    @dependency = TaskDependency.new(predecessor_task: @task1, successor_task: @task2)
  end

  test "should be valid with valid attributes" do
    assert @dependency.valid?
  end

  test "should require predecessor_task" do
    @dependency.predecessor_task = nil
    assert_not @dependency.valid?
  end

  test "should require successor_task" do
    @dependency.successor_task = nil
    assert_not @dependency.valid?
  end

  test "should have default dependency_type of finish_to_start" do
    @dependency.save!
    assert_equal "finish_to_start", @dependency.dependency_type
  end

  test "should not allow self-dependency" do
    @dependency.successor_task = @task1
    assert_not @dependency.valid?
    assert_includes @dependency.errors[:base], "Task cannot depend on itself"
  end

  test "should not allow duplicate dependencies" do
    @dependency.save!
    duplicate = TaskDependency.new(predecessor_task: @task1, successor_task: @task2)

    # Should raise a constraint exception due to unique index
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save!
    end
  end

  test "should not allow dependencies between tasks in different projects" do
    other_project = Project.create!(name: "Other Project", user: users(:two))
    other_task = Task.create!(title: "Other Task", project: other_project)

    @dependency.successor_task = other_task
    assert_not @dependency.valid?
    assert_includes @dependency.errors[:base], "Dependencies must be between tasks in the same project"
  end

  test "should detect simple circular dependency" do
    @dependency.save! # task1 -> task2

    # Try to create task2 -> task1 (circular)
    reverse_dependency = TaskDependency.new(predecessor_task: @task2, successor_task: @task1)
    assert_not reverse_dependency.valid?
    assert_includes reverse_dependency.errors[:base], "This dependency would create a circular reference"
  end

  test "should detect complex circular dependency" do
    task3 = Task.create!(title: "Task 3", project: @project)

    # Create chain: task1 -> task2 -> task3
    @dependency.save!
    TaskDependency.create!(predecessor_task: @task2, successor_task: task3)

    # Try to create task3 -> task1 (creates circular dependency)
    circular_dependency = TaskDependency.new(predecessor_task: task3, successor_task: @task1)
    assert_not circular_dependency.valid?
    assert_includes circular_dependency.errors[:base], "This dependency would create a circular reference"
  end

  test "should allow valid dependency chains" do
    task3 = Task.create!(title: "Task 3", project: @project)
    task4 = Task.create!(title: "Task 4", project: @project)

    # Create valid chain: task1 -> task2 -> task3 -> task4
    @dependency.save!
    dep2 = TaskDependency.create!(predecessor_task: @task2, successor_task: task3)
    dep3 = TaskDependency.create!(predecessor_task: task3, successor_task: task4)

    assert @dependency.valid?
    assert dep2.valid?
    assert dep3.valid?
  end

  test "should update successor task status when created" do
    # Initially task2 should not be blocked
    assert_not @task2.blocked?

    # Create dependency - should make task2 blocked
    @dependency.save!
    @task2.reload
    assert @task2.blocked?
  end

  test "should update successor task status when destroyed" do
    @dependency.save!
    @task2.reload
    assert @task2.blocked?

    # Remove dependency - should unblock task2
    @dependency.destroy
    @task2.reload
    @task2.check_if_blocked # Manual trigger since we're testing the callback
    assert_not @task2.blocked?
  end

  test "should handle multiple predecessors correctly" do
    task3 = Task.create!(title: "Task 3", project: @project)

    # Create two dependencies to task3
    dep1 = TaskDependency.create!(predecessor_task: @task1, successor_task: task3)
    dep2 = TaskDependency.create!(predecessor_task: @task2, successor_task: task3)

    task3.reload
    assert task3.blocked? # Should be blocked

    # Complete one predecessor
    @task1.update!(status: :done)
    task3.reload
    task3.check_if_blocked
    assert task3.blocked? # Should still be blocked because task2 is not done

    # Complete other predecessor
    @task2.update!(status: :done)
    task3.reload
    task3.check_if_blocked
    assert_not task3.blocked? # Should now be unblocked
  end

  test "circular dependency detection should handle deep chains" do
    # Create a longer chain
    tasks = (3..6).map { |i| Task.create!(title: "Task #{i}", project: @project) }

    # Create chain: task1 -> task2 -> task3 -> task4 -> task5 -> task6
    @dependency.save! # task1 -> task2
    TaskDependency.create!(predecessor_task: @task2, successor_task: tasks[0]) # task2 -> task3
    TaskDependency.create!(predecessor_task: tasks[0], successor_task: tasks[1]) # task3 -> task4
    TaskDependency.create!(predecessor_task: tasks[1], successor_task: tasks[2]) # task4 -> task5
    TaskDependency.create!(predecessor_task: tasks[2], successor_task: tasks[3]) # task5 -> task6

    # Try to create task6 -> task1 (creates a long circular dependency)
    circular_dependency = TaskDependency.new(predecessor_task: tasks[3], successor_task: @task1)
    assert_not circular_dependency.valid?
    assert_includes circular_dependency.errors[:base], "This dependency would create a circular reference"
  end

  test "should allow same task to be predecessor for multiple tasks" do
    task3 = Task.create!(title: "Task 3", project: @project)

    dep1 = TaskDependency.create!(predecessor_task: @task1, successor_task: @task2)
    dep2 = TaskDependency.create!(predecessor_task: @task1, successor_task: task3)

    assert dep1.valid?
    assert dep2.valid?
  end

  test "should allow same task to have multiple predecessors" do
    task3 = Task.create!(title: "Task 3", project: @project)

    dep1 = TaskDependency.create!(predecessor_task: @task1, successor_task: task3)
    dep2 = TaskDependency.create!(predecessor_task: @task2, successor_task: task3)

    assert dep1.valid?
    assert dep2.valid?
  end
end
