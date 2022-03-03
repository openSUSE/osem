# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  protected

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path(resource)
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :name,
      :username
    )
  end

  def account_update_params
    user_attributes = [:email, :name, :password, :password_confirmation, :current_password, :email_public]
    user_attributes << :is_admin if current_user.is_admin?
    params.require(:user).permit(user_attributes)
  end

  def check_captcha
    unless Feature.inactive?(:recaptcha) || verify_recaptcha
      self.resource = resource_class.new sign_up_params
      resource.validate # Look for any other validation errors besides Recaptcha
      respond_with_navigational(resource) { render :new }
    end
  end
end
