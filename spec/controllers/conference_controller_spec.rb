require 'spec_helper'

describe ConferenceController do
  let(:conference) { create(:conference) }
  describe 'GET #show' do
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
