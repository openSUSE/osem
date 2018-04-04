# frozen_string_literal: true

class ConferenceRegistrationDateUpdateMailJob < ApplicationJob
  queue_as :default

  def perform(conference)
    conference.subscriptions.each do |subscription|
      Mailbot.conference_registration_date_update_mail(conference, subscription.user).deliver_now
    end
  end
end
