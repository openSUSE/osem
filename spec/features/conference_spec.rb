# frozen_string_literal: true

require 'spec_helper'

feature Conference do
  let!(:user) { create(:admin) }
  let!(:organization) { create(:organization) }
  shared_examples 'add and update conference' do
    scenario 'adds a new conference', feature: true, js: true do
      expected_count = Conference.count + 1
      sign_in user

      visit new_admin_conference_path

      select organization.name, from: 'conference_organization_id'
      fill_in 'conference_title', with: 'Example Con'
      fill_in 'conference_short_title', with: 'ExCon'

      select('(GMT+01:00) Berlin', from: 'conference[timezone]')

      today = Time.zone.today - 1
      page
      .execute_script("$('#conference-start-datepicker').val('" +
                         "#{today.strftime('%d/%m/%Y')}')")
      page
      .execute_script("$('#conference-end-datepicker').val('" +
                         "#{(today + 7).strftime('%d/%m/%Y')}')")

      click_button 'Create Conference'

      expect(flash)
          .to eq('Conference was successfully created.')
      expect(Conference.count).to eq(expected_count)
      expect(Conference.last.organization).to eq(organization)
      user.reload
      expect(user.has_cached_role? :organizer, Conference.last).to eq(true)
    end

    scenario 'update conference', feature: true, js: true do
      conference = create(:conference)
      organizer_role = Role.find_by(name: 'organizer', resource: conference)
      organizer = create(:user, role_ids: [organizer_role.id])

      expected_count = Conference.count

      sign_in organizer
      visit edit_admin_conference_path(conference.short_title)

      fill_in 'conference_title', with: 'New Con'
      fill_in 'conference_short_title', with: ''

      click_button 'Update Conference'
      expect(flash)
          .to eq("Updating conference failed. Short title can't be blank.")

      fill_in 'conference_title', with: 'New Con'
      fill_in 'conference_short_title', with: 'NewCon'

      day = Time.zone.today + 10
      page
          .execute_script("$('#conference-start-datepicker').val('" +
                             "#{day.strftime('%d/%m/%Y')}')")
      page
          .execute_script("$('#conference-end-datepicker').val('" +
                             "#{(day + 7).strftime('%d/%m/%Y')}')")

      click_button 'Update Conference'
      expect(flash)
          .to eq('Conference was successfully updated.')

      conference.reload
      expect(conference.title).to eq('New Con')
      expect(conference.short_title).to eq('NewCon')
      expect(Conference.count).to eq(expected_count)
    end
  end

  describe 'admin' do
    let!(:conference) { create(:conference) }

    scenario 'has organization name in menu bar for conference views', feature: true, js: true do
      sign_in user
      visit admin_conference_path(conference.short_title)

      expect(find('.navbar-brand').text).to eq(conference.organization.name)
    end

    it_behaves_like 'add and update conference'
  end
end
