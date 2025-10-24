require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  setup do
    @user = users(:one)
  end

  test "rejects connection with expired session" do
    session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "WebSocket")
    session.update_columns(expires_at: 1.day.ago)

    cookies.signed[:session_id] = session.id

    assert_reject_connection { connect }
  end

  test "tracks activity when session is valid" do
    session = @user.sessions.create!(ip_address: "127.0.0.1", user_agent: "WebSocket")
    initial_activity = session.last_activity_at

    travel 2.hours do
      cookies.signed[:session_id] = session.id
      connect
    end

    assert_equal @user, connection.current_user
    assert_operator session.reload.last_activity_at, :>, initial_activity
  end
end
