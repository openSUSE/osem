require 'spec_helper'

describe ConferenceController do
  let(:conference) { create(:conference) }
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
    context 'conference is not public' do
      it 'raises routing error' do
        # rendered as 404 NOT FOUND in production environment
        conference.update_attribute(:make_conference_public, false)
        expect { get :show, id: conference.short_title }.
            to raise_error(ActionController::RoutingError)
      end
    end
  end
end
