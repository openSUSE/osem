require 'spec_helper'

feature Schedule do
  let!(:conference) { create(:conference) }
  let!(:program) { conference.program }

  context 'as a conference participant' do
    context 'who visits the schedule page' do
      before(:each) do
        visit vertical_schedule_conference_schedule_path
      end

      it 'returns a successful response' do
        expect(response.status).to eq(200)
      end
    end
  end
end
