# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_submissions
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  survey_id  :integer
#  user_id    :integer
#
class SurveySubmission < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_replies, through: :user

  validates :user_id, uniqueness: { scope: :survey_id }

  accepts_nested_attributes_for :survey_replies
end
