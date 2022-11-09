class Conference::Calendar::EventBuilder
  include ConferenceHelper

  def self.call(conference:, is_full_calendar:, calendar:, conference_url:)
    new(conference:, is_full_calendar:, calendar:, conference_url:).call
  end

  def initialize(conference:, is_full_calendar:, calendar:, conference_url:)
    @calendar = calendar
    @conference_url = conference_url
    @conference = conference
    @is_full_calendar = is_full_calendar
    @venue = conference.venue
  end

  def call
    return build_full_calendar if is_full_calendar
     
    build_not_full_calendar
  end

  private
  attr :conference, :is_full_calendar, :calendar, :conference_url, :venue

  def build_full_calendar
    event_schedules = conference.program.selected_event_schedules(
      includes: [{ event: %i[event_type speakers submitter] }]
    )
    icalendar_proposals(calendar, event_schedules.map(&:event), conference)
  end

  def build_not_full_calendar
    calendar.event do |event|
      build_event_general_informations(event)
      build_event_venue(event) if venue
    end
    calendar
  end

  def build_event_general_informations(event)
    event.dtstart = conference.start_date
    event.dtstart.ical_params = { 'VALUE'=>'DATE' }
    event.dtend = conference.end_date
    event.dtend.ical_params = { 'VALUE'=>'DATE' }
    event.duration = "P#{(conference.end_date - conference.start_date + 1).floor}D"
    event.created = conference.created_at
    event.last_modified = conference.updated_at
    event.summary = conference.title
    event.description = conference.description
    event.uid = conference.guid
    event.url = conference_url
  end

  def build_event_venue(event)
    event.geo = venue.latitude, venue.longitude if venue.latitude && venue.longitude
    location = build_venue_location
    event.location = location if location
  end
  
  def build_venue_location
    location = ''
    location += "#{venue.street}, " if venue.street
    location += "#{venue.postalcode} #{venue.city}, " if venue.postalcode && venue.city
    location += venue.country_name if venue.country_name
    location
  end
end
