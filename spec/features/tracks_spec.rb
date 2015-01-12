require 'spec_helper'

feature Track do
  let!(:conference) { create(:conference) }
  let!(:organizer_role) { Role.find_by(name: 'organizer', resource: conference) }
  let!(:organizer) { create(:user, role_ids: [organizer_role.id]) }

  shared_examples 'tracks' do
    scenario 'adds a track', feature: true, js: true do

      sign_in organizer

      visit admin_conference_program_tracks_path(conference_id: conference.short_title)
      click_link 'New Track'

      fill_in 'track_name', with: 'Distribution'
      page.find('#track_color').set('#B94D4D')
      fill_in 'track_description', with: 'Events about our Linux distribution'
      click_button 'Create Track'

      expect(flash).to eq('Track successfully created.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
    end

    scenario 'deletes a track', feature: true, js: true do
      track = create(:track, program_id: conference.program.id)
      sign_in organizer

      visit admin_conference_program_tracks_path(conference_id: conference.short_title)

      click_link 'Delete'

      expect(flash).to eq('Track successfully deleted.')
      within('table#tracks') do
        expect(page.has_content?(track.name)).to be false
        expect(page.has_content?(track.description)).to be false
        expect(page.assert_selector('tr', count: 1)).to be true
      end
    end

    scenario 'updates a track', feature: true, js: true do
      create(:track, program_id: conference.program.id)
      sign_in organizer

      visit admin_conference_program_tracks_path(conference_id: conference.short_title)
      click_link 'Edit'

      fill_in 'track_name', with: 'Distribution'
      page.find('#track_color').set('#B94D4D')
      fill_in 'track_description', with: 'Events about our Linux distribution'
      click_button 'Update Track'

      expect(flash).to eq('Track successfully updated.')
      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux')).to be true
        expect(page.assert_selector('tr', count: 2)).to be true
      end
    end
  end

  describe 'organizer' do
    it_behaves_like 'tracks'
  end
end
