# frozen_string_literal: true

# == Schema Information
#
# Table name: event_types
#
#  id                      :bigint           not null, primary key
#  color                   :string
#  description             :string
#  length                  :integer          default(30)
#  maximum_abstract_length :integer          default(500)
#  minimum_abstract_length :integer          default(0)
#  submission_instructions :text
#  title                   :string           not null
#  created_at              :datetime
#  updated_at              :datetime
#  program_id              :integer
#

FactoryBot.define do
  factory :event_type do
    title { 'Example Event Type' }
    length { 30 }
    minimum_abstract_length { 0 }
    maximum_abstract_length { 500 }
    description { 'Example Event Description' }
    submission_instructions { 'Example Event Instructions' }
    color { '#ffffff' }
    program
  end

end
