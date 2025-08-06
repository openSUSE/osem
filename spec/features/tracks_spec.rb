# frozen_string_literal: true

require 'spec_helper'

feature Track do
  let!(:conference) { create(:conference) }
  let!(:organizer) { create(:organizer, resource: conference) }
  let(:user) { create(:user) }

  describe 'organizer' do
    scenario 'adds a track', feature: true, js: true do

      sign_in organizer

      expect do
        visit admin_conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'New Track'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        click_button 'Create Track'
        within('#flash') { expect(page).to have_text('Track successfully created.') }
      end.to change { Track.count }.by 1

      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
      end
    end

    scenario 'deletes a track', feature: true, js: true do
      track = create(:track, program_id: conference.program.id)
      sign_in organizer

      visit admin_conference_program_tracks_path(conference_id: conference.short_title)
      within('#tracks', visible: true) do
        click_link 'Delete'
      end
      page.accept_alert

      within('#flash') { expect(page).to have_text('Track successfully deleted.') }
      expect(page.has_css?('table#tracks')).to be false
      expect(page.has_content?(track.name)).to be false
      expect(Track.count).to eq(0)
    end

    scenario 'updates a track', feature: true, js: true do
      create(:track, program_id: conference.program.id)
      sign_in organizer

      expect do
        visit admin_conference_program_tracks_path(conference_id: conference.short_title)
        within('#tracks', visible: true) do
          click_link 'Edit'
        end

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        fill_in 'track_description', with: 'Events about our Linux distribution'
        click_button 'Update Track'
        within('#flash') { expect(page).to have_text('Track successfully updated.') }
      end.to_not(change { Track.count })

      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux')).to be true
      end
    end
  end

  describe 'signed in user' do
    before :each do
      create(:cfp, cfp_type: 'tracks', program: conference.program)
    end

    scenario 'adds a track', feature: true, js: true do

      sign_in user

      expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'New Track request'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        fill_in 'track_description', with: 'Events about our Linux distribution'
        fill_in 'track_relevance', with: 'Maintainer of super awesome distribution'
        click_button 'Create Track'
        within('#flash') { expect(page).to have_text('Track request successfully created.') }
      end.to change { Track.count }.by 1

      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux dist...')).to be true
      end
    end

    scenario 'withdraws a track', feature: true, js: true do
      track = create(:track, :self_organized, program_id: conference.program.id, submitter: user)
      sign_in user

      expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)

        accept_confirm do
          click_link 'Withdraw'
        end
        within('#flash') { expect(page).to have_text("Track #{track.name} withdrawn.") }
      end.to_not(change { Track.count })

      within('table#tracks') do
        expect(page.has_content?(track.name)).to be true
        expect(page.has_link?('Re-Submit')).to be true
      end
    end

    scenario 'updates a track', feature: true, js: true do
      create(:track, :self_organized, program_id: conference.program.id, submitter: user)
      sign_in user

      expect do
        visit conference_program_tracks_path(conference_id: conference.short_title)
        click_link 'Edit'

        fill_in 'track_name', with: 'Distribution'
        fill_in 'track_short_name', with: 'Distribution'
        fill_in 'track_description', with: 'Events about our Linux distribution'
        click_button 'Update Track'
        within('#flash') { expect(page).to have_text('Track request successfully updated.') }
      end.to_not(change { Track.count })

      within('table#tracks') do
        expect(page.has_content?('Distribution')).to be true
        expect(page.has_content?('Events about our Linux dist...')).to be true
      end
    end
  end
end
