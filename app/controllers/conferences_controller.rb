# frozen_string_literal: true

EVENTS_PER_PAGE = 3

class ConferencesController < ApplicationController
  include ConferenceHelper

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
    # load conference with header content
    @conference = Conference.unscoped.eager_load(
      :splashpage,
      :program,
      :registration_period,
      :contact,
      venue: :commercial
    ).find_by!(conference_finder_conditions)
    authorize! :show, @conference # TODO: reduce the 10 queries performed here

    splashpage = @conference.splashpage

    unless splashpage.present?
      redirect_to admin_conference_splashpage_path(@conference.short_title) && return
    end

    # User messages at the top of the page.
    @unpaid_tickets = current_user_has_unpaid_tickets?
    @user_needs_to_register = current_user_needs_to_register?

    @image_url = "#{request.protocol}#{request.host}#{@conference.picture}"

    if splashpage.include_cfp
      cfps = @conference.program.cfps
      @call_for_events = cfps.find { |call| call.cfp_type == 'events' }
      if @call_for_events.try(:open?)
        @event_types = @conference.event_types.pluck(:title)
        @track_names = @conference.confirmed_tracks.pluck(:name).sort
      end
      @call_for_tracks = cfps.find { |call| call.cfp_type == 'tracks' }
      @call_for_booths = cfps.find { |call| call.cfp_type == 'booths' }
    end
    if splashpage.include_program
      @highlights = @conference.highlighted_events.eager_load(:speakers)
      if splashpage.include_tracks
        @tracks = @conference.confirmed_tracks.eager_load(
          :room
        ).order('tracks.name')
      end
      if splashpage.include_booths
        @booths = @conference.confirmed_booths.order('title')
      end
    end
    if splashpage.include_registrations || splashpage.include_tickets
      @tickets = @conference.tickets.visible.order('price_cents')
    end
    if splashpage.include_lodgings
      @lodgings = @conference.lodgings.order('id')
    end
    if splashpage.include_sponsors
      @sponsorship_levels = @conference.sponsorship_levels.eager_load(
        :sponsors
      ).order('sponsorship_levels.position ASC', 'sponsors.name')
      @sponsors = @conference.sponsors
    end
    if splashpage.include_happening_now
      events_schedules_list = get_happening_now_events_schedules(@conference)
      @events_schedules_limit = EVENTS_PER_PAGE
      @events_schedules_length = events_schedules_list.length
      @pagy, @events_schedules = pagy_array(events_schedules_list, items: @events_schedules_limit, link_extra: 'data-remote="true"')
      @happening_now_url = happening_now_conference_schedule_path(conference_id: @conference.short_title, format: :json)
    end
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

  def current_user_tickets
    @current_user_tickets ||= current_user.ticket_purchases.by_conference(@conference)
  end

  def current_user_needs_to_register?
    current_user && !@conference.user_registered?(current_user) &&
      current_user_tickets.where(ticket: @conference.registration_tickets).paid.any?
  end

  def current_user_has_unpaid_tickets?
    current_user && current_user_tickets.unpaid.any?
  end
end
