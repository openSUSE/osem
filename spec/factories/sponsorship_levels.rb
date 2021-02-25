# frozen_string_literal: true

# == Schema Information
#
# Table name: sponsorship_levels
#
#  id            :bigint           not null, primary key
#  position      :integer
#  title         :string
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#

FactoryBot.define do
  factory :sponsorship_level do
    title { Faker::Lorem.word }

    conference
  end
end
