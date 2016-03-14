module Admin
  module ConferenceHelper
    def withdrawn_events?(conference)
      conference.program.events.where(state: :withdrawn).empty?
    end

    def withdrawn_events_count(conference)
      conference.program.events.where(state: :withdrawn).count
    end
  end
end
