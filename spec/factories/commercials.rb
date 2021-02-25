# frozen_string_literal: true

# == Schema Information
#
# Table name: commercials
#
#  id                  :bigint           not null, primary key
#  commercial_type     :string
#  commercialable_type :string
#  url                 :string
#  created_at          :datetime
#  updated_at          :datetime
#  commercial_id       :string
#  commercialable_id   :integer
#

FactoryBot.define do
  factory :commercial do
    sequence(:url) { |n| "https://www.youtube.com/watch?v=4VrhlyIgo3M&factory=#{n}" }

    factory :conference_commercial do
      association :commercialable, factory: :conference
    end

    factory :event_commercial do
      association :commercialable, factory: :event
    end
  end
end
