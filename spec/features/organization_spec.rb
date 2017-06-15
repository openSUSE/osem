require 'spec_helper'

feature Organization do
  let!(:organization) { create(:organization) }
  let!(:organization_admin_role) { Role.find_by(name: 'organization_admin', resource: organization) }
  let(:organization_admin) { create(:user, role_ids: [organization_admin_role.id]) }
  let(:admin_user) { create(:admin) }

  shared_examples 'successfully updates a organization' do
    scenario 'updates a exsisting organization', feature: true, js: true do
      visit edit_admin_organization_path(organization)
      fill_in 'organization_name', with: 'changed name'

      click_button 'Update Organization'

      organization.reload
      expect(flash).to eq('Organization successfully updated')
      expect(organization.name).to eq('changed name')
    end
  end

  context 'signed in as site admin' do
    before do
      sign_in admin_user
    end
    scenario 'creates a new organization', feature: true, js: true do
      visit new_admin_organization_path
      fill_in 'organization_name', with: 'Organization name'

      click_button 'Create Organization'

      expect(flash).to eq('Organization successfully created')
      expect(Organization.last.name).to eq('Organization name')
    end

    it_behaves_like 'successfully updates a organization'
  end

  context 'signed in as organization admin' do
    before do
      sign_in organization_admin
    end
    scenario "can't create new organization", feature: true, js: true do
      visit new_admin_organization_path

      expect(flash).to eq('You are not authorized to access this page.')
    end

    it_behaves_like 'successfully updates a organization'
  end
end
