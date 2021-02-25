# frozen_string_literal: true

# == Schema Information
#
# Table name: vpositions
#
#  id            :bigint           not null, primary key
#  description   :text
#  title         :string           not null
#  created_at    :datetime
#  updated_at    :datetime
#  conference_id :integer
#
FactoryBot.define do
  factory :vposition do
    title { 'Example Volunteer Position' }
    description { 'Lorem Ipsum dolsum' }
    conference

    after(:build) do |vposition|
      vposition.vdays << build(:vday, conference: vposition.conference)
    end
  end

end
