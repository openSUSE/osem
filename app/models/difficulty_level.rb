class DifficultyLevel < ActiveRecord::Base
  attr_accessible :title, :description, :color, :conference_id

  belongs_to :conference
  has_many :events, dependent: :nullify

  validates :title, presence: true
end
