require 'spec_helper'

describe HomeController do
  let(:conference) { create(:conference) }
  describe 'GET #index' do
    it 'Response code is 200' do
      get :index
      expect(response.response_code).to eq(200)
    end

    it 'Assigns conference' do
      get :index
      expect(assigns(:current)).to eq [conference]
    end

    it 'Assigns only pending conferences' do
      create(:conference,
             end_date: Date.today - 7,
             start_date: Date.today - 14)
      get :index
      expect(assigns(:current)).to eq [conference]
    end

  end

  describe 'OPTIONS #index' do
    it 'Response code is 200' do
      process :index, 'OPTIONS'
      expect(response.response_code).to eq(200)
    end
  end
end
