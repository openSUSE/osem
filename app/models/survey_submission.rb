class SurveySubmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_replies, through: :user

  accepts_nested_attributes_for :survey_replies
end
