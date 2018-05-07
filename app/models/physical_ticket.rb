# frozen_string_literal: true

class PhysicalTicket < ApplicationRecord
  belongs_to :ticket_purchase
  has_one :ticket, through: :ticket_purchase
  has_one :conference, through: :ticket_purchase
  has_one :user, through: :ticket_purchase
  has_many :ticket_scannings

  before_create :set_token

  private

  def set_token
    self.token = generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex(10)
      break token unless PhysicalTicket.exists?(token: token)
    end
  end
end
