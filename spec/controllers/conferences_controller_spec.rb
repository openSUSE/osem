require 'spec_helper'

describe ConferencesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let(:room) { create(:room, venue: conference.venue) }

  describe 'GET #index' do
    context 'without conference' do
      it 'Response code is 200' do
        conference.destroy!
        get :index
        expect(response.response_code).to eq(200)
      end
    end

    context 'with one next conference' do
      describe 'with splashpage' do
        it 'Response code is 200 when is not public' do
          current = Conference.first
          current.splashpage.public = false
          current.splashpage.save
          get :index
          expect(response.response_code).to eq(200)
        end
        it 'Response code is 302 when is public' do
          get :index
          expect(response.response_code).to eq(302)
        end
        it 'Redirect to conference#show' do
          get :index
          expect(response).to redirect_to(conference_path(conference))
        end
      end
      describe 'without splashpage' do
        it 'Response code is 200' do
          conference.splashpage.destroy!
          get :index
          expect(response.response_code).to eq(200)
        end
      end
    end
  end

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

    context 'accessing conference via custom domain' do
      before do
        conference.update_attribute(:custom_domain, 'lvh.me')
        @request.host = 'lvh.me'
      end

      it 'assigns correct conference' do
        get :show

        expect(response).to render_template :show
        expect(assigns(:conference)).to eq conference
      end
    end
  end

  describe 'OPTIONS #index' do
    it 'Response code is 200' do
      process :index, 'OPTIONS'
      expect(response.response_code).to eq(200)
    end
  end

end
