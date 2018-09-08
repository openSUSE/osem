# frozen_string_literal: true

FactoryBot.define do
  factory :vday do
    day { Time.zone.today }
    description { 'Lorem Ipsum dolsum' }
    conference
  end

end
