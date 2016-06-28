class SurveyReply < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey_question
  serialize :text

  validates :survey_question_id, uniqueness: { scope: :user_id }
end
