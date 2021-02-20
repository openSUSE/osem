# frozen_string_literal: true

# == Schema Information
#
# Table name: difficulty_levels
#
#  id          :bigint           not null, primary key
#  color       :string
#  description :text
#  title       :string
#  created_at  :datetime
#  updated_at  :datetime
#  program_id  :integer
#
FactoryBot.define do
  factory :difficulty_level do
    title { 'Example Difficulty Level' }
    description { 'Lorem Ipsum dolsum' }
    color { '#ffffff' }
    program
  end
end
