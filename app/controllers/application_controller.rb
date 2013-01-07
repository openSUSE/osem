class ApplicationController < ActionController::Base
  include ApplicationHelper

  protect_from_forgery

  def verify_user
    :authenticate_user!

    if (current_user.nil?)
      redirect_to '/accounts/sign_in'
      return
    end

    @conference = Conference.find_all_by_short_title(params[:conference_id]).first
  end

  def organizer_or_admin?
    has_role?(current_user, 'admin') || has_role?(current_user, 'organizer')
  end

  def verify_organizer
    verify_user

    ## Todo simplify this
    redirect_to '/' unless has_role?(current_user, 'admin') || has_role?(current_user, 'organizer')
  end

  def verify_admin
    verify_user

    redirect_to '/' unless has_role?(current_user, 'admin')
  end

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug("Access denied!")
    redirect_to '/', :alert => exception.message
  end
end
