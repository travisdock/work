class TaskDependency < ApplicationRecord
  # Associations
  belongs_to :predecessor_task, class_name: "Task"
  belongs_to :successor_task, class_name: "Task"

  # Validations
  validate :no_self_dependency
  validate :no_circular_dependency
  validate :tasks_in_same_project

  # Callbacks
  after_create :update_successor_status
  after_destroy :update_successor_status

  private

  def no_self_dependency
    if predecessor_task_id == successor_task_id
      errors.add(:base, "Task cannot depend on itself")
    end
  end

  def no_circular_dependency
    return unless predecessor_task && successor_task

    if creates_circular_dependency?
      errors.add(:base, "This dependency would create a circular reference")
    end
  end

  def creates_circular_dependency?
    visited = Set.new
    queue = [predecessor_task_id]

    while queue.any?
      current = queue.shift
      return true if current == successor_task_id

      next if visited.include?(current)
      visited.add(current)

      TaskDependency.where(successor_task_id: current).pluck(:predecessor_task_id).each do |pred_id|
        queue << pred_id
      end
    end

    false
  end

  def tasks_in_same_project
    if predecessor_task && successor_task && predecessor_task.project_id != successor_task.project_id
      errors.add(:base, "Dependencies must be between tasks in the same project")
    end
  end

  def update_successor_status
    successor_task.check_if_blocked if successor_task
  end
end
