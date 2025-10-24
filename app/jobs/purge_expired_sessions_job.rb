class PurgeExpiredSessionsJob < ApplicationJob
  queue_as :default

  def perform
    Session.where("expires_at <= ?", Time.current).delete_all
  end
end
