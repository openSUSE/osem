# frozen_string_literal: true

require 'spec_helper'

feature SponsorshipLevel do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'sponsorship_levels' do
    scenario 'adds a sponsorship level', feature: true, js: true do
      sign_in organizer
      visit admin_conference_sponsorship_levels_path(
                conference_id: conference.short_title)

      expect(page.has_no_table?('#sponsorship_levels')).to be true

      # Add SponsorshipLevel
      click_link 'New Sponsorship Level'

      fill_in 'sponsorship_level_title', with: 'Platin'

      click_button 'Create Sponsorship level'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Sponsorship level successfully created.')
      within('table#sponsorship_levels') do
        expect(page.has_content?('Platin')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
    end

    scenario 'updates a sponsorship level', feature: true, js: true do
      level = create(:sponsorship_level, conference_id: conference.id)
      sign_in organizer
      visit edit_admin_conference_sponsorship_level_path(
                conference_id: conference.short_title, id: level.id)

      fill_in 'sponsorship_level_title', with: 'Gold'

      click_button 'Update Sponsorship level'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Sponsorship level successfully updated.')
      within('table#sponsorship_levels') do
        expect(page.has_content?('Gold')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
      level.reload
      expect(level.title).to eq('Gold')
    end
  end

  describe 'organizer' do
    it_behaves_like 'sponsorship_levels'
  end
end
