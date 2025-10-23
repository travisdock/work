class PurgeExpiredSessionsJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current
    inactivity_cutoff = Session::INACTIVITY_TIMEOUT.ago

    Session.where("expires_at <= ?", now).delete_all
    Session.where("last_activity_at <= ?", inactivity_cutoff).delete_all
  end
end
