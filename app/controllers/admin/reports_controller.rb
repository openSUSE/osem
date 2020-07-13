# frozen_string_literal: true

module Admin
  class ReportsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    # For some reason this doesn't work, so a workaround is used
    # load_and_authorize_resource :event, through: :program

    def index
      @events = Event.accessible_by(current_ability).where(program: @program,
                                                           state: [:confirmed, :unconfirmed])
      @events_commercials = Commercial.where(commercialable_type: 'Event', commercialable_id: @events.pluck(:id))
      @events_missing_commercial = @events.where.not(id: @events_commercials.pluck(:commercialable_id))
      @events_with_requirements = @events.where.not(description: ['', nil])

      attended_registrants_ids = @conference.registrations.where(attended: true).pluck(:user_id)
      @missing_event_speakers = EventUser.joins(:event)
                                .where('event_role = ? and program_id = ?', 'speaker', @program.id)
                                .where.not(user_id: attended_registrants_ids)
                                .where(event_id: @events.pluck(:id))
                                .includes(:user, :event)
    end
  end
end
