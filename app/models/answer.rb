class Answer < ApplicationRecord
  has_many :qanswers
  has_many :questions, through: :qanswers

  validates :title, presence: true
end
