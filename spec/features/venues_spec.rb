require 'spec_helper'

feature Conference do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'venue' do
    scenario 'adds and updates venue' do

      sign_in organizer

      visit edit_admin_conference_venue_path(
                conference_id: conference.short_title)

      expect(page.find("//*[@id='venue_submit_action']").
                 text).to eq('Update Venue')

      fill_in 'venue_name', with: 'Example University'
      fill_in 'venue_address', with: 'Example Street 42 \n' +
          '12345 Example City \n Germany'
      fill_in 'venue_website', with: 'www.example.com'
      fill_in 'venue_description',
              with: 'Lorem ipsum dolor sit amet, consetetur' \
              'sadipscing elitr, sed diam nonumy eirmod tempor'

      click_button 'Update Venue'

      expect(flash).
          to eq('Venue was successfully updated.')

      venue = Conference.find(conference.id).venue
      expect(venue.name).to eq('Example University')
      expect(venue.address).to eq('Example Street 42 \n' \
      '12345 Example City \n Germany')
      expect(venue.website).to eq('www.example.com')
      expect(venue.description).to eq('Lorem ipsum dolor sit amet, consetetur' \
              'sadipscing elitr, sed diam nonumy eirmod tempor')

      fill_in 'venue_name', with: 'Example University new'
      fill_in 'venue_address', with: 'Example Street 42 \n ' \
      '12345 Example City \n Germany new'
      fill_in 'venue_website', with: 'www.example.com new'
      fill_in 'venue_description',
              with: 'new'

      click_button 'Update Venue'
      expect(flash).
          to eq('Venue was successfully updated.')

      venue.reload
      expect(venue.name).to eq('Example University new')
      expect(venue.address).to eq('Example Street 42 \n ' \
      '12345 Example City \n Germany new')
      expect(venue.website).to eq('www.example.com new')
      expect(venue.description).to eq('new')
    end
  end

  describe 'organizer' do
    it_behaves_like 'venue'
  end

end
