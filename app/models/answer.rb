class Answer < ActiveRecord::Base
  attr_accessible :title

  has_many :qanswers
  has_many :questions, through: :qanswers

  validates :title, presence: true
end
