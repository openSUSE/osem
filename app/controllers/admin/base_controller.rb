module Admin
  class BaseController < ApplicationController
    before_filter :verify_user_admin

    def verify_user_admin
      if (current_user.nil?)
        redirect_to sign_in_path
        return false
      end
      unless (current_user.has_role? :organizer, :any) || (current_user.has_role? :cfp, :any) ||
             (current_user.has_role? :info_desk, :any) ||
             (current_user.has_role? :volunteers_coordinator, :any) || current_user.is_admin
        raise CanCan::AccessDenied.new('You are not authorized to access this area!')
      end
    end
  end
end
