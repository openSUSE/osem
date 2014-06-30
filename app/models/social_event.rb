class SocialEvent < ActiveRecord::Base
  attr_accessible :title, :description, :date

  belongs_to :conference
  has_and_belongs_to_many :registrations
end
