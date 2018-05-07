# frozen_string_literal: true

module Admin
  module VolunteersHelper
    def can_manage_volunteers?(conference)
      current_user.has_cached_role?(:organizer, conference) || current_user.has_cached_role?(:volunteers_coordinator, conference)
    end
  end
end
