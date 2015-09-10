class Qanswer < ActiveRecord::Base
  attr_accessible :question_id, :answer_id

  belongs_to :question
  belongs_to :answer

  has_and_belongs_to_many :registrations

  validates :question, :answer, presence: true
end
