# frozen_string_literal: true

# == Schema Information
#
# Table name: survey_questions
#
#  id               :bigint           not null, primary key
#  kind             :integer          default("boolean")
#  mandatory        :boolean          default(FALSE)
#  max_choices      :integer
#  min_choices      :integer
#  possible_answers :text
#  title            :string
#  survey_id        :integer
#
FactoryBot.define do
  factory :survey_question do
    survey
    title { 'What about this question?' }
    kind { :boolean }
    min_choices { nil }
    max_choices { nil }
    possible_answers { nil }

    factory :boolean_non_mandatory do
      title { 'Have you attended the conference before? (Non mandatory)' }
      kind { :boolean }
    end

    factory :boolean_mandatory do
      title { 'Did you attend the info talk about the conference? (Mandatory)' }
      kind { :boolean }
      mandatory { true }
    end

    # radio buttons
    factory :choice_mandatory_1_reply do
      title { 'Choice question with only 1 answer (Mandatory)?' }
      kind { :choice }
      min_choices { 1 }
      max_choices { 1 }
      possible_answers { 'A, B, C' }
      mandatory { true }
    end

    factory :choice_non_mandatory_1_reply do
      title { 'Choice question with only 1 answer (Non mandatory)' }
      kind { :choice }
      min_choices { 1 }
      max_choices { 1 }
      possible_answers { 'A, B, C' }
    end

    # checkboxes
    factory :choice_mandatory_2_replies do
      title { 'Choice question with 2 replies (Mandatory)?' }
      kind { :choice }
      min_choices { 2 }
      max_choices { 2 }
      possible_answers { 'A, B, C' }
      mandatory { true }
    end

    # checkboxes
    factory :choice_non_mandatory_2_replies do
      title { 'Choice question with 2 replies (Non mandatory)?' }
      kind { :choice }
      min_choices { 2 }
      max_choices { 2 }
      possible_answers { 'A, B, C' }
    end

    factory :string_mandatory do
      title { 'String question (Mandatory)?' }
      kind { :string }
      mandatory { true }
    end

    factory :string_non_mandatory do
      title { 'String question (Non mandatory)?' }
      kind { :string }
    end

    factory :text_mandatory do
      title { 'Text question (Mandatory)?' }
      kind { :text }
      mandatory { true }
    end

    factory :text_non_mandatory do
      title { 'Text question (Non mandatory)?' }
      kind { :text }
    end

    factory :datetime_mandatory do
      title { 'Datetime question (Mandatory)?' }
      kind { :datetime }
      mandatory { true }
    end

    factory :datetime_non_mandatory do
      title { 'Datetime question (Non mandatory)?' }
      kind { :datetime }
    end

    factory :numeric_mandatory do
      title { 'Numeric question (Mandatory)?' }
      kind { :numeric }
      mandatory { true }
    end

    factory :numeric_non_mandatory do
      title { 'Numeric question (Non mandatory)?' }
      kind { :numeric }
    end
  end
end
