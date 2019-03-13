# frozen_string_literal: true

require 'spec_helper'

feature Conference do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'venue' do
    scenario 'adds and updates venue' do

      sign_in organizer

      # create the venue
      visit admin_conference_venue_path(
                conference_id: conference.short_title)
      click_link 'Create Venue'
      fill_in 'venue_name', with: 'Example University'
      fill_in 'venue_street', with: 'Example Street 42'
      fill_in 'venue_city', with: 'Example City'
      fill_in 'venue_postalcode', with: '12345'
      select  'Germany', from: 'venue_country'
      fill_in 'venue_website', with: 'www.example.com'
      fill_in 'venue_description',
              with: 'Lorem ipsum dolor sit amet, consetetur' \
              'sadipscing elitr, sed diam nonumy eirmod tempor'
      click_button 'Create Venue'
      page.find('#flash')
      expect(flash)
          .to eq('Venue was successfully created.')
      venue = Conference.find(conference.id).venue
      expect(venue.name).to eq('Example University')
      expect(venue.street).to eq('Example Street 42')
      expect(venue.website).to eq('www.example.com')
      expect(venue.description).to eq('Lorem ipsum dolor sit amet, consetetur' \
              'sadipscing elitr, sed diam nonumy eirmod tempor')

      # edit the venue
      click_link 'Edit Venue'
      expect(page.find("//*[@id='venue_submit_action']")
                 .text).to eq('Update Venue')
      fill_in 'venue_name', with: 'Example University new'
      fill_in 'venue_website', with: 'www.example.com new'
      fill_in 'venue_description', with: 'new'
      click_button 'Update Venue'
      page.find('#flash')
      expect(flash)
          .to eq('Venue was successfully updated.')
      venue.reload
      expect(venue.name).to eq('Example University new')
      expect(venue.website).to eq('www.example.com new')
      expect(venue.description).to eq('new')
    end
  end

  describe 'organizer' do
    it_behaves_like 'venue'
  end

end
