# frozen_string_literal: true

# == Schema Information
#
# Table name: tracks
#
#  id                   :bigint           not null, primary key
#  cfp_active           :boolean          not null
#  color                :string
#  description          :text
#  end_date             :date
#  guid                 :string           not null
#  name                 :string           not null
#  relevance            :text
#  short_name           :string           not null
#  start_date           :date
#  state                :string           default("new"), not null
#  created_at           :datetime
#  updated_at           :datetime
#  program_id           :integer
#  room_id              :integer
#  selected_schedule_id :integer
#  submitter_id         :integer
#
# Indexes
#
#  index_tracks_on_room_id               (room_id)
#  index_tracks_on_selected_schedule_id  (selected_schedule_id)
#  index_tracks_on_submitter_id          (submitter_id)
#
FactoryBot.define do
  factory :track do
    name { Faker::Commerce.department(2, true) }
    description { Faker::Lorem.sentence }
    color { Faker::Color.hex_color }
    short_name { SecureRandom.urlsafe_base64(5) }
    state { 'confirmed' }
    cfp_active { true }
    program

    trait :self_organized do
      association :submitter, factory: :user
      state { 'new' }
      cfp_active { false }
      start_date { Time.zone.today }
      end_date { Time.zone.today }
      room
      relevance { Faker::Hipster.paragraph(2) }
    end
  end
end
