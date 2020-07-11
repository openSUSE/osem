# frozen_string_literal: true

class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title, except: :show

  def index
    @current    = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
    @antiquated = Conference.where('end_date < ?', Date.current)
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
