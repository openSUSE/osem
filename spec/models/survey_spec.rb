require 'spec_helper'

describe Survey do
  subject { create(:survey) }
  let(:survey_active) { create(:conference_survey, start_date: Date.current - 1.day, end_date: Date.current + 1.day) }
  let(:survey_inactive) { create(:conference_survey, start_date: Date.current - 2.day, end_date: Date.current - 1.day) }

  describe 'association' do
    it { is_expected.to have_many(:survey_questions) }
    it { is_expected.to have_many(:survey_submissions) }
  end

  describe 'validation' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe '#active?' do
    it { expect(survey_active.active?).to eq true }
    it { expect(survey_inactive.active?).to eq false }
    it 'returns false, if start_date is not set' do
      expect(create(:survey, start_date: nil, end_date: Date.current + 1.day).active?).to eq false
    end

    it 'returns false, if end_date is not set' do
      expect(create(:survey, start_date: Date.current + 1.day, end_date: nil).active?).to eq false
    end
  end
end
