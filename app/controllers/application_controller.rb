class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  before_filter :get_conferences
  before_filter :store_location
  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
  end

  def store_location
    session[:return_to] = request.fullpath if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
  end

  def after_sign_in_path_for(resource)
    if session[:return_to] &&
        !session[:return_to].start_with?(user_registration_path)
      logger.debug "Returning to #{session[:return_to]}"
      session[:return_to]
    else
      logger.debug "Not returning to #{session[:return_to]} because it would loop"
      super
    end
  end

  def get_conferences
    @conferences =Conference.all
  end

  def verify_user
    :authenticate_user!

    if (current_user.nil?)
      redirect_to new_user_session_path
      return false
    end

    @conference = Conference.find_by(short_title: params[:conference_id])
    true
  end

  def organizer_or_admin?
    has_role?(current_user, 'admin') || has_role?(current_user, 'organizer')
  end

  def verify_organizer
    if !verify_user
      return
    end

    ## Todo simplify this
    redirect_to root_path unless has_role?(current_user, 'admin') || has_role?(current_user, 'organizer')
  end

  def verify_admin
    if !verify_user
      return
    end

    redirect_to root_path unless has_role?(current_user, 'admin')
  end

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug("Access denied!")
    redirect_to root_path, :alert => exception.message
  end
  helper_method :organizer_or_admin?
end
