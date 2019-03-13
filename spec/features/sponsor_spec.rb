# frozen_string_literal: true

require 'spec_helper'

feature Sponsor do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'sponsors' do
    scenario 'adds and updates sponsors', feature: true, js: true do
      path = "#{Rails.root}/app/assets/images/rails.png"

      conference.sponsorship_levels << create(:sponsorship_level, conference: conference)
      sign_in organizer

      visit admin_conference_sponsors_path(
                conference_id: conference.short_title)
      # Add sponsors
      click_link 'Add Sponsor'

      fill_in 'sponsor_name', with: 'SUSE'
      fill_in 'sponsor_description', with: 'The original provider of the enterprise Linux distribution'
      attach_file 'Picture', path
      fill_in 'sponsor_website_url', with: 'http://www.suse.com'
      select(conference.sponsorship_levels.first.title, from: 'sponsor_sponsorship_level_id')

      click_button 'Create Sponsor'
      page.find('#flash')
      expect(flash).to eq('Sponsor successfully created.')
      within('table#sponsors') do
        expect(page.has_content?('SUSE')).to be true
        expect(page.has_content?('The original provider')).to be true
        expect(page.has_content?('http://www.suse.com')).to be true
        expect(page.has_content?(conference.sponsorship_levels.first.title)).to be true
        expect(page).to have_selector("img[src*='rails.png']")
        expect(page.assert_selector('tr', count: 2)).to be true
      end

      # Remove sponsor
      visit admin_conference_sponsors_path(
        conference_id: conference.short_title
      )
      within('table#sponsors') do
        page.accept_confirm do
          click_link 'Delete'
        end
      end
      page.find('#flash')
      expect(flash).to eq('Sponsor successfully deleted.')
      expect(page).to_not have_selector('table#sponsors')
    end
  end

  describe 'organizer' do
    it_behaves_like 'sponsors'
  end
end
