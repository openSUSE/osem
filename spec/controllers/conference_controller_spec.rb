require 'spec_helper'

describe ConferenceController do
  let(:conference) { create(:conference,  splashpage: create(:splashpage, public: true), venue: create(:venue)) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let(:room) { create(:room, venue: conference.venue) }

  describe 'GET #index' do
    it 'Response code is 200' do
      get :index
      expect(response.response_code).to eq(200)
    end
  end

  describe 'GET #show' do
    context 'conference made public' do
      it 'assigns the requested conference to conference' do
        get :show, id: conference.short_title
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, id: conference.short_title
        expect(response).to render_template :show
      end
    end
  end

  describe 'GET #schedule' do
    context 'XML' do
      before :each do
        conference.program.schedule_public = true
        conference.program.save!
        create(:event_scheduled, program: conference.program)
        create(:event_scheduled, program: conference.program)

        get :schedule, id: conference.short_title, format: :xml
      end

      it 'assigns variables' do
        expect(assigns(:conference)).to eq conference
        expect(assigns(:events_xml)).to eq conference.program.events.scheduled.
                                           group_by{ |event| event.start_time.to_date }
      end

      it 'renders successfully' do
        expect(response).to be_success
      end
    end
  end

  describe 'OPTIONS #index' do
    it 'Response code is 200' do
      process :index, 'OPTIONS'
      expect(response.response_code).to eq(200)
    end
  end

end
