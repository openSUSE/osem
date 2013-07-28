class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  before_filter :get_conferences

  def get_conferences
    @conferences =Conference.all
  end

  def verify_user
    :authenticate_user!

    if (current_user.nil?)
      redirect_to new_user_session_path
      return false
    end

    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
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
