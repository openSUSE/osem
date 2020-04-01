# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::TracksController do
  let!(:conference) { create(:conference) }
  let!(:conference_track) { create(:track, name: 'Conference Track', program_id: conference.program.id) }
  let!(:track) { create(:track, name: 'Test Track') }

  describe 'GET #index' do
    context 'without conference scope' do
      it 'returns all tracks' do

        get :index, params: { format: :json }
        json = JSON.parse(response.body)['tracks']

        expect(response).to be_success

        expect(json.pluck('name')).to contain_exactly('Conference Track', 'Test Track')
      end
    end

    context 'with conference scope' do
      it 'returns all rooms of conference' do

        get :index, params: { conference_id: conference.short_title, format: :json }
        json = JSON.parse(response.body)['tracks']

        expect(response).to be_success

        expect(json.length).to eq(1)
        expect(json[0]['name']).to eq('Conference Track')
      end
    end
  end
end
