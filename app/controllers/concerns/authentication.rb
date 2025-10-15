module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    helper_method :current_user, :user_signed_in?
  end

  private

  def current_user
    @current_user ||= session[:user_id] && User.find_by(id: session[:user_id])
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to sign_in_path, alert: "You must be signed in to continue" unless user_signed_in?
  end
end
