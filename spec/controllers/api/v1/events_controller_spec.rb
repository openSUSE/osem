# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::EventsController do
  let!(:conference) { create(:conference) }
  let!(:event) { create(:event_full, state: 'confirmed', title: 'Example Event') }
  let!(:conference_event) { create(:event_full, state: 'confirmed', title: 'Conference Event', program: conference.program) }

  describe 'GET #index' do
    context 'without conference scope' do
      it 'returns all confirmed events' do

        get :index, params: { format: :json }
        json = JSON.parse(response.body)['events']
        expect(response).to be_successful

        expect(json.pluck('title')).to contain_exactly('Conference Event', 'Example Event')
      end
    end

    context 'with conference scope' do
      it 'returns all confirmed events of conference' do

        get :index, params: { conference_id: conference.short_title, format: :json }
        json = JSON.parse(response.body)['events']

        expect(response).to be_successful

        expect(json.length).to eq(1)
        expect(json[0]['title']).to eq('Conference Event')
      end
    end
  end
end
