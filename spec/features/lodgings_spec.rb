require 'spec_helper'

feature Lodging do
  # It is necessary to use bang version of let to build roles before user
  let!(:organizer_role) { create(:organizer_role) }
  let!(:participant_role) { create(:participant_role) }
  let!(:admin_role) { create(:admin_role) }

  shared_examples 'lodgings' do |user|
    scenario 'adds and updates lodgings', feature: true, js: true do
      expected_count = Lodging.count + 1
      conference = create(:conference)
      conference.venue = create(:venue)
      sign_in create(user)

      visit admin_conference_lodgings_path(
                conference_id: conference.short_title)

      # Add lodging
      click_link 'New Lodging'
      fill_in 'lodging_name', with: 'Lodging1000'
      fill_in 'lodging_description', with: 'Lorem ipsum dolorem'
      attach_file('lodging_photo', Rails.root + 'spec/fixtures/suse.jpg')
      fill_in 'lodging_website_link', with: 'http://www.suse.com'
      click_button 'Save Lodging'

      # Validations
      expect(Lodging.count).to eq(expected_count)
      expect(flash).to eq('Lodging was successfully created.')
      expect(page.has_content?('Lodging1000')).to be true
      expect(page.has_content?('Lorem ipsum dolorem')).to be true
      expect(page.has_content?('http://www.suse.com')).to be true

      # Update room
      click_link 'Edit'
      fill_in 'lodging_name', with: 'Lodging2000'
      fill_in 'lodging_description', with: 'Lorem ipsum dolorem...'
      attach_file('lodging_photo', Rails.root + 'spec/fixtures/suse_pinguin.png')
      fill_in 'lodging_website_link', with: 'http://www.opensuse.com'
      click_button 'Save Lodging'

      # Validations
      expect(Lodging.count).to eq(expected_count)
      expect(flash).to eq('Lodging was successfully updated.')
      expect(page.has_content?('Lodging2000')).to be true
      expect(page.has_content?('Lorem ipsum dolorem...')).to be true
      expect(page.has_content?('http://www.opensuse.com')).to be true

      # Remove room
      click_link 'Delete'

      # Validations
      expect(Lodging.count).to eq(expected_count - 1)
      expect(flash).to eq('Lodging was successfully destroyed.')
      expect(page.has_content?('Lodging2000')).to be false
      expect(page.has_content?('Lorem ipsum dolorem...')).to be false
      expect(page.has_content?('http://www.opensuse.com')).to be false

      # Enable lodgings for splash page
      check('venue_include_lodgings_in_splash')
      click_button 'Update Venue'
      expect(flash).to eq('Venue was successfully updated.')
    end
  end

  describe 'admin' do
    it_behaves_like 'lodgings', :admin
  end

  describe 'organizer' do
    it_behaves_like 'lodgings', :organizer
  end
end
