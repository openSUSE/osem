# frozen_string_literal: true

require 'spec_helper'

describe Admin::OrganizationsController do
  let!(:admin) { create(:admin) }
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user) }

  context 'logged in as user with no role' do
    before :each do
      sign_in user
    end

    describe 'GET #new' do
      before :each do
        get :new
      end

      it 'redirects to root' do
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'GET #index' do
      before :each do
        get :index
      end

      it 'redirects to root' do
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'POST #create' do
      it 'does not create new organization' do
        expected = expect do
          post :create, params: { organization: attributes_for(:organization) }
        end
        expected.to_not change(Organization, :count)
      end

      it 'redirects to root' do
        post :create, params: { organization: attributes_for(:organization) }

        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'PATCH #update' do
      it 'does not update and redirects to root' do
        old_name = organization.name
        patch :update, params: { id: organization.id, organization: attributes_for(:organization, name: 'new name') }

        organization.reload
        expect(organization.name).to eq(old_name)
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'DELETE #destroy' do
      context 'for a valid organization' do
        it 'does not destroy a resource' do
          expected = expect do
            delete :destroy, params: { id: organization.id }
          end
          expected.to_not change(Organization, :count)
        end

        it 'redirects to root' do
          delete :destroy, params: { id: organization.id }

          expect(flash[:alert]).to eq('You are not authorized to access this page.')
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end

  context 'logged in as admin' do
    before :each do
      sign_in admin
    end

    describe 'GET #new' do
      before do
        get :new
      end
      it { expect(response).to render_template('new') }
    end

    describe 'GET #index' do
      before do
        get :index
      end
      it { expect(response).to render_template('index') }
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'creates new organization' do
          expected = expect do
            post :create, params: { organization: attributes_for(:organization) }
          end
          expected.to change { Organization.count }.by(1)
        end

        it 'redirects to index' do
          post :create, params: { organization: attributes_for(:organization) }

          expect(flash[:notice]).to eq('Organization successfully created')
          expect(response).to redirect_to(admin_organizations_path)
        end
      end

      context 'with invalid attributes' do
        it 'does not create new organization' do
          expected = expect do
            post :create, params: { organization: attributes_for(:organization, name: '') }
          end
          expected.to_not change(Organization, :count)
        end

        it 'redirects to new' do
          post :create, params: { organization: attributes_for(:organization, name: '') }

          expect(flash[:error]).to eq("Name can't be blank")
          expect(response).to redirect_to(new_admin_organization_path)
        end
      end
    end

    describe 'PATCH #update' do
      it 'saves and redirects to index when the attributes are valid' do
        patch :update, params: { id: organization.id, organization: attributes_for(:organization, name: 'changed name') }

        organization.reload
        expect(organization.name).to eq('changed name')
        expect(flash[:notice]).to eq('Organization successfully updated')
        expect(response).to redirect_to(admin_organizations_path)
      end

      it 'redirects to edit when attributes are invalid' do
        patch :update, params: { id: organization.id, organization: attributes_for(:organization, name: '') }

        expect(flash[:error]).to eq("Name can't be blank")
        expect(response).to redirect_to(edit_admin_organization_path(organization))
      end
    end

    describe 'DELETE #destroy' do
      context 'for a valid organization' do
        it 'should successfully destroy a resource' do
          expected = expect do
            delete :destroy, params: { id: organization.id }
          end
          expected.to change { Organization.count }.by(-1)
        end

        it 'redirects to index' do
          delete :destroy, params: { id: organization.id }

          expect(flash[:notice]).to eq('Organization successfully destroyed')
          expect(response).to redirect_to(admin_organizations_path)
        end
      end
    end

    describe 'POST #assign_org_admins' do
      let(:org_admin_role) { Role.find_by(name: 'organization_admin', resource: organization) }

      before do
        post :assign_org_admins, params: { id:   organization.id,
                                           user: { email: user.email } }
      end

      it 'assigns organization_admin role' do
        expect(user.roles).to eq [org_admin_role]
      end
    end

    describe 'DELETE #unassign_org_admins' do
      let(:org_admin_role) { Role.find_by(name: 'organization_admin', resource: organization) }
      let!(:org_admin_user) { create(:user, role_ids: [org_admin_role.id]) }

      before do
        delete :unassign_org_admins, params: { id:   organization.id,
                                               user: { email: org_admin_user.email } }
      end

      it 'unassigns organization_admin role' do
        expect(org_admin_user.reload.roles).to eq []
      end
    end
  end
end
