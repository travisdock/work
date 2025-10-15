class RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      reset_session # Prevent session fixation
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
