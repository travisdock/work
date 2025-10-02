class Task < ApplicationRecord
  # Enums
  enum :status, {
    todo: 0,
    in_progress: 1,
    blocked: 2,
    done: 3,
    deferred: 4
  }, default: :todo

  # Associations
  belongs_to :project
  belongs_to :parent_task, class_name: "Task", optional: true
  has_many :subtasks, class_name: "Task", foreign_key: "parent_task_id", dependent: :destroy

  has_many :predecessor_dependencies, class_name: "TaskDependency", foreign_key: "successor_task_id", dependent: :destroy
  has_many :successor_dependencies, class_name: "TaskDependency", foreign_key: "predecessor_task_id", dependent: :destroy
  has_many :predecessors, through: :predecessor_dependencies, source: :predecessor_task
  has_many :successors, through: :successor_dependencies, source: :successor_task

  # Validations
  validates :title, presence: true
  validates :priority_number, inclusion: { in: 1..5 }, allow_nil: false
  validate :parent_task_must_be_in_same_project
  validate :cannot_be_own_parent

  # Serialization
  serialize :priority_tags, coder: JSON, type: Array

  # Scopes
  scope :root_tasks, -> { where(parent_task_id: nil) }
  scope :incomplete, -> { where.not(status: :done) }
  scope :by_position, -> { order(:position) }

  # Callbacks
  before_validation :set_defaults
  after_save :check_if_blocked

  # Instance methods
  def is_blocked?
    predecessors.incomplete.any?
  end

  def check_if_blocked
    if is_blocked? && !blocked?
      update_column(:status, Task.statuses[:blocked])
    elsif blocked? && !is_blocked? && status_previously_was != :blocked
      update_column(:status, Task.statuses[:todo])
    end
  end

  private

  def set_defaults
    self.priority_number ||= 3
    self.priority_tags ||= []
  end

  def parent_task_must_be_in_same_project
    if parent_task && parent_task.project_id != project_id
      errors.add(:parent_task, "must be in the same project")
    end
  end

  def cannot_be_own_parent
    if parent_task_id && parent_task_id == id
      errors.add(:parent_task, "cannot be itself")
    end
  end
end
