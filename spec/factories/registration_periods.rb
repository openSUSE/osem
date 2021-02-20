# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_periods
#
#  id            :bigint           not null, primary key
#  end_date      :date
#  start_date    :date
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#

FactoryBot.define do
  factory :registration_period do
    start_date { 3.days.ago }
    end_date { 5.days.from_now }
  end
end
