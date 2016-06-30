class Survey < ActiveRecord::Base
  belongs_to :surveyable, polymorphic: true
  has_many :survey_questions

  enum target: [:after_conference, :during_registration]
  validates :title, presence: true
end
