require 'spec_helper'

feature Conference do

  shared_examples 'add and update conference' do |user|
    scenario 'adds a new conference', feature: true, js: true do
      expected_count = Conference.count + 1
      sign_in create(user)

      visit new_admin_conference_path
      fill_in 'conference_title', with: 'Example Con'
      fill_in 'conference_short_title', with: 'ExCon'
      fill_in 'conference_social_tag', with: 'ExCon'

      select('(GMT+01:00) Berlin', from: 'conference[timezone]')

      page.execute_script("$('#conference-start-datepicker').val('21/12/2014')")
      page.execute_script("$('#conference-end-datepicker').val('24/12/2014')")

      click_button 'Create Conference'

      expect(page.find('#flash_notice').text).
          to eq('Conference was successfully created.')
      expect(Conference.count).to eq(expected_count)
    end

    scenario 'update conference', feature: true, js: true do
      conference = create(:conference)
      expected_count = Conference.count
      sign_in create(user)

      visit admin_conference_path(conference.short_title)
      fill_in 'conference_title', with: 'New Con'
      fill_in 'conference_short_title', with: 'NewCon'
      fill_in 'conference_social_tag', with: 'NewCon'

      click_button 'Update Conference'
      expect(page.find('#flash_notice').text).
          to eq('Conference was successfully updated.')

      conference.reload
      expect(conference.title).to eq('New Con')
      expect(conference.short_title).to eq('NewCon')
      expect(conference.social_tag).to eq('NewCon')
      expect(Conference.count).to eq(expected_count)
    end
  end

  shared_examples 'venue' do |user|
    scenario 'adds and updates venue' do
      conference = create(:conference)

      sign_in create(user)
      visit  admin_conference_venue_info_path(conference_id: conference.short_title)

      expect(page.find("//*[@id='venue_submit_action']").text).to eq('Update Venue')

      fill_in 'venue_name', with: 'Example University'
      fill_in 'venue_address', with: 'Example Street 42 \n 12345 Example City \n Germany'
      fill_in 'venue_website', with: 'www.example.com'
      fill_in 'venue_description',
              with: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam' \
                      'nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,' \
                      'sed diam voluptua.'

      click_button 'Update Venue'

      expect(page.find('#flash_notice').text).
          to eq('Venue was successfully updated.')

      venue = Conference.find(conference.id).venue
      expect(venue.name).to eq('Example University')
      expect(venue.address).to eq('Example Street 42 \n 12345 Example City \n Germany')
      expect(venue.website).to eq('www.example.com')
      expect(venue.description).to eq('Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam' \
                      'nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,' \
                      'sed diam voluptua.')

      fill_in 'venue_name', with: 'Example University new'
      fill_in 'venue_address', with: 'Example Street 42 \n 12345 Example City \n Germany new'
      fill_in 'venue_website', with: 'www.example.com new'
      fill_in 'venue_description',
              with: 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam' \
                      'nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,' \
                      'sed diam voluptua. new'

      click_button 'Update Venue'
      expect(page.find('#flash_notice').text).
          to eq('Venue was successfully updated.')

      venue.reload
      expect(venue.name).to eq('Example University new')
      expect(venue.address).to eq('Example Street 42 \n 12345 Example City \n Germany new')
      expect(venue.website).to eq('www.example.com new')
      expect(venue.description).to eq('Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam' \
                      'nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,' \
                      'sed diam voluptua. new')
    end
  end

  describe 'admin' do
    it_behaves_like 'add and update conference', :admin
    it_behaves_like 'venue', :admin
  end

  describe 'organizer' do
    it_behaves_like 'add and update conference', :organizer
    it_behaves_like 'venue', :organizer
  end

end
