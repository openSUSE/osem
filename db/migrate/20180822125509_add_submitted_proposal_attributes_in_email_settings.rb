# frozen_string_literal: true

class AddSubmittedProposalAttributesInEmailSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :email_settings, :send_on_submitted_proposal, :boolean, default: false
    add_column :email_settings, :submitted_proposal_subject, :string
    add_column :email_settings, :submitted_proposal_body, :text
  end
end
