class Answer < ActiveRecord::Base
  attr_accessible :title

  has_many :qanswers, dependent: :destroy
  has_many :questions, through: :qanswers

  validates :title, presence: true
  validate :no_modification_if_used

  def no_modification_if_used
    errors.add('', 'cannot be altered or deleted, if they are being used.') if self.title_changed? && self.questions.any?
  end

  # Gets answer, question, conference
  ## Returns
  # the amount of replies for a given answer
  # + integer +
  def sum_replies question, conference
    self.qanswers.find_by(question: question).registrations.where(conference: conference).count
  end
end
