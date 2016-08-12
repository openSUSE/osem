require 'spec_helper'

describe SchedulesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }

  describe 'GET #show' do
    context 'XML' do
      before :each do
        conference.program.schedule_public = true
        conference.program.save!
        create(:event_scheduled, program: conference.program)
        create(:event_scheduled, program: conference.program)

        get :show, conference_id: conference.short_title, format: :xml
      end

      it 'assigns variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:events_xml)).to eq conference.program.selected_event_schedules.map(&:event)
                                           .group_by{ |event| event.time.to_date }
      end

      it 'has 200 status code' do
        expect(response).to be_success
      end
    end
  end
end
