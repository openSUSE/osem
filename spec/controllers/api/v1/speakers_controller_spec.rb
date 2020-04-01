# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::SpeakersController do
  let!(:conference) { create(:conference) }
  let!(:event) { create(:event_full) }
  let!(:conference_event) { create(:event_full, program: conference.program) }

  let(:speaker) { create(:user, name: 'Speaker') }
  let(:conference_speaker) { create(:user, name: 'Conf_Speaker') }

  describe 'GET #index' do
    before do
      event.speakers = [speaker]
      conference_event.speakers = [conference_speaker]
    end

    context 'without conference scope' do
      it 'returns all speakers' do

        get :index, params: { format: :json }
        json = JSON.parse(response.body)['speakers']
        expect(response).to be_success
        expect(json.pluck('name')).to contain_exactly('Conf_Speaker', 'Speaker')
      end
    end

    context 'with conference scope' do
      it 'returns all speakers of conference' do

        get :index, params: { conference_id: conference.short_title, format: :json }
        json = JSON.parse(response.body)['speakers']

        expect(response).to be_success

        expect(json.length).to eq(1)
        expect(json[0]['name']).to eq('Conf_Speaker')
      end
    end
  end
end
