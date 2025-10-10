class Project < ApplicationRecord
  # Enums
  enum :status, {
    planned: 0,
    active: 1,
    on_hold: 2,
    completed: 3,
    cancelled: 4
  }, default: :planned

  # Associations
  has_many :tasks, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :priority_number, inclusion: { in: 1..5 }, allow_nil: false

  # Serialization
  serialize :priority_tags, coder: JSON, type: Array

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :not_completed, -> { where.not(status: :completed) }
  scope :completed, -> { where(status: :completed) }
  scope :recently_archived, -> { completed.where("updated_at >= ?", 60.days.ago) }
  scope :by_priority, -> { order(priority_number: :desc) }
  scope :by_recent_update, -> { order(updated_at: :desc) }

  # Callbacks
  before_validation :set_defaults

  private

  def set_defaults
    self.priority_number ||= 3
    self.priority_tags ||= []
  end
end
