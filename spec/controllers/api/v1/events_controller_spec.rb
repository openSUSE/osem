require 'spec_helper'

describe Api::V1::EventsController do
  let!(:conference) { create(:conference) }
  let!(:event) { create(:event_full, state: 'confirmed', title: 'Example Event') }
  let!(:conference_event) { create(:event_full, state: 'confirmed', title: 'Conference Event', program: conference.program) }

  describe 'GET #index' do
    context 'without conference scope' do
      it 'returns all confirmed events' do

        get :index, format: :json
        json = JSON.parse(response.body)['events']
        expect(response).to be_success

        expect(json.length).to eq(2)
        expect(json[0]['title']).to eq('Example Event')
        expect(json[1]['title']).to eq('Conference Event')
      end
    end

    context 'with conference scope' do
      it 'returns all confirmed events of conference' do

        get :index, conference_id: conference.short_title, format: :json
        json = JSON.parse(response.body)['events']

        expect(response).to be_success

        expect(json.length).to eq(1)
        expect(json[0]['title']).to eq('Conference Event')
      end
    end
  end
end
