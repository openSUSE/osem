# frozen_string_literal: true

require 'spec_helper'

feature DifficultyLevel do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }

  shared_examples 'difficulty levels' do
    scenario 'adds difficulty level', feature: true, js: true do

      sign_in organizer
      visit admin_conference_program_difficulty_levels_path(
                conference_id: conference.short_title)

      # Add difficulty level
      click_link 'Add Difficulty Level'

      fill_in 'difficulty_level_title', with: 'Hard'
      fill_in 'difficulty_level_description', with: 'Life is the hardest'
      page.find('#difficulty_level_color').set('#ff0000')

      click_button 'Create Difficulty level'
      page.find('#flash')
      # Validations
      expect(flash).to eq('Difficulty level successfully created.')
      within('table#difficulty_levels') do
        expect(page.has_content?('Hard')).to be true
        expect(page.has_content?('Life is the hardest')).to be true
        expect(page.assert_selector('tr', count: 5)).to be true
      end
    end

    scenario 'updates difficulty level', feature: true, js: true do

      conference.program.difficulty_levels << create(:difficulty_level)
      sign_in organizer
      visit admin_conference_program_difficulty_levels_path(
                conference_id: conference.short_title)

      # Remove difficulty level
      page.accept_alert do
        within('table tr:nth-of-type(4)') do
          click_link 'Delete'
        end
      end
      page.find('#flash')

      # Validations
      expect(flash).to eq('Difficulty level successfully deleted.')
      within('table#difficulty_levels') do
        expect(page.assert_selector('tr', count: 4)).to be true
        expect(page.has_content?('Easy Events')).to be true
        expect(page.has_content?('Medium Events')).to be true
        expect(page.has_content?('Hard Events')).to be true
      end
    end

  end

  describe 'organizer' do
    it_behaves_like 'difficulty levels'
  end
end
