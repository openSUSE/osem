class Qanswer < ActiveRecord::Base
  belongs_to :question
  belongs_to :answer, dependent: :delete

  has_and_belongs_to_many :registrations

  validates :question, :answer, presence: true
end
