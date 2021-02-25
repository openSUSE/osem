# frozen_string_literal: true

# == Schema Information
#
# Table name: rooms
#
#  id       :bigint           not null, primary key
#  guid     :string           not null
#  name     :string           not null
#  order    :integer
#  size     :integer
#  url      :string
#  venue_id :integer          not null
#
FactoryBot.define do
  factory :room do
    name { "Room #{Faker::Address.country}" }
    size { 4 }

    venue

    factory :room_for_100 do
      name { 'Room for 100' }
      size { 100 }
    end
  end
end
