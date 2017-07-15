module Admin
  class ReportsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true

    def index
      @events = @program.events
      @events_commercials = Commercial.where(commercialable_type: 'Event', commercialable_id: @events.pluck(:id))
      @events_missing_commercial = @events.where.not(id: @events_commercials.pluck(:commercialable_id))
      @events_with_requirements = @events.where.not(description: ['', nil])

      attended_registrants_ids = @conference.registrations.where(attended: true).pluck(:user_id)
      @missing_event_speakers = EventUser.joins(:event)
                                .where('event_role = ? and program_id = ?', 'submitter', @program.id)
                                .where.not(user_id: attended_registrants_ids)
                                .includes(:user, :event)
    end
  end
end
