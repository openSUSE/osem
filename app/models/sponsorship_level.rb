class SponsorshipLevel < ActiveRecord::Base
  attr_accessible :title, :donation_amount
  validates_presence_of :title
  belongs_to :conference
end
