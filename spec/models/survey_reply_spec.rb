require 'spec_helper'

describe SurveyReply do
  subject { create(:survey_reply) }

  describe 'association' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:survey_question) }
  end

  describe 'validation' do
    it { is_expected.to validate_uniqueness_of(:survey_question_id).scoped_to(:user_id) }
  end
end
