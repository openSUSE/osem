class SponsorshipLevel < ActiveRecord::Base
  attr_accessible :title, :description
  belongs_to :conference
  has_many :sponsorship_registrations
  validates_presence_of :title
end
