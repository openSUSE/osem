# frozen_string_literal: true

class SurveySubmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_replies, through: :user

  validates :user_id, uniqueness: { scope: :survey_id }

  accepts_nested_attributes_for :survey_replies
end
