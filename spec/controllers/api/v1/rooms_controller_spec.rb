require 'spec_helper'

describe Api::V1::RoomsController do
  let!(:conference) { create(:conference) }
  let!(:venue) { create(:venue, conference: conference) }
  let!(:conference_room) { create(:room, name: 'Conference Room', venue: venue) }
  let!(:room) { create(:room, name: 'Test Room') }

  describe 'GET #index' do
    context 'without conference scope' do
      it 'returns all rooms' do

        get :index, format: :json
        json = JSON.parse(response.body)['rooms']

        expect(response).to be_success

        expect(json.length).to eq(2)
        expect(json[0]['name']).to eq('Conference Room')
        expect(json[1]['name']).to eq('Test Room')
      end
    end

    context 'with conference scope' do
      it 'returns all rooms of conference' do

        get :index, conference_id: conference.short_title, format: :json
        json = JSON.parse(response.body)['rooms']

        expect(response).to be_success

        expect(json.length).to eq(1)
        expect(json[0]['name']).to eq('Conference Room')
      end
    end
  end
end
