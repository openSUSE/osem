# frozen_string_literal: true

class MailblusterCreateLeadJob < ApplicationJob
  queue_as :default

  def perform(user)
    ApplicationController.helpers.create_lead(user)
  end
end
