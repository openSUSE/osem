# frozen_string_literal: true

class MailblusterEditLeadJob < ApplicationJob
  queue_as :default

  def perform(user, add_tags: [], remove_tags: [], old_email: nil)
    ApplicationController.helpers.edit_lead(user,
                                            add_tags: add_tags, remove_tags: remove_tags, old_email: old_email)
  end
end
