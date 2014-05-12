require 'spec_helper'

describe ConferenceController do

  describe 'GET #show' do
    it 'returns http success' do
      get :show, :id => 'sample'
      expect(response).to be_success
    end
  end

end
