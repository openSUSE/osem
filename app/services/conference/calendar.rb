class Conferences::Calendar
  private_class_method :new

  def self.call(conference:, is_full_calendar:)
    new(conference, is_full_calendar).call
  end

  def initialize(conference:, is_full_calendar:)
    @calendar = Icalendar::Calendar.new
    @conference = conference
    @is_full_calendar = is_full_calendar
  end

  def not_full_calendar
    calendar.event do |e|
      default_calendar_params(e)
      if @conference.venue
        venue_calendar_params(e)
      end
    end
    calendar
  end

  def full_calendar
    icalendar_proposals(@calendar, event_schedules.map(&:event), @conference)
  end

  private

  def default_calendar_params(event)
    event.dtstart = @conference.start_date
    event.dtstart.ical_params = { 'VALUE'=>'DATE' }
    event.dtend = @conference.end_date
    event.dtend.ical_params = { 'VALUE'=>'DATE' }
    event.duration = "P#{(@conference.end_date - @conference.start_date + 1).floor}D"
    event.created = @conference.created_at
    event.last_modified = @conference.updated_at
    event.summary = @conference.title
    event.description = @conference.description
    event.uid = @conference.guid
    event.url = conference_url(@conference.short_title)
  end

  def venue_calendar_params(event)
    venue = @conference.venue
    event.geo = venue.latitude, venue.longitude if venue.latitude && venue.longitude
    location = location(venue)
    event.location = location if location
  end

  def location(venue)
    location = ''
    location += "#{venue.street}, " if venue.street
    location += "#{venue.postalcode} #{venue.city}, " if venue.postalcode && venue.city
    location += venue.country_name if venue.country_name
    location
  end

  def event_schedules
    @conference.program.selected_event_schedules(
        includes: [{ event: %i[event_type speakers submitter] }]
      )
  end
end
