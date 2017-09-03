require 'spec_helper'

feature Conference do
  let!(:organization) { create(:organization) }
  let!(:conference) { create(:conference, custom_domain: 'mydomain.conf', organization: organization) }
  let(:admin) { create(:admin) }
  let(:role_organization_admin) { Role.find_by(name: 'organization_admin', resource: organization) }
  let(:user_organization_admin) { create(:user, role_ids: [role_organization_admin.id]) }
  let(:role_organizer) { Role.find_by(name: 'organizer', resource: conference) }
  let(:user_organizer) { create(:user, role_ids: [role_organizer.id]) }
  let(:role_info_desk) { Role.find_by(name: 'info_desk', resource: conference) }
  let(:user_info_desk) { create(:user, role_ids: [role_info_desk.id]) }
  let(:role_cfp) { Role.find_by(name: 'cfp', resource: conference) }
  let(:user_cfp) { create(:user, role_ids: [role_cfp.id]) }

  shared_examples 'successfully adds, update or show custom domain' do
    scenario 'adds or update custom domain of a conference', feature: true, js: true do
      visit edit_admin_conference_domain_path(conference.short_title)

      fill_in 'conference_custom_domain', with: 'newdomain.conf'
      click_button 'Attach this domain'

      expect(flash).to eq 'Attached new domain name to conference. This does not mean that the new domain should work. Please make sure you follow step 3 to point your domain to this hosted version'
      expect(page).to have_text('newdomain.conf')
    end

    scenario 'show custom domain of a conference', feature: true, js: true do
      visit admin_conference_domain_path(conference.short_title)

      expect(page).to have_text('mydomain.conf')
    end
  end

  shared_examples 'does not add, update or show custom domain' do
    scenario 'does not add or update custom domain', feature: true, js: true do
      visit edit_admin_conference_domain_path(conference.short_title)

      expect(flash).to eq 'You are not authorized to access this page.'
    end

    scenario 'does not show custom domain of a conference', feature: true, js: true do
      visit admin_conference_domain_path(conference.short_title)

      expect(flash).to eq 'You are not authorized to access this page.'
    end
  end

  context 'signed in as admin' do
    before do
      sign_in admin
    end

    it_behaves_like 'successfully adds, update or show custom domain'
  end

  context 'signed in as organization admin' do
    before do
      sign_in user_organization_admin
    end

    it_behaves_like 'successfully adds, update or show custom domain'
  end

  context 'signed in as organizer' do
    before do
      sign_in user_organizer
    end

    it_behaves_like 'successfully adds, update or show custom domain'
  end

  context 'signed in as info_desk' do
    before do
      sign_in user_info_desk
    end

    it_behaves_like 'does not add, update or show custom domain'
  end

  context 'signed in as cfp' do
    before do
      sign_in user_cfp
    end

    it_behaves_like 'does not add, update or show custom domain'
  end
end
