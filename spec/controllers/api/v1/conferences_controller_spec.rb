# frozen_string_literal: true

require 'spec_helper'

describe Api::V1::ConferencesController do
  let!(:conf_one) { create(:conference, short_title: 'conf_one') }
  let!(:conf_two) { create(:conference, short_title: 'conf_two') }

  describe 'GET #index' do
    before(:each) do
      get :index, params: { format: :json }
      @json = JSON.parse(response.body)['conferences']
    end

    it 'returns successful response' do
      expect(response).to be_success
    end

    it 'returns all conferences' do
      expect(@json.length).to eq(2)
    end

    it 'returns correct conferences' do
      expect(@json.pluck('short_title')).to contain_exactly('conf_one', 'conf_two')
    end
  end

  describe 'GET #show' do
    before(:each) do
      get :show, params: { id: 'conf_two', format: :json }
      @json = JSON.parse(response.body)['conferences']
    end

    it 'returns successful response' do
      expect(response).to be_success
    end

    it 'returns only one conference' do
      expect(@json.length).to eq(1)
    end

    it 'returns the correct conference' do
      expect(@json[0]['short_title']).to eq('conf_two')
    end
  end
end
