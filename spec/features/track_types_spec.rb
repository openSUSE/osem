# frozen_string_literal: true

require 'spec_helper'

feature TrackType do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'track types' do
    scenario 'adds and updates track type', feature: true do

      sign_in organizer
      visit admin_conference_program_track_types_path(
                conference_id: conference.short_title)

      # Add event type
      click_link 'Add Track Type'

      fill_in 'track_type_title', with: '2 day devroom'
      fill_in 'track_type_description', with: 'Devroom that spans two days'

      click_button 'Create Track type'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Track type successfully created.')
      within('table#track-types') do
        expect(page.has_content?('2 day devroom')).to be true
        expect(page.has_content?('Devroom that spans two days')).to be true
        expect(page.assert_selector('tr', count: 1)).to be true
      end

      # Remove track type
      within('tr', text: '2 day devroom') do
        click_link 'Delete'
      end
      page.find('#flash')
      expect(flash).to eq('Track type successfully deleted.')

      within('table#track-types') do
        expect(page.assert_selector('tr', count: 0)).to be true
        expect(page.has_content?('2 day devroom')).to be false
      end
    end
  end

  describe 'organizer' do
    it_behaves_like 'track types'
  end
end
