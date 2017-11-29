class ConferencesController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :respond_to_options
  load_and_authorize_resource find_by: :short_title, except: :show

  def index
    @current = Conference.where('end_date >= ?', Date.current).reorder(start_date: :asc)
    @antiquated = @conferences - @current
  end

  def show
    @conference = Conference.unscoped.eager_load(
      :organization,
      :splashpage,
      :registration_period,
      :tickets,
      :confirmed_tracks,
      :call_for_events,
      :event_types,
      :program,
      :call_for_tracks,
      :lodgings,
      :call_for_booths,
      :confirmed_booths,
      :sponsors,
      :call_for_sponsors,
      :contact,
      venue:              [:commercial],
      highlighted_events: [:speakers],
      sponsorship_levels: [:sponsors]
    ).order(
      'sponsorship_levels.position ASC',
      'sponsors.name',
      'tracks.name',
      'booths.title',
      'lodgings.name',
      'tickets.price_cents'
    ).find_by(conference_finder_conditions)
    authorize! :show, @conference
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
end
