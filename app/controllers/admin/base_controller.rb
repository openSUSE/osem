# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :verify_user_admin
    before_action :load_all_conferences

    private

    def load_all_conferences
      @conferences = Conference.all
    end

    def current_ability
      @current_ability ||= AdminAbility.new(current_user)
    end

    def verify_user_admin
      if current_user.nil?
        redirect_to sign_in_path
        return false
      end
      unless (current_user.has_cached_role? :organizer, :any) || (current_user.has_cached_role? :cfp, :any) ||
             (current_user.has_cached_role? :info_desk, :any) || (current_user.has_cached_role? :volunteers_coordinator, :any) ||
             (current_user.has_cached_role? :track_organizer, :any) || current_user.is_admin
        raise CanCan::AccessDenied.new('You are not authorized to access this page.')
      end
    end

    def sign_in_path
      if ENV.fetch('OSEM_ICHAIN_ENABLED', nil) == 'true'
        User.ichain_login_url
      else
        new_user_session_path
      end
    end
  end
end
