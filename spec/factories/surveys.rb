# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id              :bigint           not null, primary key
#  description     :text
#  end_date        :datetime
#  start_date      :datetime
#  surveyable_type :string
#  target          :integer          default("after_conference")
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  surveyable_id   :integer
#
# Indexes
#
#  index_surveys_on_surveyable_type_and_surveyable_id  (surveyable_type,surveyable_id)
#
FactoryBot.define do
  factory :survey do
    title { 'This is my survey' }
    start_date { Date.current - 1.day }
    end_date { Date.current + 1.day }

    factory :conference_survey do
      association :surveyable, factory: :conference
    end

    factory :registration_survey do
      association :surveyable, factory: :registration
    end
  end
end
