module ShareableHelper
  def get_shareable_title(event)
    "Watching #{event.title} by #{event.speaker_names}"
  end

  def get_shareable_url(event, conference)
    url_for(conference_program_proposal_path(conference.short_title, event.id))
  end

  HANDLE_REGEX=/((https?:\/\/)?(www\.)?twitter\.com\/)?(@|#!\/)?([A-Za-z0-9_]{1,15})(\/([-a-z]{1,20}))?/
  def get_twitter_handle(event)
    twitter = event.program.conference.contact.twitter
    return HANDLE_REGEX.match(twitter)[5] unless twitter.blank?
  end
end
