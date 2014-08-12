class SupporterLevel < ActiveRecord::Base
  belongs_to :conference
  has_many :supporter_registrations

  attr_accessible :conference, :title, :url, :description, :ticket_price, :conference_id
end
