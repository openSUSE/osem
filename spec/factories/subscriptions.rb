# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#  user_id       :integer
#
FactoryBot.define do
  factory :subscription do
    user
    conference
  end

end
