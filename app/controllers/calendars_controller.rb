class CalendarsController < ApplicationController
  skip_authorization_check only: :index

  # GET /calendars
  def index
    calendar = Icalendar::Calendar.new

    Conference.all.each do |conference|
      if params[:full]
        event_schedules = conference.program.selected_event_schedules(
          includes: [{ event: %i[event_type speakers submitter] }]
        )
        calendar = build_icalendar_from_proposals(calendar, event_schedules.map(&:event), conference)
      else
        calendar = build_icalender_from_conference(calendar, conference)
      end
    end

    respond_to do |format|
      format.ics do
        calendar.publish
        render inline: calendar.to_ical
      end
    end
  end

  private

  def build_icalender_from_conference(calendar, conference)
    calendar.event do |event|
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
      event.url = conference_url(conference.short_title)

      venue = conference.venue
      if venue
        event.geo = venue.latitude, venue.longitude if venue.latitude && venue.longitude

        location = ''
        location += "#{venue.street}, " if venue.street
        location += "#{venue.postalcode} #{venue.city}, " if venue.postalcode && venue.city
        location += venue.country_name if venue.country_name
        event.location = location if location
      end
    end
    calendar
  end

  # adds events to icalendar for proposals in a conference
  def build_icalendar_from_proposals(calendar, proposals, conference)
    proposals.each do |proposal|
      calendar.event do |event|
        event.dtstart = proposal.time
        event.dtend = proposal.time + (proposal.event_type.length * 60)
        event.duration = "PT#{proposal.event_type.length}M"
        event.created = proposal.created_at
        event.last_modified = proposal.updated_at
        event.summary = proposal.title
        event.description = proposal.abstract
        event.uid = proposal.guid
        event.url = conference_program_proposal_url(conference.short_title, proposal.id)
        venue = conference.venue
        if venue
          event.geo = venue.latitude, venue.longitude if venue.latitude && venue.longitude

          location = ''
          location += "#{proposal.room.name} - " if proposal.room.name
          location += " - #{venue.street}, " if venue.street
          location += "#{venue.postalcode} #{venue.city}, " if venue.postalcode && venue.city
          location += "#{venue.country_name}, " if venue.country_name
          event.location = location
        end
        if proposal.difficulty_level && proposal.track
          event.categories = proposal.title, "Difficulty: #{proposal.difficulty_level.title}", "Track: #{proposal.track.name}"
        end
      end
    end
    calendar
  end
end
