class DifficultyLevel < ActiveRecord::Base
  attr_accessible :title, :description, :color
  
  belongs_to :conference
  has_many :events

  validates :title, presence: true
end
