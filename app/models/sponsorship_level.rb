class SponsorshipLevel < ActiveRecord::Base
  attr_accessible :title, :conference_id
  validates_presence_of :title
  belongs_to :conference
  acts_as_list scope: :conference
  has_many :sponsors
end
