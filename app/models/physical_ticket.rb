class PhysicalTicket < ActiveRecord::Base
  belongs_to :ticket_purchase
  has_one :ticket, through: :ticket_purchase
  has_one :conference, through: :ticket_purchase
  has_one :user, through: :ticket_purchase
  has_many :ticket_scannings
end
