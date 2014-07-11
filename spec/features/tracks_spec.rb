require 'spec_helper'

feature Track do
  # It is necessary to use bang version of let to build roles before user
  let!(:participant_role) { create(:participant_role) }
  let!(:organizer_role) { create(:organizer_role) }

  shared_examples 'tracks' do |user|
    scenario 'adds and updates tracks', feature: true, js: true do
      conference = create(:conference)
      sign_in create(user)
      visit admin_conference_tracks_path(
                conference_id: conference.short_title)

      # Add track
      click_link 'Add track'
      expect(page.all('div.nested-fields').count == 1).to be true

      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
          set('Example track')
      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
          set('#ff0000')
      page.
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(3) textarea').
          set('Example room description')

      click_button 'Update Conference'

      # Validations
      expect(flash).to eq('Tracks were successfully updated.')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(1) input').
                 value).to eq('Example track')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(2) input').
                 value).to eq('#ff0000')
      expect(
          find('div.nested-fields:nth-of-type(1) div:nth-of-type(3) textarea').
                 value).to eq('Example room description')

      # Remove track
      click_link 'Remove track'
      expect(page.all('div.nested-fields').count == 0).to be true
      click_button 'Update Conference'
      expect(flash).to eq('Tracks were successfully updated.')
      expect(page.all('div.nested-fields').count == 0).to be true
    end
  end

  describe 'organizer' do
    it_behaves_like 'tracks', :organizer
  end
end
