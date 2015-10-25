class DifficultyLevel < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  validates :title, presence: true
end
