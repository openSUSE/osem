# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  include ApplicationHelper
  add_flash_types :error
  protect_from_forgery with: :exception, prepend: true
  before_action :store_location
  # Ensure every controller authorizes resource or skips authorization (skip_authorization_check)
  check_authorization unless: :devise_controller?
  skip_authorization_check if:

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?

    if (request.path != '/accounts/sign_in' &&
        request.path != '/accounts/sign_up' &&
        request.path != '/accounts/password/new' &&
        request.path != '/accounts/password/edit' &&
        request.path != '/accounts/confirmation' &&
        request.path != '/accounts/sign_out' &&
        request.path != '/users/ichain_registration/ichain_sign_up' &&
        !request.path.starts_with?(Devise.ichain_base_url) &&
        !request.xhr?) # don't store ajax calls
      session[:return_to] = request.fullpath
    end
  end

  def after_sign_in_path_for(_resource)
    if (can? :view, Conference) &&
      (!session[:return_to] ||
      session[:return_to] &&
      session[:return_to] == root_path)
      admin_conferences_path
    else
      session[:return_to] || root_path
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    message = exception.message
    message << ' Maybe you need to sign in?' unless @ignore_not_signed_in_user || current_user
    redirect_to root_path, alert: message
  end

  rescue_from IChainRecordNotFound do
    Rails.logger.debug('IChain Record was not Unique!')
    sign_out(current_user)
    redirect_to root_path,
                error: 'Your E-Mail address is already registered at OSEM. Please contact the admin if you want to attach your openSUSE Account to OSEM!'
  end

  rescue_from UserDisabled do
    Rails.logger.debug('User is disabled!')
    sign_out(current_user)
    mail = User.admin.first ? User.admin.first.email : 'the admin!'
    redirect_to User.ichain_logout_url, error:  "This User is disabled. Please contact #{mail}!"
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  skip_authorization_check only: :apple_pay
  def apple_pay
    render plain: ENV['OSEM_APPLE_PAY_ID']
  end
end
