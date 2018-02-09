# frozen_string_literal: true

require 'spec_helper'

describe SurveySubmission do
  subject { create(:survey_submission) }

  describe 'association' do
    it { is_expected.to belong_to(:survey) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:survey_replies).through(:user) }
    it { is_expected.to accept_nested_attributes_for(:survey_replies) }
  end

  describe 'validation' do
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:survey_id) }
  end
end
