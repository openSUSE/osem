module Admin
  class SpeakersController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :speaker, through: :conference

    respond_to :js, :html

    def edit
      @event = @conference.events.find(params[:event_id])
      @speaker = @event.event_users.where(event_role: 'speaker').first
    end

    def update
      @event = @conference.events.find(params[:event_id])
      @speaker = @event.event_users.where(event_role: 'speaker').first
      @speaker.user_id = params[:speaker][:user_id]
      @speaker.save
      respond_with @speaker, location: admin_conference_events_path(@conference.short_title)
    end
  end
end
