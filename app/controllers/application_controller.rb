class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  before_filter :get_conferences
  before_filter :store_location
  before_filter :verify_user_admin
  helper_method :date_string
  # Ensure every controller authorizes resource or skips authorization (skip_authorization_check)
  check_authorization unless: :devise_controller?

  def store_location
    session[:return_to] = request.fullpath if request.get? && controller_name != "user_sessions" && controller_name != "sessions"
  end

  def after_sign_in_path_for(resource)
    if (can? :view, Conference) &&
      (!session[:return_to] ||
      session[:return_to] &&
      session[:return_to] == root_path)
      admin_conference_index_path
    else
      if session[:return_to] &&
          !session[:return_to].start_with?(user_registration_path)
        logger.debug "Returning to #{session[:return_to]}"
        session[:return_to]
      else
        logger.debug "Not returning to #{session[:return_to]} because it would loop"
        super
      end
    end
  end

  def get_conferences
    @conferences =Conference.all
  end

  def verify_user_admin
    if self.class.to_s.split('::').first == 'Admin' && verify_user
      unless (current_user.has_role? :organizer, :any) || (current_user.has_role? :cfp, :any) ||
          (current_user.has_role? :info_desk, :any) ||
          (current_user.has_role? :volunteers_coordinator, :any) || current_user.is_admin
        raise CanCan::AccessDenied.new('You are not authorized to access this area!')
      end
    end
  end

  def verify_user
    :authenticate_user!

    if (current_user.nil?)
      redirect_to new_user_session_path
      return false
    end

    true
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug("Access denied!")
    redirect_to root_path, alert: exception.message
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  ##
  # Returns a string build from the start and end date of the given conference.
  #
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
      startstr = start_date.strftime('%B %d - ')
      endstr = end_date.strftime('%d, %Y')
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
