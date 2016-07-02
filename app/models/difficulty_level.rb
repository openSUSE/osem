class DifficultyLevel < ActiveRecord::Base
  belongs_to :program
  has_many :events, dependent: :nullify

  validates :title, presence: true
  validates :color, format: /\A#[0-9a-fA-F]{6}\z/
end
