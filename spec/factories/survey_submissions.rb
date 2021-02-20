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
FactoryBot.define do
  factory :survey_submission do
    user
    survey
  end
end
