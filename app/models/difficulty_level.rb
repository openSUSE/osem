class DifficultyLevel < ActiveRecord::Base
  attr_accessible :title, :description, :color, :conference_id

  belongs_to :conference
  has_many :events

  validates :title, presence: true
end
