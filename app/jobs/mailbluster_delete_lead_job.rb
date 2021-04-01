class MailblusterDeleteLeadJob < ApplicationJob
  queue_as :default

  def perform(user)
    MailblusterManager.delete_lead(user)
  end
end
