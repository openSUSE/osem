# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_replies
#
#  id                 :bigint           not null, primary key
#  text               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  survey_question_id :integer
#  user_id            :integer
#
class SurveyReply < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey_question
  serialize :text

  validates :user_id, :survey_question_id, presence: true
  validates :survey_question_id, uniqueness: { scope: :user_id }
end
