# frozen_string_literal: true

FactoryGirl.define do
  factory :vposition do
    title 'Example Volunteer Position'
    description 'Lorem Ipsum dolsum'
    conference

    after(:build) do |vposition|
      vposition.vdays << build(:vday, conference: vposition.conference)
    end
  end

end
