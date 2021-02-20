# frozen_string_literal: true

# == Schema Information
#
# Table name: events_registrations
#
#  id              :bigint           not null, primary key
#  attended        :boolean          default(FALSE), not null
#  created_at      :datetime
#  event_id        :integer
#  registration_id :integer
#

FactoryBot.define do
  factory :events_registration do
    event
    registration
  end
end
