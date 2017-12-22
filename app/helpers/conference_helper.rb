module ConferenceHelper
  # Return true if only call_for_papers or call_for_tracks is open
  def one_call_open(*calls)
    calls.one? { |call| call.try(:open?) }
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
end
