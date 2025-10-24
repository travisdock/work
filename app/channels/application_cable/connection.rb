module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        return unless (session = Session.includes(:user).find_by(id: cookies.signed[:session_id]))
        return if session.expired?

        session.touch_activity_if_stale!
        self.current_user = session.user
      end
  end
end
