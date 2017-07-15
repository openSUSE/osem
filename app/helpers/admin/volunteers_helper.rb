module Admin
  module VolunteersHelper
    def can_manage_volunteers?(conference)
      current_user.has_role?(:organizer, conference) || current_user.has_role?(:volunteers_coordinator, conference)
    end
  end
end
