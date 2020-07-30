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

  def short_ticket_description(ticket)
    return unless ticket.description
    markdown(ticket.description.split("\n").first&.strip)
  end
end
