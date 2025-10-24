require "test_helper"

class PurgeExpiredSessionsJobTest < ActiveJob::TestCase
  test "deletes expired and inactive sessions" do
    active_session = users(:one).sessions.create!(ip_address: "127.0.0.1", user_agent: "Active")
    expired_session = users(:one).sessions.create!(ip_address: "127.0.0.1", user_agent: "Expired")

    expired_session.update_columns(
      expires_at: 1.day.ago,
      last_activity_at: Session::INACTIVITY_TIMEOUT.ago - 1.day
    )

    assert_difference -> { Session.count }, -1 do
      PurgeExpiredSessionsJob.perform_now
    end

    assert_not Session.exists?(expired_session.id)
    assert Session.exists?(active_session.id)
  end
end
