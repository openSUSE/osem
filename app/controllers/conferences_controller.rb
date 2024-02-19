# frozen_string_literal: true

class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title, except: :show

  def index
    @current    = Conference.upcoming.reorder(start_date: :asc)
    @antiquated = Conference.past
    if @antiquated.empty? && @current.empty? && User.empty?
      render :new_install
    end
  end

  def show
    authorize! :show, conference # TODO: reduce the 10 queries performed here

    splashpage = conference.splashpage

    unless splashpage.present?
      return redirect_to admin_conference_splashpage_path(conference.short_title)
    end

    @image_url = show_variables_fetcher.conference_image_url(request)
  
    assign_cfp_variables if splashpage.include_cfp
      
    assign_program_variables if splashpage.include_program
  
    @tickets = show_variables_fetcher.fetch_tickets
    @lodgings = show_variables_fetcher.fetch_lodgings

    assign_sponsor_variables if splashpage.include_sponsors 
  end

  def calendar
    respond_to do |format|
      format.ics do
        calendar = Icalendar::Calendar.new
        Conference.all.each do |conf|
          if params[:full]
            event_schedules = conf.program.selected_event_schedules(
              includes: [{ event: %i[event_type speakers submitter] }]
            )
            calendar = icalendar_proposals(calendar, event_schedules.map(&:event), conf)
          else
            calendar.event do |e|
              e.dtstart = conf.start_date
              e.dtstart.ical_params = { 'VALUE'=>'DATE' }
              e.dtend = conf.end_date
              e.dtend.ical_params = { 'VALUE'=>'DATE' }
              e.duration = "P#{(conf.end_date - conf.start_date + 1).floor}D"
              e.created = conf.created_at
              e.last_modified = conf.updated_at
              e.summary = conf.title
              e.description = conf.description
              e.uid = conf.guid
              e.url = conference_url(conf.short_title)
              v = conf.venue
              if v
                e.geo = v.latitude, v.longitude if v.latitude && v.longitude
                location = ''
                location += "#{v.street}, " if v.street
                location += "#{v.postalcode} #{v.city}, " if v.postalcode && v.city
                location += v.country_name if v.country_name
                e.location = location if location
              end
            end
          end
        end
        calendar.publish
        render inline: calendar.to_ical
      end
    end
  end

  private

  def assign_program_variables
    @highlights = conference.highlighted_events.eager_load(:speakers)
    @tracks = show_variables_fetcher.fetch_tracks
    @booths = show_variables_fetcher.fetch_booths
  end

  def assign_cfp_variables
    @call_for_events = show_variables_fetcher.cfp_call_by_type('events')
    @event_types, @track_names = show_variables_fetcher.event_types_and_track_names(@call_for_events)
    @call_for_tracks = show_variables_fetcher.cfp_call_by_type('tracks')
    @call_for_booths = show_variables_fetcher.cfp_call_by_type('booths')
  end

  def assign_sponsor_variables
    @sponsorship_levels = show_variables_fetcher.sponsorship_levels
    @sponsors = conference.sponsors
  end

  def conference
    @conference ||= Queries::Conferences::conference_by_filter(conference_finder_conditions)
  end

  def show_variables_fetcher
    show_variables_fetcher ||= Conferences::ShowVariablesFetcher.new(conference: conference)
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
