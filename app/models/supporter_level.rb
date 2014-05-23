class SupporterLevel < ActiveRecord::Base
  belongs_to :conference
  has_many :supporter_registrations
  monetize :price_cents, with_model_currency: :price_currency
  attr_accessible :conference, :title, :url, :description, :price_currency, :amount, :price_cents
  validate :convert_money_to_cents
  
  private
  
  def convert_money_to_cents
    self.price_cents = (self.amount.to_d * 100).to_i
  end
end
