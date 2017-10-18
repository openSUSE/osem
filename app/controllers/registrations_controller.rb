class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def edit
    @openids = Openid.where(user_id: current_user.id).order(:provider)
    super
  end

  def update
    @openids = Openid.where(user_id: current_user.id).order(:provider)
    super
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path(resource)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |u|
      u
          .permit(:email, :password, :password_confirmation, :current_password, :username, :email_public)
    end
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u
          .permit(:email, :password, :password_confirmation, :name, :username)
    end
  end
end
