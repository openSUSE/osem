require 'spec_helper'

feature Commercial do
  # It is necessary to use bang version of let to build roles before user
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }
  let!(:participant) { create(:user) }

  context 'in admin area' do
    scenario 'adds, updates, deletes of a conference', feature: true, js: true do
      expected_count = conference.commercials.count + 1

      sign_in organizer

      visit admin_conference_commercials_path(conference.short_title)
      click_link 'Add Commercial'

      # Create without an commercial id
      select('SlideShare', from: 'commercial_commercial_type')

      click_button 'Create Commercial'
      expect(flash).to eq("An error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(conference.commercials.count).to eq(expected_count - 1)

      # Create valid commercial
      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '12345'

      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(conference.commercials.count).to eq(expected_count)
      expect(page.has_content?('SlideShare')).to be true

      click_link 'Edit'

      # Update without an commercial id
      select('YouTube', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: ''

      click_button 'Update Commercial'
      expect(flash).to eq("An error prohibited this Commercial from being saved: Commercial can't be blank.")
      expect(conference.commercials.count).to eq(expected_count)

      # Update valid commercial
      select('YouTube', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '678910'

      click_button 'Update Commercial'
      expect(flash).to eq('Commercial was successfully updated.')
      expect(conference.commercials.count).to eq(expected_count)

      # Delete commercial
      click_link 'Delete'

      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(conference.commercials.count).to eq(expected_count - 1)
    end
  end

  context 'in public area' do
    let!(:event) { create(:event, conference: conference, title: 'Example Proposal') }

    before(:each) do
      event.event_users = [create(:event_user,
                                  user_id: participant.id,
                                  event_id: event.id,
                                  event_role: 'submitter')]

      @expected_count = Commercial.count + 1
      sign_in participant
    end

    after(:each) do
      sign_out
    end

    scenario 'adds a valid commercial to an event', feature: true, js: true do
      visit edit_conference_proposal_path(conference.short_title, event.id)

      click_link 'Commercials'
      click_link 'Add Commercial'

      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '12345'

      click_button 'Create Commercial'
      expect(flash).to eq('Commercial was successfully created.')
      expect(event.commercials.count).to eq(@expected_count)
    end

    scenario 'adds an invalid commercial to an event', feature: true, js: true do
      visit edit_conference_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      click_link 'Add Commercial'

      select('SlideShare', from: 'commercial_commercial_type')

      click_button 'Create Commercial'
      expect(event.commercials.count).to eq(@expected_count - 1)
    end

    scenario 'updates a valid commercial to an event', feature: true, js: true do
      create(:commercial,
             commercialable_id: event.id,
             commercialable_type: 'Event')
      visit edit_conference_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      click_link 'Edit'
      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: '56789'
      click_button 'Update Commercial'
      expect(flash).to eq('Commercial was successfully updated.')
      expect(event.commercials.count).to eq(@expected_count)
    end

    scenario 'updates a invalid commercial to an event', feature: true, js: true do
      create(:commercial,
             commercialable_id: event.id,
             commercialable_type: 'Event')
      visit edit_conference_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      click_link 'Edit'
      select('SlideShare', from: 'commercial_commercial_type')
      fill_in 'commercial_commercial_id', with: ''
      click_button 'Update Commercial'
      expect(event.commercials.count).to eq(@expected_count)
    end

    scenario 'deletes a commercial to an event', feature: true, js: true do
      create(:commercial,
             commercialable_id: event.id,
             commercialable_type: 'Event')
      visit edit_conference_proposal_path(conference.short_title, event.id)
      click_link 'Commercials'
      click_link 'Delete'
      page.driver.network_traffic
      expect(flash).to eq('Commercial was successfully destroyed.')
      expect(event.commercials.count).to eq(@expected_count - 1)
    end
  end
end
