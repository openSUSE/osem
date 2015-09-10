require 'spec_helper'

describe Admin::QuestionsController do
  let!(:conference) { create(:conference) }
  let!(:question_with_answers) { create(:question_with_answers) }
  let!(:question_without_answers) { create(:question) }
  let(:organizer) { create(:organizer) }

  describe 'PATCH #update_conference' do
    before(:each) do
      sign_in(organizer)
    end

    it 'enables a question for a conference if the question has answers' do
      patch :toggle_question, conference_id: conference.short_title, id: question_with_answers, enable: 'true'

      conference.reload

      expect(conference.question_ids).to eq([question_with_answers.id])
      expect(conference.question_ids).to_not include([question_without_answers.id])

      expect(flash[:notice]).to eq("Questions for #{conference.short_title} successfully updated. Note: Only questions with answers can be enabled for a conference.")
      expect(response).to redirect_to admin_conference_questions_path(conference.short_title)
    end
  end
end
