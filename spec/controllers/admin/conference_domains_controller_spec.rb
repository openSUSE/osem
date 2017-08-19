require 'spec_helper'

describe Admin::ConferenceDomainsController do
  let!(:admin) { create(:admin) }
  let!(:conference) { create(:conference) }
  context 'as signed in admin' do
    before do
      sign_in admin
    end

    describe 'GET #show' do
      it 'redirects to edit if custom domain is not present' do
        get :show, conference_id: conference.short_title
        expect(response).to redirect_to(admin_conference_conference_domains_edit_path)
      end

      it 'renders correct template if custom domain is present' do
        conference.update_attribute(:custom_domain, 'mydomain.conf')
        get :show, conference_id: conference.short_title
        expect(response).to render_template('show')
      end
    end

    describe 'PATCH #update' do
      before do
        patch :update, conference_id: conference.short_title,
                       conference: { custom_domain: 'newdomain.conf' }
      end

      it 'successfully updates the custom domain' do
        expect(conference.reload.custom_domain).to eq('newdomain.conf')
      end
    end

    describe 'GET #edit' do
      it 'renders correct template' do
        get :edit, conference_id: conference.short_title
        expect(response).to render_template('edit')
      end
    end
  end
end
