require 'spec_helper'

feature SupporterLevel do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }

  shared_examples 'supporter levels' do |user|
    scenario 'adds and updates supporter level', feature: true, js: true do
      conference = create(:conference)
      sign_in create(user)
      visit admin_conference_supporter_levels_path(
                conference_id: conference.short_title)

      # Add supporter level
      click_link 'Add supporter_level'
      expect(page.all('div.nested-fields').count == 1).to be true

      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example supporter level')

      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
          set('http://www.google.de')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Supporter levels were successfully updated.')
      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example supporter level')
      expect(find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
                 value).to eq('http://www.google.de')

      # Remove supporter level
      click_link 'Remove supporter_level'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Supporter levels were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'supporter levels', :organizer
  end
end
