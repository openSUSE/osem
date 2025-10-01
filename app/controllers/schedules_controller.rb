# frozen_string_literal: true

class SchedulesController < ApplicationController
  load_and_authorize_resource
  before_action :respond_to_options
  load_resource :conference, find_by: :short_title
  load_resource :program, through: :conference, singleton: true, except: :index
  before_action :load_withdrawn_event_schedules, only: [:show, :events]

  def show
    redirect_to events_conference_schedule_path(@conference.short_title)
  end

  def events
    @dates = @conference.start_date..@conference.end_date
    @events_schedules = @program.selected_event_schedules(
      includes: [:room, { event: %i[track event_type speakers submitter] }]
    )
    @events_schedules = [] unless @events_schedules

    @unscheduled_events = @program.events.confirmed - @events_schedules.map(&:event)

    day = @conference.current_conference_day
    @tag = day.strftime('%Y-%m-%d') if day
  end

  def app
    @qr_code = RQRCode::QRCode.new(conference_schedule_url).as_svg(offset: 20, color: '000', shape_rendering: 'crispEdges', module_size: 11)
  end

  private

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end

  def load_withdrawn_event_schedules
    # Avoid making repetitive EXISTS queries for these later.
    # See usage in EventsHelper#canceled_replacement_event_label
    @withdrawn_event_schedules = EventSchedule.withdrawn_or_canceled_event_schedules(@program.schedule_ids)
  end
end
