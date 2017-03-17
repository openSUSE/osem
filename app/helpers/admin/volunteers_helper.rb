module Admin
  module VolunteersHelper
    def can_manage_volunteers?(conference)
      if (current_user.has_role? :organizer, conference) || (current_user.has_role? :volunteers_coordinator, conference)
        true
      else
        false
      end
    end
  end
end
