class DeletedEventRegistrationAutomaticallyJob < ActiveJob::Base
  queue_as :default

  def perform(conference, user, event)
    Mailbot.deleted_event_registration_automatically(conference, user, event).deliver_now
  end
end
