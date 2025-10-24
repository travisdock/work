class Session < ApplicationRecord
  belongs_to :user

  INACTIVITY_TIMEOUT = 30.days
  ABSOLUTE_TIMEOUT = 90.days
  ACTIVITY_TOUCH_THRESHOLD = 1.hour

  scope :active, -> { where("expires_at > ?", Time.current) }

  before_validation :initialize_expiration_fields, on: :create

  validates :expires_at, presence: true

  def expired?
    expires_at <= Time.current
  end

  def touch_activity!
    return if expired?

    now = Time.current
    update_columns(
      last_activity_at: now,
      expires_at: [ absolute_deadline, inactivity_deadline(now) ].min,
      updated_at: now
    )
  end

  def touch_activity_if_stale!
    return if expired?
    return unless last_activity_at.nil? || last_activity_at <= ACTIVITY_TOUCH_THRESHOLD.ago

    touch_activity!
  end

  def absolute_deadline
    created_at + ABSOLUTE_TIMEOUT
  end

  private

  def initialize_expiration_fields
    now = Time.current
    absolute_cutoff = now + ABSOLUTE_TIMEOUT
    self.last_activity_at ||= now
    self.expires_at ||= [ absolute_cutoff, inactivity_deadline(now) ].min
  end

  def inactivity_deadline(reference_time)
    reference_time + INACTIVITY_TIMEOUT
  end
end
