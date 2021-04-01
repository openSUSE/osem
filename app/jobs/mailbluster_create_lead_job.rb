# frozen_string_literal: true

class MailblusterCreateLeadJob < ApplicationJob
  queue_as :default

  def perform(user)
    MailblusterManager.create_lead(user)
  end
end
