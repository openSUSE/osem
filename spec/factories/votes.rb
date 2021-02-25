# frozen_string_literal: true

# == Schema Information
#
# Table name: votes
#
#  id         :bigint           not null, primary key
#  rating     :integer
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#  user_id    :integer
#
FactoryBot.define do
  factory :vote do
    event
    user
    rating { 1 }
  end
end
