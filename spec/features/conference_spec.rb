require 'spec_helper'

feature Conference do

  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_conference_1_role) { create(:organizer_conference_1_role) }

  shared_examples 'add and update conference' do |user|
    scenario 'adds a new conference', feature: true, js: true do
      expected_count = Conference.count + 1
      sign_in create(user)

      visit new_admin_conference_path
      fill_in 'conference_title', with: 'Example Con'
      fill_in 'conference_short_title', with: 'ExCon'
      fill_in 'conference_social_tag', with: 'ExCon'

      select('(GMT+01:00) Berlin', from: 'conference[timezone]')

      today = Date.today - 1
      page.
      execute_script("$('#conference-start-datepicker').val('" +
                         "#{today.strftime('%d/%m/%Y')}')")
      page.
      execute_script("$('#conference-end-datepicker').val('" +
                         "#{(today + 7).strftime('%d/%m/%Y')}')")

      click_button 'Create Conference'

      expect(flash).
          to eq('Conference was successfully created.')
      expect(Conference.count).to eq(expected_count)
    end

    scenario 'update conference', feature: true, js: true do
      conference = create(:conference)
      expected_count = Conference.count
      sign_in create(:organizer_conference_1_role)

      visit edit_admin_conference_path(conference.short_title)
      fill_in 'conference_title', with: 'New Con'
      fill_in 'conference_short_title', with: 'NewCon'
      fill_in 'conference_social_tag', with: 'NewCon'

      click_button 'Update Conference'
      expect(flash).
          to eq('Conference was successfully updated.')

      conference.reload
      expect(conference.title).to eq('New Con')
      expect(conference.short_title).to eq('NewCon')
      expect(conference.social_tag).to eq('NewCon')
      expect(Conference.count).to eq(expected_count)
    end
  end

  describe 'organizer' do
    it_behaves_like 'add and update conference', :admin
  end
end
