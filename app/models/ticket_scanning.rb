# frozen_string_literal: true

# == Schema Information
#
# Table name: ticket_scannings
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  physical_ticket_id :integer          not null
#
class TicketScanning < ApplicationRecord
  belongs_to :physical_ticket

  before_create :mark_user_present

  private

  def mark_user_present
    if physical_ticket.ticket.registration_ticket?
      physical_ticket.user.mark_attendance_for_conference(physical_ticket.conference)
    end
  end
end
