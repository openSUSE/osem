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
require 'spec_helper'

describe SurveyQuestion do
  # subject needs to be of kind 'choice', so that optional validations also run
  # eg. numericality of min_choices and max_choices
  subject { create(:choice_mandatory_1_reply) }

  let(:single_choice_question) { create(:choice_mandatory_1_reply) }
  let(:multiple_choice_question) { create(:choice_mandatory_2_replies) }
  let(:boolean_question) { create(:boolean_question, min_choices: 3) }

  describe 'association' do
    it { is_expected.to belong_to(:survey) }
    it { is_expected.to have_many(:survey_replies) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_numericality_of(:min_choices).is_greater_than_or_equal_to(1) }
    it { is_expected.to validate_numericality_of(:max_choices).is_greater_than_or_equal_to(1) }

    it 'field presence, when of type choice?' do
      survey_question = build(:survey_question, kind: :choice)
      expect(survey_question).to validate_presence_of(:min_choices)
      expect(survey_question).to validate_presence_of(:max_choices)
      expect(survey_question).to validate_presence_of(:possible_answers)
    end

    it 'max_choices > min_choices' do
      survey_question = build(:survey_question, kind: :choice, min_choices: 3, max_choices: 2)
      expect(survey_question.valid?).to eq false
      expect(survey_question.errors[:max_choices]).to eq ['Max choices should not be less than min choices']
    end
  end

  describe '#multiple_choice?' do
    it 'returns false, when choice with 1 max_choice' do
      expect(single_choice_question.multiple_choice?).to eq false
    end

    it 'returns true, when choice with 2 max_choices' do
      expect(multiple_choice_question.multiple_choice?).to eq true
    end
  end

  describe '#single_choice?' do
    it 'returns true, when choice with 1 max_choice' do
      expect(single_choice_question.single_choice?).to eq true
    end

    it 'returns false, when choice with 2 max_choices' do
      expect(multiple_choice_question.single_choice?).to eq false
    end
  end

  describe 'min_choices value' do
    it 'nil, when boolean question' do
      boolean_question = create(:boolean_mandatory, min_choices: 3)
      expect(boolean_question.min_choices).to eq nil
    end

    it 'not nil, when choice question' do
      boolean_question = create(:survey_question, kind: :choice, possible_answers: 'Yes, No', min_choices: 3, max_choices: 4)
      expect(boolean_question.min_choices).to eq 3
    end
  end

  describe 'optional field' do
    it 'min_choices is set when question is choice' do
      question = create(:choice_mandatory_2_replies, min_choices: 2)
      expect(question.min_choices).to eq 2
    end

    it 'max_choices is set when question is choice' do
      question = create(:choice_mandatory_2_replies, max_choices: 2)
      expect(question.max_choices).to eq 2
    end

    it 'possible_answers is set when question is choice' do
      question = create(:choice_mandatory_2_replies, possible_answers: 'sth, sth else')
      expect(question.possible_answers).to eq 'sth, sth else'
    end

    shared_examples 'is nil' do |question_kind, field|
      scenario "when question is #{question_kind} and field is #{field}" do
        question = create(:survey_question, kind: question_kind.to_sym, field => 3)
        expect(question.send(field)).to eq nil
      end
    end

    fields = %w[min_choices max_choices possible_answers]
    (SurveyQuestion.kinds.keys - ['choice']).each do |kind|
      fields.each do |field|
        it_behaves_like 'is nil', kind, field
      end
    end
  end
end
