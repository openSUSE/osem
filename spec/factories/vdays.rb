# frozen_string_literal: true

# == Schema Information
#
# Table name: vdays
#
#  id            :bigint           not null, primary key
#  day           :date
#  description   :text
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
FactoryBot.define do
  factory :vday do
    day { Time.zone.today }
    description { 'Lorem Ipsum dolsum' }
    conference
  end

end
