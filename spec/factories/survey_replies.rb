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
FactoryBot.define do
  factory :survey_reply do
    user
    survey_question
  end
end
