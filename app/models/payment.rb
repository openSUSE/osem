class Payment < ActiveRecord::Base
  has_many :ticket_purchases
  belongs_to :user
  belongs_to :conference

  validates :last4, presence: true
  validates :authorization_code, presence: true
  validates :status, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :conference_id, presence: true

  enum status: {
    unpaid: 0,
    success: 1,
    failure: 2
  }

  def self.purchase(gateway_response, user, conference)
    create(last4: gateway_response[:source][:last4],
           amount: gateway_response[:amount],
           status: (gateway_response[:paid] ? 1 : 0),
           authorization_code: gateway_response[:id],
           user_id: user.id,
           conference_id: conference.id)
  end
end
