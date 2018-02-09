# frozen_string_literal: true

class SurveyReply < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey_question
  serialize :text

  validates :user_id, :survey_question_id, presence: true
  validates :survey_question_id, uniqueness: { scope: :user_id }
end
