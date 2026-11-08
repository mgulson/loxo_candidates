class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    @current_user ||= User.all.find { |user| user.name == session[:current_user_name] } || User.all.first
  end

  def require_current_user
    return if current_user

    redirect_to users_path, alert: "No users are available in db/users.csv."
  end
end
