class MailblusterDeleteLeadJob < ApplicationJob
  queue_as :default

  def perform(user)
    ApplicationController.helpers.delete_lead(user)
  end
end
