require 'spec_helper'

feature DifficultyLevel do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { create(:organizer_role, resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'difficulty levels' do
    scenario 'adds and updates difficulty level', feature: true, js: true do

      sign_in organizer
      visit admin_conference_difficulty_levels_path(
                conference_id: conference.short_title)

      # Add difficulty level
      click_link 'Add difficulty_level'
      expect(page.all('div.nested-fields').count == 1).to be true

      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example difficulty level')
      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) textarea').
          set('Example difficulty level description')
      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(3) input').
          set('#ff0000')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Difficulty Levels were successfully updated.')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example difficulty level')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) textarea').
                 value).to eq('Example difficulty level description')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(3) input').
                 value).to eq('#ff0000')

      # Remove difficulty level
      click_link 'Remove difficulty_level'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Difficulty Levels were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'difficulty levels'
  end
end
