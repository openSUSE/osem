# frozen_string_literal: true

require 'spec_helper'

describe Survey do
  subject { create(:survey) }
  let(:survey_active) { create(:conference_survey, start_date: Date.current - 1.day, end_date: Date.current + 1.day) }
  let(:survey_inactive) { create(:conference_survey, start_date: Date.current - 2.days, end_date: Date.current - 1.day) }

  describe 'association' do
    it { is_expected.to have_many(:survey_questions) }
    it { is_expected.to have_many(:survey_submissions) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#active?' do
    it { expect(survey_active.active?).to be true }
    it { expect(survey_inactive.active?).to be false }
    it 'returns true, if both start_date and end_date are not set' do
      expect(create(:survey, start_date: nil, end_date: nil, surveyable: create(:conference)).active?).to be true
    end
  end
end
