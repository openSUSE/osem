# frozen_string_literal: true

# == Schema Information
#
# Table name: event_users
#
#  id         :bigint           not null, primary key
#  comment    :string
#  event_role :string           default("participant"), not null
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#  user_id    :integer
#

FactoryBot.define do
  factory :event_user do
    user

    Hash[EventUser::ROLES].each_value do |role|
      factory role do
        event_role { role }
      end
    end
  end
end
