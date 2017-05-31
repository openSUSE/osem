require 'spec_helper'

describe OrganizationsController do
  let!(:organization) { create(:organization) }
  let!(:admin) { create(:admin, is_admin: true) }

  describe 'GET #new' do
    before :each do
      sign_in admin
      get :new
    end

    it { expect(response).to render_template('new') }
  end

  describe 'GET #index' do
    before :each do
      sign_in admin
      get :index
    end

    it { expect(response).to render_template('index') }
  end

  describe 'POST #create' do
    before :each do
      sign_in admin
    end
    context 'with valid attributes' do
      it 'creates new organization' do
        expected = expect do
          post :create, organization: attributes_for(:organization)
        end
        expected.to change { Organization.count }.by(1)
      end

      it 'redirects to index' do
        post :create, organization: attributes_for(:organization)

        expect(flash[:notice]).to eq('Organization successfully created')
        expect(response).to redirect_to(organizations_path)
      end
    end

    context 'with invalid attributes' do
      it 'does not create new organization' do
        expected = expect do
          post :create, organization: attributes_for(:organization, name: '')
        end
        expected.to_not change { Organization.count }
      end

      it 'redirects to new' do
        post :create, organization: attributes_for(:organization, name: '')

        expect(flash[:error]).to eq("Name can't be blank")
        expect(response).to redirect_to(new_organization_path)
      end
    end
  end

  describe 'PATCH #update' do
    before :each do
      sign_in admin
    end

    it 'saves and redirects to index when the attributes are valid' do
      patch :update, id: organization.id, organization: attributes_for(:organization, name: 'changed name')

      expect(organization.name).to eq('changed name')
      expect(flash).to eq('Organization successfully updated')
      expect(response).to redirect_to(organizations_path)
    end

    it 'redirects to edit when attributes are invalid' do
      patch :update, id: organization.id, organization: attributes_for(:organization, name: '')

      expect(flash[:error]).to eq("Name can't be blank")
      expect(response).to redirect_to(edit_organization_path(organization))
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      sign_in admin
    end

    context 'for a valid organization' do
      it 'should successfully destroy a resource' do
        expected = expect do
          delete :destroy, id: organization.id
        end
        expected.to change { Organization.count }.by(-1)
      end

      it 'redirects to index' do
        delete :destroy, id: organization.id

        expect(flash[:notice]).to eq('Organization successfully destroyed')
        expect(response).to redirect_to(organizations_path)
      end
    end
  end
end
