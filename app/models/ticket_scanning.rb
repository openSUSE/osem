# frozen_string_literal: true

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
