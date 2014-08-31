require 'spec_helper'

describe ConferenceController do
  let(:conference) { create(:conference,  splashpage: create(:splashpage, public: true)) }

  describe 'GET #show' do
    context 'conference made public' do
      it 'assigns the requested conference to conference' do
        get :show, id: conference.short_title
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, id: conference.short_title
        expect(response).to render_template :show
      end
    end

    context 'gallery photos for splash' do
      it 'return conference photos' do
        xhr :get, :gallery_photos, id: conference.short_title
        expect(assigns(:photos)).to eq conference.photos
      end

      it 'renders photos template' do
        xhr :get, :gallery_photos, id: conference.short_title
       expect(response).to render_template :photos
      end
    end
  end
end
