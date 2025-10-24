require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "initializes activity and expiration timestamps on creation" do
    travel_to Time.zone.local(2025, 1, 1, 9, 0, 0) do
      session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")

      assert_in_delta Time.current, session.last_activity_at, 1.second
      assert_in_delta Time.current + Session::INACTIVITY_TIMEOUT, session.expires_at, 1.second
    end
  end

  test "touch_activity! extends expiration but never beyond absolute deadline" do
    session_id = nil
    created_at = nil

    travel_to Time.zone.local(2025, 1, 1, 9, 0, 0) do
      session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
      session_id = session.id
      created_at = session.created_at
    end

    travel_to Time.zone.local(2025, 1, 25, 9, 0, 0) do
      session = Session.find(session_id)
      session.touch_activity!
      session.reload

      assert_in_delta Time.current + Session::INACTIVITY_TIMEOUT, session.expires_at, 1.second
    end

    travel_to Time.zone.local(2025, 2, 20, 9, 0, 0) do
      session = Session.find(session_id)
      session.touch_activity!
      session.reload

      assert_in_delta Time.current + Session::INACTIVITY_TIMEOUT, session.expires_at, 1.second
    end

    travel_to Time.zone.local(2025, 3, 20, 9, 0, 0) do
      session = Session.find(session_id)
      session.touch_activity!
      session.reload

      expected_deadline = created_at + Session::ABSOLUTE_TIMEOUT
      assert_in_delta expected_deadline, session.expires_at, 1.second
    end
  end

  test "touch_activity_if_stale! only updates when threshold exceeded" do
    session_id = nil
    initial_last_activity = nil

    travel_to Time.zone.local(2025, 1, 1, 9, 0, 0) do
      session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
      session_id = session.id
      initial_last_activity = session.last_activity_at
    end

    travel_to Time.zone.local(2025, 1, 1, 9, 30, 0) do
      session = Session.find(session_id)
      session.touch_activity_if_stale!

      assert_equal initial_last_activity, session.reload.last_activity_at
    end

    travel_to Time.zone.local(2025, 1, 1, 12, 30, 0) do
      session = Session.find(session_id)
      session.touch_activity_if_stale!

      assert_in_delta Time.current, session.reload.last_activity_at, 1.second
    end
  end

  test "expired? reflects expiration timestamp" do
    travel_to Time.zone.local(2025, 1, 1, 9, 0, 0) do
      session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "Test")
      session.update_columns(expires_at: 1.minute.ago)

      assert_predicate session, :expired?
    end
  end
end
