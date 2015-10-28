class DifficultyLevel < ActiveRecord::Base
  belongs_to :conference
  has_many :events, dependent: :nullify

  validates :title, presence: true
end
