require 'spec_helper'

feature Schedule do
  let!(:conference) { create(:conference) }
  let!(:program) { conference.program }

  context 'as a conference participant' do
    scenario 'who visits the schedule page' do
      before(:each) do
        visit vertical_schedule_conference_schedule_path
      end
    end
  end
end