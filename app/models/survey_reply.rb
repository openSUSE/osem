class SurveyReply < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey_question
  serialize :text
end
