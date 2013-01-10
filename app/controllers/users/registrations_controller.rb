class Users::RegistrationsController < Devise::RegistrationsController
  
  skip_before_filter :require_admin_in_system, :authenticate_user!
  before_filter :require_no_admin

  def create
    params[:user][:is_admin] = true
    super
  end

  private

  def require_no_admin
    redirect_to new_user_session_url unless User.no_admin_yet?
  end
  
end