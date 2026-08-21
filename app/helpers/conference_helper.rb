# frozen_string_literal: true

module ConferenceHelper
  # Return true if only call_for_papers or call_for_tracks or call_for_booths is open
  def one_call_open(*calls)
    calls.one? { |call| call.try(:open?) }
  end
  # Return true if exactly two of those calls are open: call_for_papers , call_for_tracks , call_for_booths

  def two_calls_open(*calls)
    calls.count{ |call| call.try(:open?) } == 2
  end

  # URL for sponsorship emails
  def sponsorship_mailto(conference)
    [
      'mailto:',
      conference.contact.sponsor_email,
      '?subject=',
      url_encode(conference.short_title),
      '%20Sponsorship'
    ].join
  end

  # adds events to icalendar for proposals in a conference
  def icalendar_proposals(calendar, proposals, conference)
    proposals.each do |proposal|
      calendar.event { |e| populate_icalendar_event(e, proposal, conference) }
    end
    calendar
  end

  private

  def populate_icalendar_event(event, proposal, conference)
    length = proposal.event_type&.length
    event.dtstart = proposal.time
    event.dtend = proposal.time + (length * 60) if proposal.time && length
    event.duration = "PT#{length}M" if length
    event.created = proposal.created_at
    event.last_modified = proposal.updated_at
    event.summary = proposal.title
    event.description = proposal.abstract
    event.uid = proposal.guid
    event.url = conference_program_proposal_url(conference.short_title, proposal.id)
    venue = conference.venue
    if venue
      event.geo = venue.latitude, venue.longitude if venue.latitude && venue.longitude
      event.location = icalendar_event_location(proposal, venue)
    end
    event.categories = icalendar_event_categories(proposal, conference)
  end

  def icalendar_event_location(proposal, venue)
    location = ''
    location += "#{proposal.room.name} - " if proposal.room&.name
    location += " - #{venue.street}, " if venue.street
    location += "#{venue.postalcode} #{venue.city}, " if venue.postalcode && venue.city
    location += "#{venue.country_name}, " if venue.country_name
    location
  end

  def icalendar_event_categories(proposal, conference)
    categories = [conference.title]
    categories << "Difficulty: #{proposal.difficulty_level.title}" if proposal.difficulty_level
    categories << "Track: #{proposal.track.name}" if proposal.track
    categories
  end
end
