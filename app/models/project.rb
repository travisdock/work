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
  belongs_to :user
  has_many :tasks, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :priority_number, inclusion: { in: 1..5 }, allow_nil: false
  validates :completed_at, presence: true, if: -> { completed? || cancelled? }

  # Serialization
  serialize :priority_tags, coder: JSON, type: Array

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :not_completed, -> { where(status: [ :planned, :active, :on_hold, :cancelled ]) }
  scope :completed, -> { where(status: :completed) }
  scope :archived, -> { completed }
  scope :for_user, ->(user) { where(user_id: user&.id) }
  scope :by_priority, -> { order(priority_number: :desc) }
  scope :by_recent_update, -> { order(updated_at: :desc) }
  scope :by_completed_at, -> { order(completed_at: :desc) }

  # Callbacks
  before_validation :set_defaults
  before_validation :manage_completed_at, if: :status_changed?

  private

  def set_defaults
    self.priority_number ||= 3
    self.priority_tags ||= []
  end

  def manage_completed_at
    if (completed? || cancelled?) && completed_at.nil?
      self.completed_at = Time.current
    elsif !completed? && !cancelled?
      self.completed_at = nil
    end
  end
end
