# frozen_string_literal: true

require 'spec_helper'

feature EventType do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'event types' do
    scenario 'adds and updates event type', feature: true do

      sign_in organizer
      visit admin_conference_program_event_types_path(
                conference_id: conference.short_title)

      within('table#event_types') do
        expect(page.assert_selector('tr', count: 2)).to be true
      end

      # Add event type
      click_link 'Add Event Type'

      fill_in 'event_type_title', with: 'Party'
      fill_in 'event_type_length', with: '240'
      fill_in 'event_type_description', with: '**Description**'
      fill_in 'event_type_submission_instructions', with: '**Instructions**'
      fill_in 'event_type_minimum_abstract_length', with: '0'
      fill_in 'event_type_maximum_abstract_length', with: '13042'
      page.find('#event_type_color').set('#e4e4e4')

      click_button 'Create Event type'
      page.find('#flash')
      # Validations
      # binding.pry
      expect(flash).to eq('Event type successfully created.')
      within('table#event_types') do
        expect(page.has_content?('Party')).to be true
        expect(page.has_content?('13042')).to be true
        expect(page.has_content?('#E4E4E4')).to be true
        expect(page.has_content?('Description')).to be true
        expect(page.has_content?('Instructions')).to be true
        expect(page.assert_selector('tr', count: 3)).to be true
      end

      # Remove event type
      within('tr', text: 'Party') do
        click_link 'Delete'
      end
      page.find('#flash')
      expect(flash).to eq('Event type successfully deleted.')

      within('table#event_types') do
        expect(page.assert_selector('tr', count: 2)).to be true
        expect(page.has_content?('Party')).to be false
      end
    end
  end

  describe 'organizer' do
    it_behaves_like 'event types'
  end
end
