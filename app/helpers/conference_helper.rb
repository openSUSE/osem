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
      calendar.event do |e|
        e.dtstart = proposal.time
        e.dtend = proposal.time + proposal.event_type.length * 60
        e.duration = "PT#{proposal.event_type.length}M"
        e.created = proposal.created_at
        e.last_modified = proposal.updated_at
        e.summary = proposal.title
        e.description = proposal.abstract
        e.uid = proposal.guid
        e.url = conference_program_proposal_url(conference.short_title, proposal.id)
        v = conference.venue
        if v
          e.geo = v.latitude, v.longitude if v.latitude && v.longitude
          location = ''
          location += "#{proposal.room.name} - " if proposal.room.name
          location += " - #{v.street}, " if v.street
          location += "#{v.postalcode} #{v.city}, " if v.postalcode && v.city
          location += "#{v.country_name}, " if v.country_name
          e.location = location
        end
        e.categories = conference.title, "Difficulty: #{proposal.difficulty_level.title}", "Track: #{proposal.track.name}"
      end
    end
    calendar
  end
end
