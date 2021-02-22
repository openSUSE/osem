# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id              :bigint           not null, primary key
#  description     :text
#  end_date        :datetime
#  start_date      :datetime
#  surveyable_type :string
#  target          :integer          default("after_conference")
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  surveyable_id   :integer
#
# Indexes
#
#  index_surveys_on_surveyable_type_and_surveyable_id  (surveyable_type,surveyable_id)
#
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
    it { expect(survey_active.active?).to eq true }
    it { expect(survey_inactive.active?).to eq false }
    it 'returns true, if both start_date and end_date are not set' do
      expect(create(:survey, start_date: nil, end_date: nil, surveyable: create(:conference)).active?).to eq true
    end
  end
end
