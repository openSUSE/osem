# frozen_string_literal: true

FactoryGirl.define do
  factory :vday do
    day { Time.zone.today }
    description 'Lorem Ipsum dolsum'
    conference
  end

end
