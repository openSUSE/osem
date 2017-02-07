class ApplicationController < ActionController::Base
  before_filter :set_paper_trail_whodunnit
  include ApplicationHelper
  add_flash_types :error
  protect_from_forgery with: :exception
  before_filter :get_conferences
  before_filter :store_location
  helper_method :date_string
  # Ensure every controller authorizes resource or skips authorization (skip_authorization_check)
  check_authorization unless: :devise_controller?

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

  def get_conferences
    @conferences = Conference.all
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    message = exception.message
    message << ' Maybe you need to sign in?' unless current_user
    redirect_to root_path, alert: message
  end

  rescue_from IChainRecordNotFound do
    Rails.logger.debug('IChain Record was not Unique!')
    sign_out(current_user)
    redirect_to root_path,
                error: 'Your E-Mail adress is already registered at OSEM. Please contact the admin if you want to attach your openSUSE Account to OSEM!'
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

  ##
  # Returns a string build from the start and end date of the given conference.
  #
  # If the conference is only one day long
  # * %B %d %Y (January 17 2014)
  # If the conference starts and ends in the same month and year
  # * %B %d - %d, %Y (January 17 - 21 2014)
  # If the conference ends in another month but in the same year
  # * %B %d - %B %d, %Y (January 31 - February 02 2014)
  # All other cases
  # * %B %d, %Y - %B %d, %Y (December 30, 2013 - January 02, 2014)
  def date_string(start_date, end_date)
    startstr = 'Unknown - '
    endstr = 'Unknown'
    # When the conference  in the same month
    if start_date.month == end_date.month && start_date.year == end_date.year
      if start_date.day == end_date.day
        startstr = start_date.strftime('%B %d')
        endstr = end_date.strftime(' %Y')
      else
        startstr = start_date.strftime('%B %d - ')
        endstr = end_date.strftime('%d, %Y')
      end
    elsif start_date.month != end_date.month && start_date.year == end_date.year
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%B %d, %Y')
    else
      startstr = start_date.strftime('%B %d, %Y - ')
      endstr = end_date.strftime('%B %d, %Y')
    end

    result = startstr + endstr
    result
  end
end
