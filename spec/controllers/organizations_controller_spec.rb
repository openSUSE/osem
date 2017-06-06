require 'spec_helper'

describe OrganizationsController do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user) }

  describe 'GET #index' do
    before :each do
      sign_in user
      get :index
    end

    it { expect(response).to render_template('index') }
  end
end
