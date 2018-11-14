# frozen_string_literal: true

module Admin
  class SchedulesController < Admin::BaseController
    # By authorizing 'conference' resource, we can ensure there will be no unauthorized access to
    # the schedule of a conference, which should not be accessed in the first place
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :program, through: :conference, singleton: true
    load_and_authorize_resource :schedule, through: :program, except: [:new, :create]
    load_resource :event_schedules, through: :schedule
    load_resource :selected_schedule, through: :program, singleton: true
    load_resource :venue, through: :conference, singleton: true

    def index; end

    def new
      @schedule = @program.schedules.build(track: @program.tracks.new)
      authorize! :new, @schedule
    end

    def create
      @schedule = @program.schedules.new(schedule_params)
      authorize! :create, @schedule
      if @schedule.save
        redirect_to admin_conference_schedule_path(@conference.short_title, @schedule.id),
                    notice: 'Schedule was successfully created.'
      else
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    error: "Could not create schedule. #{@schedule.errors.full_messages.join('. ')}."
      end
    end

    def show
      @event_schedules = @schedule.event_schedules.eager_load(
        room:  :tracks,
        event: [
          :difficulty_level,
          :track,
          :event_type,
          event_users: :user
        ]
      )

      if @schedule.track
        track = @schedule.track
        @unscheduled_events = track.events.confirmed - @schedule.events
        @dates = track.start_date..track.end_date
        @rooms = [track.room]
      else
        @program.tracks.self_organized.confirmed.each do |t|
          @event_schedules += t.selected_schedule.event_schedules if t.selected_schedule
        end
        self_organized_tracks_events = Event.eager_load(event_users: :user).confirmed.where(track: @program.tracks.self_organized.confirmed)
        @unscheduled_events = @program.events.confirmed - @schedule.events - self_organized_tracks_events
        @dates = @conference.start_date..@conference.end_date
        @rooms = @conference.venue.rooms if @conference.venue
      end
    end

    def destroy
      if @schedule.destroy
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    notice: 'Schedule successfully deleted.'
      else
        redirect_to admin_conference_schedules_path(conference_id: @conference.short_title),
                    error: "Schedule couldn't be deleted. #{@schedule.errors.full_messages.join('. ')}."
      end
    end

    private

    def schedule_params
      params.require(:schedule).permit(:track_id) if params[:schedule]
    end
  end
end
