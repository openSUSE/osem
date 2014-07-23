class DietaryChoice < ActiveRecord::Base
  attr_accessible :title

  belongs_to :conference
  has_many :registrations
end
