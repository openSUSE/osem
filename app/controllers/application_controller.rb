class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  before_filter :get_conferences
  before_filter :store_location
  helper_method :date_string

  def store_location
    session[:return_to] = request.fullpath if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
  end

  def after_sign_in_path_for(resource)
    if organizer_or_admin? &&
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

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug("Access denied!")
    redirect_to root_path, :alert => exception.message
  end
  helper_method :organizer_or_admin?

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
