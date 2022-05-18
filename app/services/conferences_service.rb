class ConferencesService
  def initialize(conference = nil)
    @conference = conference
    @cfps = @conference&.program&.cfps
    @splashpage = @conference&.splashpage
  end

  def self.conference_by_filter(conference_finder_conditions)
    Conference.unscoped.eager_load(
        :splashpage,
        :program,
        :registration_period,
        :contact,
        venue: :commercial
      ).find_by!(conference_finder_conditions)
  end

  def conference_image_url(request)
    "#{request.protocol}#{request.host}#{@conference.picture}"
  end

  def cfp_variables_if_event_open(call_for_events)
    if call_for_events.try(:open?)
      [event_types, track_names]
    end
  end

  def cfp_call_by_type(type)
    @cfps.find { |call| call.cfp_type == type }
  end

  def if_include_tracks
    if @splashpage.include_tracks
      tracks
    end
  end

  def if_include_booths
    if @splashpage.include_booths
      booths
    end
  end

  def if_include_registrations_or_tickets
    if @splashpage.include_registrations || @splashpage.include_tickets
      tickets
    end
  end

  def if_include_lodgings
    if @splashpage.include_lodgings
      lodgings
    end
  end

  def sponsorship_levels
    @conference.sponsorship_levels.eager_load(
        :sponsors
      ).order('sponsorship_levels.position ASC', 'sponsors.name')
  end

  private

  def lodgings
    @conference.lodgings.order('name')
  end

  def track_names
    @conference.confirmed_tracks.pluck(:name).sort
  end

  def event_types
    @conference.event_types.pluck(:title)
  end

  def tracks
    @conference.confirmed_tracks.eager_load(
        :room
      ).order('tracks.name')
  end

  def booths
    @conference.confirmed_booths.order('title')
  end

  def tickets
    @conference.tickets.order('price_cents')
  end
end
