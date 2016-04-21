class ConferenceCfpUpdateMailJob < ActiveJob::Base
  queue_as :default

  def perform(conference)
    conference.subscriptions.each do |subscription|
      Mailbot.conference_cfp_update_mail(conference, subscription.user).deliver_now
    end
  end
end
