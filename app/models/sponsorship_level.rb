class SponsorshipLevel < ActiveRecord::Base
  attr_accessible :title, :conference_id
  validates_presence_of :title
  belongs_to :conference
  has_many :sponsors
end
