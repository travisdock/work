class Session < ApplicationRecord
  belongs_to :user

  INACTIVITY_TIMEOUT = 30.days
  ABSOLUTE_TIMEOUT = 90.days
  ACTIVITY_TOUCH_THRESHOLD = 1.hour

  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  before_validation :initialize_expiration_fields, on: :create

  validates :expires_at, :last_activity_at, presence: true

  def expired?
    expires_at <= Time.current
  end

  def touch_activity!
    return if expired?

    now = Time.current
    update_columns(
      last_activity_at: now,
      expires_at: [absolute_deadline, inactivity_deadline(now)].min,
      updated_at: now
    )
  end

  def touch_activity_if_stale!(threshold: ACTIVITY_TOUCH_THRESHOLD)
    return if expired?
    return unless last_activity_at.nil? || last_activity_at <= threshold.ago

    touch_activity!
  end

  def absolute_deadline
    (created_at || Time.current) + ABSOLUTE_TIMEOUT
  end

  private

  def initialize_expiration_fields
    now = Time.current
    self.last_activity_at ||= now
    self.expires_at ||= [absolute_deadline_for(now), inactivity_deadline(now)].min
  end

  def absolute_deadline_for(reference_time)
    (created_at || reference_time) + ABSOLUTE_TIMEOUT
  end

  def inactivity_deadline(reference_time)
    reference_time + INACTIVITY_TIMEOUT
  end
end
