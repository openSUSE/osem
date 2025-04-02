# frozen_string_literal: true

require 'spec_helper'

feature Role do
  let(:conference) { create(:conference) }
  let(:role_names) { Role.all.each.map(&:name) }

  shared_examples 'successfully edits' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario "role #{role_name}", feature: true, js: true do
      click_link('Edit', href: edit_admin_conference_role_path(conference.short_title, role_name))
      fill_in 'role_description', with: 'changed description'
      click_button 'Update Role'
      role.reload
      page.find('#flash')
      expect(flash).to eq("Successfully updated role #{role_name}")
      expect(role.description).to eq('changed description')
    end
  end

  shared_examples 'does not successfully edit' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }

    before(:each) do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end
    scenario "role #{role_name}" do
      expect(page.has_link?('Edit', href: edit_admin_conference_role_path(conference.short_title, role_name))).to be false
    end
  end

  shared_examples 'successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:user_with_role) { create(:user, role_ids: [role.id]) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }
    let!(:user_with_no_role) { create :user }

    before :each do
      sign_in user_to_sign_in
    end

    scenario "adds role #{role_name}", feature: true, js: true do
      visit admin_conference_role_path(conference.short_title, role_name)

      fill_in 'user_email', with: user_with_no_role.email
      click_button 'Add'

      within('table#users') do
        expect(page).to have_text(user_with_no_role.email)
      end
    end

    scenario "removes role #{role_name}", feature: true, js: true do
      visit admin_conference_role_path(conference.short_title, role_name)

      bootstrap_switch = find('tr', text: user_with_role.name).find('.bootstrap-switch-container')
      bootstrap_switch.click

      expect(page).to have_css('.alert', text: "Successfully removed role #{role_name} from user #{user_with_role.email}")
    end
  end

  shared_examples 'does not successfully' do |role_name, by_role_name|
    let!(:role) { Role.find_by(name: role_name, resource: conference) }
    let!(:user_with_role) { create(:user, role_ids: [role.id]) }
    let!(:by_role) { Role.find_by(name: by_role_name, resource: conference) }
    let!(:user_to_sign_in) { create(:user, role_ids: [by_role.id]) }
    let!(:user_with_no_role) { create :user }

    before :each do
      sign_in user_to_sign_in
      visit admin_conference_roles_path(conference.short_title)
    end

    scenario "add role #{role_name}", feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      expect(page.has_field?('user_email')).to be false
    end

    scenario "remove role #{role_name}", feature: true, js: true do
      click_link('Users', href: admin_conference_role_path(conference.short_title, role_name))

      expect(first('td').has_css?('.bootstrap-switch-container')).to be false
    end
  end

  context 'organizer' do
    Role.all.each.map(&:name).each do |role|
      it_behaves_like 'successfully', role, 'organizer'
      it_behaves_like 'successfully edits', role, 'organizer'
    end
  end

  context 'volunteers_coordinator' do
    it_behaves_like 'successfully', 'volunteers_coordinator', 'volunteers_coordinator'
    it_behaves_like 'does not successfully edit', 'volunteers_coordinator', 'volunteers_coordinator'

    Role.all.each.map(&:name).reject { |role| role == 'volunteers_coordinator' }.each do |role|
      it_behaves_like 'does not successfully', role, 'volunteers_coordinator'
      it_behaves_like 'does not successfully edit', role, 'volunteers_coordinator'
    end
  end

  context 'cfp' do
    it_behaves_like 'successfully', 'cfp', 'cfp'
    it_behaves_like 'does not successfully edit', 'cfp', 'cfp'

    Role.all.each.map(&:name).reject { |role| role == 'cfp' }.each do |role|
      it_behaves_like 'does not successfully', role, 'cfp'
      it_behaves_like 'does not successfully edit', role, 'cfp'
    end
  end

  context 'info_desk' do
    it_behaves_like 'successfully', 'info_desk', 'info_desk'
    it_behaves_like 'does not successfully edit', 'info_desk', 'info_desk'

    Role.all.each.map(&:name).reject { |role| role == 'info_desk' }.each do |role|
      it_behaves_like 'does not successfully', role, 'info_desk'
      it_behaves_like 'does not successfully edit', role, 'info_desk'
    end
  end
end
