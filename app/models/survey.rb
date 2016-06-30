class Survey < ActiveRecord::Base
  belongs_to :surveyable, polymorphic: true
  has_many :survey_questions

  enum target: [:conference, :registration]

  validates :title, presence: true
end
