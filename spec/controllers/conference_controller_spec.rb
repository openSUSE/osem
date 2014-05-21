require 'spec_helper'

describe ConferenceController do
  let(:conference) { create(:conference_with_registration) }
  describe 'GET #show' do
    it 'returns http success' do
      get :show, id: conference.short_title
      expect(response).to be_success
    end
  end

end
