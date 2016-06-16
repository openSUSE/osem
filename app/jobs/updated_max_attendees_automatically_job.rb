class UpdatedMaxAttendeesAutomaticallyJob < ActiveJob::Base
  queue_as :default

  def perform(event, users_emails=nil)
    if users_emails.present?
      event.program.conference.email_settings.updated_max_attendees_automatically_body << "\n\nThe following users have been unregistered from your event:\n #{users_emails}"
    end

    event.users.uniq.each do |user|
      Mailbot.updated_max_attendees_automatically(event.program.conference, user, event).deliver_now
    end
  end
end
