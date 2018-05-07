# frozen_string_literal: true

class ConferenceScheduleUpdateMailJob < ApplicationJob
  queue_as :default

  def perform(conference)
    conference.subscriptions.each do |subscription|
      Mailbot.conference_schedule_update_mail(conference, subscription.user).deliver_now
    end
  end
end
