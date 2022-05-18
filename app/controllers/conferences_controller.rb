# frozen_string_literal: true

class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  before_action :conference, only: [:show]
  before_action :set_conferences_service, only: [:show]
  load_and_authorize_resource find_by: :short_title, except: :show

  def index
    @current    = Conference.upcoming.reorder(start_date: :asc)
    @antiquated = Conference.past
    if @antiquated.empty? && @current.empty? && User.empty?
      render :new_install
    end
  end

  def show
    authorize! :show, @conference # TODO: reduce the 10 queries performed here

    splashpage = @conference.splashpage

    unless splashpage.present?
      redirect_to admin_conference_splashpage_path(@conference.short_title) && return
    end
    handle_present_splash_page(splashpage)
  end

  def calendar
    respond_to do |format|
      format.ics do
        calendar = Icalendar::Calendar.new
        Conference.all.each do |conf|
          service = ConferenceCalendarService.new(calendar, conf)
          calendar = if params[:full]
                       service.full_calendar
                     else
                       service.not_full_calendar
                     end
        end
        calendar.publish
        render inline: calendar.to_ical
      end
    end
  end

  private

  def handle_present_splash_page(splashpage)
    @image_url = @service.conference_image_url(request)

    if splashpage.include_cfp
      cfp_variables
    end

    if splashpage.include_program
      program_variables
    end

    @tickets = @service.if_include_registrations_or_tickets
    @lodgings = @service.if_include_lodgings

    if splashpage.include_sponsors
      sponsor_variables
    end
  end

  def program_variables
    @highlights = @conference.highlighted_events.eager_load(:speakers)
    @tracks = @service.if_include_tracks
    @booths = @service.if_include_booths
  end

  def cfp_variables
    @call_for_events = @service.cfp_call_by_type('events')
    @event_types, @track_names = @service.cfp_variables_if_event_open(@call_for_events)
    @call_for_tracks = @service.cfp_call_by_type('tracks')
    @call_for_booths = @service.cfp_call_by_type('booths')
  end

  def sponsor_variables
    @sponsorship_levels = @service.sponsorship_levels
    @sponsors = @conference.sponsors
  end

  def conference
    @conference = ConferencesService.conference_by_filter(conference_finder_conditions)
  end

  def set_conferences_service
    @service = ConferencesService.new(@conference)
  end

  def conference_finder_conditions
    if params[:id]
      { short_title: params[:id] }
    else
      { custom_domain: request.domain }
    end
  end

  def respond_to_options
    respond_to do |format|
      format.html { head :ok }
    end if request.options?
  end
end
