# frozen_string_literal: true

# == Schema Information
#
# Table name: programs
#
#  id                   :bigint           not null, primary key
#  blind_voting         :boolean          default(FALSE)
#  languages            :string
#  rating               :integer          default(0)
#  schedule_fluid       :boolean          default(FALSE)
#  schedule_interval    :integer          default(15), not null
#  schedule_public      :boolean          default(FALSE)
#  voting_end_date      :datetime
#  voting_start_date    :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  conference_id        :integer
#  selected_schedule_id :integer
#
# Indexes
#
#  index_programs_on_selected_schedule_id  (selected_schedule_id)
#

FactoryBot.define do
  factory :program do
    schedule_public { false }
    schedule_fluid { false }
    conference

    trait :with_cfp do
      after(:create) { |program| create(:cfp, program: program) }
    end
  end
end
