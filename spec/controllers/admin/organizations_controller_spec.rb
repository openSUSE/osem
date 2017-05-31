require 'spec_helper'

describe Admin::OrganizationsController do
  let(:admin) { create(:admin) }

  describe 'GET #index' do
    before :each do
      sign_in admin
      get :index
    end

    it { expect(response).to render_template('index') }
  end
end
