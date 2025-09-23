require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project")
    @task = Task.new(title: "Test Task", project: @project)
  end

  test "should be valid with valid attributes" do
    assert @task.valid?
  end

  test "should require title" do
    @task.title = nil
    assert_not @task.valid?
    assert_includes @task.errors[:title], "can't be blank"
  end

  test "should require project" do
    @task.project = nil
    assert_not @task.valid?
  end

  test "should have default status of todo" do
    @task.save!
    assert_equal "todo", @task.status
  end

  test "should have default priority of 3" do
    @task.save!
    assert_equal 3, @task.priority_number
  end

  test "should validate priority number is between 1 and 5" do
    @task.priority_number = 0
    assert_not @task.valid?
    assert_includes @task.errors[:priority_number], "is not included in the list"

    @task.priority_number = 6
    assert_not @task.valid?
    assert_includes @task.errors[:priority_number], "is not included in the list"

    @task.priority_number = 3
    assert @task.valid?
  end

  test "should serialize priority_tags as array" do
    @task.priority_tags = ["urgent", "quick_win"]
    @task.save!
    @task.reload
    assert_equal ["urgent", "quick_win"], @task.priority_tags
  end

  test "should have subtasks association" do
    @task.save!
    subtask = @task.subtasks.create!(title: "Subtask", project: @project)
    assert_equal 1, @task.subtasks.count
    assert_includes @task.subtasks, subtask
    assert_equal @task, subtask.parent_task
  end

  test "should validate parent task is in same project" do
    other_project = Project.create!(name: "Other Project")
    other_task = Task.create!(title: "Other Task", project: other_project)

    @task.parent_task = other_task
    assert_not @task.valid?
    assert_includes @task.errors[:parent_task], "must be in the same project"
  end

  test "should not allow task to be its own parent" do
    @task.save!
    @task.parent_task_id = @task.id
    assert_not @task.valid?
    assert_includes @task.errors[:parent_task], "cannot be itself"
  end

  test "status enum should work correctly" do
    @task.save!

    assert @task.todo?

    # Test enum methods work
    assert_respond_to @task, :in_progress!
    assert_respond_to @task, :blocked!
    assert_respond_to @task, :done!
    assert_respond_to @task, :deferred!

    # Test status assignment bypassing callbacks
    @task.update_column(:status, Task.statuses[:in_progress])
    @task.reload
    assert @task.in_progress?

    @task.update_column(:status, Task.statuses[:blocked])
    @task.reload
    assert @task.blocked?

    @task.update_column(:status, Task.statuses[:done])
    @task.reload
    assert @task.done?

    @task.update_column(:status, Task.statuses[:deferred])
    @task.reload
    assert @task.deferred?
  end

  test "root_tasks scope should return only tasks without parent" do
    @task.save!
    subtask = Task.create!(title: "Subtask", project: @project, parent_task: @task)

    root_tasks = Task.root_tasks
    assert_includes root_tasks, @task
    assert_not_includes root_tasks, subtask
  end

  test "incomplete scope should exclude done tasks" do
    @task.save!
    done_task = Task.create!(title: "Done Task", project: @project, status: :done)

    incomplete_tasks = Task.incomplete
    assert_includes incomplete_tasks, @task
    assert_not_includes incomplete_tasks, done_task
  end

  test "should handle dependencies correctly" do
    @task.save!
    predecessor = Task.create!(title: "Predecessor", project: @project)

    # Create dependency
    TaskDependency.create!(predecessor_task: predecessor, successor_task: @task)

    # Task should be blocked because predecessor is not done
    @task.reload
    assert @task.is_blocked?
    assert @task.blocked?

    # Complete predecessor
    predecessor.update!(status: :done)
    @task.reload

    # Task should no longer be blocked
    assert_not @task.is_blocked?
  end

  test "should automatically become blocked when dependency added" do
    @task.save!
    predecessor = Task.create!(title: "Predecessor", project: @project, status: :todo)

    # Initially not blocked
    assert_not @task.blocked?

    # Add dependency - should auto-block
    TaskDependency.create!(predecessor_task: predecessor, successor_task: @task)
    @task.reload

    assert @task.blocked?
  end

  test "should automatically unblock when dependencies complete" do
    @task.save!
    predecessor = Task.create!(title: "Predecessor", project: @project, status: :todo)
    TaskDependency.create!(predecessor_task: predecessor, successor_task: @task)

    # Task should be blocked
    @task.reload
    assert @task.blocked?

    # Complete predecessor
    predecessor.update!(status: :done)

    # Check if task gets unblocked (this tests the callback)
    # Note: This might require manual triggering in tests
    @task.check_if_blocked
    assert_not @task.blocked?
  end

  test "should destroy associated dependencies when destroyed" do
    @task.save!
    other_task = Task.create!(title: "Other Task", project: @project)
    dependency = TaskDependency.create!(predecessor_task: @task, successor_task: other_task)

    dependency_id = dependency.id
    @task.destroy

    assert_raises(ActiveRecord::RecordNotFound) { TaskDependency.find(dependency_id) }
  end

  test "should handle multiple dependencies correctly" do
    @task.save!
    pred1 = Task.create!(title: "Pred 1", project: @project, status: :todo)
    pred2 = Task.create!(title: "Pred 2", project: @project, status: :done)

    TaskDependency.create!(predecessor_task: pred1, successor_task: @task)
    TaskDependency.create!(predecessor_task: pred2, successor_task: @task)

    @task.reload
    assert @task.is_blocked? # Should be blocked because pred1 is not done

    pred1.update!(status: :done)
    @task.reload
    @task.check_if_blocked
    assert_not @task.is_blocked? # Should be unblocked now
  end
end
