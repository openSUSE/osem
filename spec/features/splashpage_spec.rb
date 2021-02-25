# frozen_string_literal: true

require 'spec_helper'

feature Splashpage do

  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let!(:participant) { create(:user, biography: '', is_admin: false) }

  scenario 'create a valid splashpage', js: true do
    sign_in organizer
    visit admin_conference_splashpage_path(conference.short_title)

    click_link 'Create Splashpage'
    click_button 'Save Changes'
    page.find('#flash')
    expect(flash).to eq('Splashpage successfully created.')
    expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
    expect(page.has_text?('Private')).to be true
  end

  context 'splashpage already created' do
    let!(:splashpage) { create(:splashpage, conference: conference, public: false)}

    scenario 'update a valid splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)

      click_link 'Edit'
      check('Make splash page public')
      click_button 'Save Changes'
      page.find('#flash')
      expect(flash).to eq('Splashpage successfully updated.')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
      expect(page.has_text?('Public')).to be true

      click_link 'Edit'
      expect(page.has_checked_field?('Make splash page public?')).to be true
    end

    scenario 'delete the splashpage', js: true do
      sign_in organizer
      visit admin_conference_splashpage_path(conference.short_title)
      click_link 'Delete'
      page.accept_alert
      page.find('#flash')
      expect(current_path).to eq(admin_conference_splashpage_path(conference.short_title))
      expect(flash).to eq('Splashpage was successfully destroyed.')
      expect(Splashpage.count).to eq(0)
    end

    scenario 'splashpage is accessible for organizers if it is not public' do
      sign_in organizer
      visit conference_path(conference.short_title)
      expect(current_path).to eq(conference_path(conference.short_title))
    end

    scenario 'splashpage is not accessible for participants if it is not public' do
      sign_in participant
      visit conference_path(conference.short_title)
      page.find('#flash')
      expect(flash).to eq('You are not authorized to access this page.')
      expect(current_path).to eq(root_path)
    end
  end

  context 'navigation' do
    let!(:splashpage) { create(:splashpage, conference: conference, public: true)}

    context 'multiple organizations' do
      let!(:additional_organization) { create(:organization) }

      scenario 'should have organization logo', feature: true, js: true do
        sign_in participant
        visit conference_path(conference.short_title)

        expect(find('.navbar-brand img')['alt']).to have_content conference.organization.name
      end
    end
  end
end
