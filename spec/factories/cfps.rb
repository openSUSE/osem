# frozen_string_literal: true

# == Schema Information
#
# Table name: cfps
#
#  id                   :bigint           not null, primary key
#  cfp_type             :string
#  description          :text
#  enable_registrations :boolean          default(FALSE)
#  end_date             :date             not null
#  start_date           :date             not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#

FactoryBot.define do
  factory :cfp do
    start_date { 1.day.ago }
    end_date { 2.days.from_now }
    cfp_type { 'events' }
    description { 'This is a test description' }
    enable_registrations { true }
    program
  end
end
